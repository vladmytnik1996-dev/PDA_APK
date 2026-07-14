from playwright.sync_api import sync_playwright
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
import base64, json, sys, time

URL='http://localhost:8765/index.html'
MAP=str(ROOT/'test-data/test_map.png')
errors=[]
console_errors=[]
def mark(x): print('STEP', x, flush=True)

with sync_playwright() as p:
    mark('launch')
    browser=p.chromium.launch(headless=True, executable_path='/usr/bin/chromium', args=['--no-sandbox','--disable-dev-shm-usage'])
    context=browser.new_context(viewport={'width':390,'height':844}, locale='ru-RU', accept_downloads=True, permissions=['geolocation'], geolocation={'latitude':54.48,'longitude':26.40,'accuracy':8})
    page=context.new_page()
    page.on('pageerror', lambda e: errors.append(str(e)))
    page.on('console', lambda m: console_errors.append(m.text) if m.type=='error' else None)
    mark('load')
    page.goto(URL, wait_until='domcontentloaded', timeout=60000)
    page.wait_for_timeout(700)
    if page.locator('#startBtn').is_visible():
        page.locator('#startBtn').click()
    page.wait_for_timeout(400)

    mark('map')
    # Load a map and verify it appears.
    page.locator('#mapFileTop').set_input_files(MAP)
    page.wait_for_function("document.querySelector('#zoneMap').naturalWidth > 0", timeout=20000)
    page.wait_for_timeout(600)
    assert page.locator('#zoneMap').is_visible(), 'map image not visible'

    mark('drag')
    # Zoom and violently drag: map must still cover the viewport on both axes.
    for _ in range(5): page.locator('#zoomInBtn').click()
    vp=page.locator('#mapViewport').bounding_box()
    page.mouse.move(vp['x']+vp['width']/2, vp['y']+vp['height']/2)
    page.mouse.down()
    page.mouse.move(vp['x']+vp['width']*3, vp['y']+vp['height']*3, steps=5)
    page.mouse.up()
    page.wait_for_timeout(300)
    check=page.evaluate("""() => {
      const v=document.querySelector('#mapViewport').getBoundingClientRect();
      const i=document.querySelector('#zoneMap').getBoundingClientRect();
      return {v:{l:v.left,t:v.top,r:v.right,b:v.bottom},i:{l:i.left,t:i.top,r:i.right,b:i.bottom},overflow:document.documentElement.scrollWidth-document.documentElement.clientWidth};
    }""")
    assert check['i']['l'] <= check['v']['l'] + 1.5
    assert check['i']['t'] <= check['v']['t'] + 1.5
    assert check['i']['r'] >= check['v']['r'] - 1.5
    assert check['i']['b'] >= check['v']['b'] - 1.5
    assert check['overflow'] <= 1

    mark('marker')
    # Marker workflow.
    page.locator('#addMarkerBtn').click()
    vp=page.locator('#mapViewport').bounding_box()
    page.mouse.click(vp['x']+vp['width']*0.55, vp['y']+vp['height']*0.45)
    page.locator('#markerTitle').fill('Тайник — тест ✓')
    page.locator('#markerDesc').fill('Под разрушенным мостом <script>не выполнять</script>')
    page.locator('#markerType').select_option('stash')
    page.locator('#saveMarkerBtn').click()
    page.wait_for_timeout(300)
    page.locator('[data-tab="tasksPanel"]').click()
    page.wait_for_timeout(250)
    assert page.locator('.task-card').count()==1
    assert 'Тайник' in page.locator('.task-card').inner_text()

    mark('markerqr')
    # Share marker as QR.
    page.locator('.task-card button', has_text='Передать').click()
    page.wait_for_selector('#qrModal.visible')
    page.wait_for_function("document.querySelector('#qrCanvas').width > 100")
    qr_data=page.locator('#qrCanvas').evaluate("c => c.toDataURL('image/png')")
    assert qr_data.startswith('data:image/png;base64,')
    qr_path=ROOT/'test-results/marker-qr.png'
    qr_path.write_bytes(base64.b64decode(qr_data.split(',',1)[1]))
    page.locator('#closeQrModal').click()

    mark('note')
    # Note workflow and QR.
    page.locator('[data-tab="notesPanel"]').click()
    page.locator('#newNoteBtn').click()
    page.locator('#noteTitle').fill('Запись с кириллицей')
    page.locator('#noteBody').fill('Проверка специальных символов: <b>&"\' — только текст.')
    page.locator('#saveNoteBtn').click()
    assert page.locator('.note-card').count()==1
    page.locator('.note-card button', has_text='Передать').click()
    page.wait_for_function("document.querySelector('#qrCanvas').width > 100")
    page.locator('#closeQrModal').click()

    mark('importqr')
    # Import marker QR from image, preview, confirm; ID must be regenerated.
    page.locator('#qrReceiveBtn').click()
    page.wait_for_selector('#qrModal.visible')
    page.locator('#qrImageInput').set_input_files(str(qr_path))
    page.wait_for_selector('#qrPreviewView:not(.hidden)', timeout=15000)
    preview=page.locator('#qrPreviewContent').inner_text()
    assert 'Тайник' in preview
    page.locator('#qrImportBtn').click()
    page.wait_for_timeout(400)
    page.locator('[data-tab="tasksPanel"]').click()
    assert page.locator('.task-card').count()==2

    mark('export')
    # Export in browser fallback.
    page.locator('[data-tab="dataPanel"]').click()
    with page.expect_download(timeout=10000) as dl:
        page.locator('#exportBtn').click()
    download=dl.value
    out=str(ROOT/'test-results/browser-export.json')
    download.save_as(out)
    data=json.loads(Path(out).read_text('utf-8'))
    assert data['version']==7 and len(data['tasks'])==2 and len(data['notes'])==1

    mark('gps')
    # GPS permission/start should not be rejected as insecure on localhost.
    page.locator('[data-tab="mapPanel"]').click()
    page.locator('#gpsBtnTop').click()
    page.wait_for_timeout(1200)
    text=page.locator('#gpsStatusText').inner_text()
    assert 'заблокирован' not in text.lower() and 'не является защищённым' not in text.lower(), text

    mark('reload')
    # State survives reload.
    page.reload(wait_until='domcontentloaded')
    page.wait_for_timeout(600)
    page.locator('[data-tab="tasksPanel"]').click()
    assert page.locator('.task-card').count()==2
    page.locator('[data-tab="notesPanel"]').click()
    assert page.locator('.note-card').count()==1

    mark('responsive')
    # Responsive regression widths.
    for w,h in [(320,568),(360,800),(375,812),(390,844),(414,896),(768,1024),(1024,768),(1440,900)]:
        page.set_viewport_size({'width':w,'height':h})
        page.wait_for_timeout(120)
        overflow=page.evaluate('document.documentElement.scrollWidth-document.documentElement.clientWidth')
        assert overflow <= 1, (w,h,overflow)

    mark('done')
    page.screenshot(path=str(ROOT/'test-results/web-final.png'), full_page=True)
    browser.close()

if errors or console_errors:
    print('PAGE_ERRORS',errors)
    print('CONSOLE_ERRORS',console_errors)
    sys.exit(2)
print('WEB_SMOKE_OK')
