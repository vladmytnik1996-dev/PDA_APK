from playwright.sync_api import sync_playwright
import sys
URL='http://localhost:8765/index.html'
errors=[]; console=[]
with sync_playwright() as p:
    browser=p.chromium.launch(headless=True, executable_path='/usr/bin/chromium', args=['--no-sandbox','--disable-dev-shm-usage','--use-fake-device-for-media-stream','--use-fake-ui-for-media-stream'])
    context=browser.new_context(viewport={'width':390,'height':844}, locale='ru-RU', permissions=['camera'])
    page=context.new_page()
    page.on('pageerror', lambda e: errors.append(str(e)))
    page.on('console', lambda m: console.append(m.text) if m.type=='error' else None)
    page.goto(URL, wait_until='domcontentloaded', timeout=60000)
    page.wait_for_timeout(400)
    if page.locator('#startBtn').is_visible(): page.locator('#startBtn').click()
    page.locator('#qrReceiveBtn').click()
    page.wait_for_selector('#qrModal.visible')
    page.wait_for_function("document.querySelector('#qrVideo').srcObject && document.querySelector('#qrVideo').srcObject.getVideoTracks().length > 0", timeout=20000)
    live=page.evaluate("document.querySelector('#qrVideo').srcObject.getVideoTracks()[0].readyState")
    assert live=='live', live
    page.locator('#closeQrModal').click()
    page.wait_for_timeout(300)
    stopped=page.evaluate("!document.querySelector('#qrVideo').srcObject")
    assert stopped, 'camera stream was not released'
    browser.close()
if errors or console:
    print('PAGE_ERRORS',errors); print('CONSOLE_ERRORS',console); sys.exit(2)
print('CAMERA_SMOKE_OK')
