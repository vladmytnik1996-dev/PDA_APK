from playwright.sync_api import sync_playwright
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
HTML=(ROOT/'android/apktool-app/assets/www/index.html').read_text('utf-8')
errors=[]; console=[]
with sync_playwright() as p:
    browser=p.chromium.launch(headless=True, executable_path='/usr/bin/chromium', args=['--no-sandbox','--disable-dev-shm-usage','--use-fake-device-for-media-stream'])
    page=browser.new_page(viewport={'width':390,'height':844}, locale='ru-RU')
    page.on('pageerror',lambda e: errors.append(str(e)))
    page.on('console',lambda m: console.append(m.text) if m.type=='error' else None)
    page.evaluate("""() => {
      const mem=new Map(); const storage={getItem:k=>mem.get(String(k))??null,setItem:(k,v)=>mem.set(String(k),String(v)),removeItem:k=>mem.delete(String(k)),clear:()=>mem.clear()};
      Object.defineProperty(window,'localStorage',{value:storage,configurable:true});
      Object.defineProperty(window,'indexedDB',{value:null,configurable:true});
      Object.defineProperty(window,'isSecureContext',{value:true,configurable:true});
      const c=document.createElement('canvas'); c.width=640;c.height=480; const stream=c.captureStream(5); window.__testStream=stream;
      Object.defineProperty(navigator,'mediaDevices',{value:{getUserMedia:async()=>stream},configurable:true});
    }""")
    page.set_content(HTML,wait_until='domcontentloaded'); page.wait_for_timeout(300)
    if page.locator('#startBtn').is_visible(): page.locator('#startBtn').click()
    page.locator('#qrReceiveBtn').click(); page.wait_for_selector('#qrModal.visible')
    page.wait_for_function("document.querySelector('#qrVideo').srcObject && document.querySelector('#qrVideo').srcObject.getVideoTracks().length")
    assert page.evaluate("__testStream.getVideoTracks()[0].readyState")=='live'
    page.locator('#closeQrModal').click(); page.wait_for_timeout(200)
    assert page.evaluate("!document.querySelector('#qrVideo').srcObject")
    assert page.evaluate("__testStream.getVideoTracks()[0].readyState")=='ended'
    browser.close()
if errors or console:
    print('PAGE_ERRORS',errors); print('CONSOLE_ERRORS',console); sys.exit(2)
print('CAMERA_DOM_SMOKE_OK')
