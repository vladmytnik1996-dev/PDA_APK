from playwright.sync_api import sync_playwright
from pathlib import Path
import base64, json, sys

ROOT = Path(__file__).resolve().parents[1]
HTML = (ROOT / 'android/apktool-app/assets/www/index.html').read_text('utf-8')
OUT = ROOT / 'test-results'
OUT.mkdir(exist_ok=True)
errors = []
console_errors = []

state = {
    'version': 8,
    'booted': True,
    'sound': False,
    'map': {'name': 'demo-sector.png', 'type': 'image/png', 'size': 1000, 'w': 900, 'h': 1200, 'saved': False},
    'tasks': [],
    'notes': [],
    'gps': {
        'follow': False,
        'calibration': {
            'anchors': [
                {'lat': 54.4801, 'lng': 26.4001, 'accuracy': 6, 'x': 0.25, 'y': 0.32, 'ts': 1710000000000},
                {'lat': 54.4810, 'lng': 26.4030, 'accuracy': 7, 'x': 0.74, 'y': 0.69, 'ts': 1710000100000},
            ],
            'metersPerPixel': 1.25,
            'rotationDeg': -3.5,
        },
    },
}

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True, executable_path='/usr/bin/chromium', args=['--no-sandbox', '--disable-dev-shm-usage'])
    page = browser.new_page(viewport={'width': 390, 'height': 844}, locale='ru-RU')
    page.on('pageerror', lambda e: errors.append(str(e)))
    page.on('console', lambda m: console_errors.append(m.text) if m.type == 'error' else None)

    page.evaluate("""(initial) => {
      const mem = new Map([['zonePdaSingle.v2', JSON.stringify(initial)]]);
      const storage = {
        getItem: k => mem.has(String(k)) ? mem.get(String(k)) : null,
        setItem: (k,v) => mem.set(String(k), String(v)),
        removeItem: k => mem.delete(String(k)),
        clear: () => mem.clear(),
        key: i => Array.from(mem.keys())[i] ?? null,
        get length(){ return mem.size; }
      };
      Object.defineProperty(window, 'localStorage', {value: storage, configurable: true});
      Object.defineProperty(window, 'sessionStorage', {value: storage, configurable: true});
      Object.defineProperty(window, 'indexedDB', {value: null, configurable: true});
    }""", state)

    page.set_content(HTML, wait_until='domcontentloaded')
    page.wait_for_timeout(350)

    # Inactive long map hint must not consume space or clip on mobile.
    assert page.locator('#mapHint').inner_text() == ''
    assert page.locator('#mapHint').evaluate("e => getComputedStyle(e).display") == 'none'

    page.locator('[data-tab="dataPanel"]').click()
    share = page.locator('#gpsShareCalibrationBtn')
    assert share.is_enabled(), 'share button must be enabled for existing calibration'
    assert 'active' in (share.get_attribute('class') or '')
    share.click()
    page.wait_for_selector('#qrModal.visible')
    page.wait_for_function("document.querySelector('#qrCanvas').width > 100")
    assert 'GPS-ПРИВЯЗКА КАРТЫ' in page.locator('#qrShareSubject').inner_text().upper()

    payload = page.evaluate("""() => {
      const c = document.querySelector('#qrCanvas');
      const x = c.getContext('2d');
      const d = x.getImageData(0, 0, c.width, c.height);
      const r = window.jsQR(d.data, c.width, c.height, {inversionAttempts:'attemptBoth'});
      return r ? JSON.parse(r.data) : null;
    }""")
    assert payload and payload['type'] == 'mapCalibration'
    assert payload['version'] == 1
    assert payload['data']['location'] == 'demo-sector.png'
    assert len(payload['data']['anchors']) == 2
    assert abs(payload['data']['metersPerPixel'] - 1.25) < 1e-9

    png_data = page.locator('#qrCanvas').evaluate("c => c.toDataURL('image/png')")
    qr_file = OUT / 'gps-calibration-qr.png'
    qr_file.write_bytes(base64.b64decode(png_data.split(',', 1)[1]))
    page.locator('#closeQrModal').click()

    # Reinitialize app without calibration; button must become disabled.
    empty = json.loads(json.dumps(state))
    empty['gps']['calibration']['anchors'] = []
    page.evaluate("s => localStorage.setItem('zonePdaSingle.v2', JSON.stringify(s))", empty)
    page.set_content(HTML, wait_until='domcontentloaded')
    page.wait_for_timeout(300)
    page.locator('[data-tab="dataPanel"]').click()
    assert page.locator('#gpsShareCalibrationBtn').is_disabled()

    # Import the QR from an image, inspect preview, confirm, then verify persisted GPS state.
    page.locator('#qrReceiveDataBtn').click()
    page.wait_for_selector('#qrModal.visible')
    page.locator('#qrImageInput').set_input_files(str(qr_file))
    page.wait_for_selector('#qrPreviewView:not(.hidden)', timeout=15000)
    preview = page.locator('#qrPreviewContent').inner_text().upper()
    assert 'GPS-ПРИВЯЗКА КАРТЫ' in preview
    assert 'A И B' in preview
    assert 'ПРИМЕНИТЬ ПРИВЯЗКУ' in page.locator('#qrImportBtn').inner_text().upper()
    page.locator('#qrImportBtn').click()
    page.wait_for_timeout(250)
    saved = page.evaluate("JSON.parse(localStorage.getItem('zonePdaSingle.v2'))")
    assert len(saved['gps']['calibration']['anchors']) == 2
    assert saved['gps']['follow'] is False
    assert abs(saved['gps']['calibration']['metersPerPixel'] - 1.25) < 1e-9
    assert page.locator('#gpsShareCalibrationBtn').is_enabled()

    # Invalid calibration payloads must be rejected without changing saved state.
    def make_qr_file(payload, name):
        encoded = page.evaluate("""(payload) => {
          const text = JSON.stringify(payload);
          const code = window.qrcode(0, 'L');
          code.addData(text, 'Byte');
          code.make();
          const quiet = 4, cell = 6, modules = code.getModuleCount();
          const c = document.createElement('canvas');
          c.width = c.height = (modules + quiet * 2) * cell;
          const x = c.getContext('2d', {alpha:false});
          x.fillStyle = '#fff'; x.fillRect(0,0,c.width,c.height); x.fillStyle = '#000';
          for (let r=0;r<modules;r++) for (let col=0;col<modules;col++) if (code.isDark(r,col)) x.fillRect((col+quiet)*cell,(r+quiet)*cell,cell,cell);
          return c.toDataURL('image/png');
        }""", payload)
        target = OUT / name
        target.write_bytes(base64.b64decode(encoded.split(',', 1)[1]))
        return target

    invalid_payloads = [
        ({'app':'other-app','version':1,'type':'mapCalibration','data':{}}, 'Этот QR-код создан другим приложением'),
        ({'app':'stalker-pda','version':2,'type':'mapCalibration','data':{}}, 'Версия формата QR-кода не поддерживается'),
        ({'app':'stalker-pda','version':1,'type':'mapCalibration','data':{'location':'x','mapWidth':900,'mapHeight':1200,'anchors':[],'metersPerPixel':1,'rotationDeg':0,'updatedAt':1710000000000}}, 'одну или две контрольные точки'),
        ({'app':'stalker-pda','version':1,'type':'mapCalibration','data':{'location':'x','mapWidth':900,'mapHeight':1200,'anchors':[{'lat':190,'lng':26,'accuracy':5,'x':.5,'y':.5,'ts':1710000000000}],'metersPerPixel':1,'rotationDeg':0,'updatedAt':1710000000000}}, 'Широта точки A'),
        ({'app':'stalker-pda','version':1,'type':'mapCalibration','data':{'location':'x','mapWidth':900,'mapHeight':1200,'anchors':[{'lat':54,'lng':26,'accuracy':5,'x':1.5,'y':.5,'ts':1710000000000}],'metersPerPixel':1,'rotationDeg':0,'updatedAt':1710000000000}}, 'находятся вне карты'),
    ]
    page.locator('#qrReceiveDataBtn').click()
    page.wait_for_selector('#qrModal.visible')
    for idx, (bad, expected) in enumerate(invalid_payloads):
        bad_file = make_qr_file(bad, f'invalid-calibration-{idx}.png')
        page.locator('#qrImageInput').set_input_files(str(bad_file))
        page.wait_for_timeout(250)
        status = page.locator('#qrScannerStatus').inner_text()
        assert expected.lower() in status.lower(), (expected, status)
    page.locator('#closeQrModal').click()
    after_invalid = page.evaluate("JSON.parse(localStorage.getItem('zonePdaSingle.v2'))")
    assert len(after_invalid['gps']['calibration']['anchors']) == 2

    # Responsive regression including the smallest and wide layouts.
    for width, height in [(320,568),(360,800),(375,812),(390,844),(414,896),(768,1024),(1024,768),(1280,800),(1440,900),(1920,1080)]:
        page.set_viewport_size({'width': width, 'height': height})
        page.wait_for_timeout(40)
        overflow = page.evaluate('document.documentElement.scrollWidth-document.documentElement.clientWidth')
        assert overflow <= 1, (width, height, overflow)

    page.screenshot(path=str(OUT / 'gps-calibration-final.png'), full_page=True)
    browser.close()

if errors or console_errors:
    print('PAGE_ERRORS', errors)
    print('CONSOLE_ERRORS', console_errors)
    sys.exit(2)
print('GPS_CALIBRATION_QR_DOM_OK')
