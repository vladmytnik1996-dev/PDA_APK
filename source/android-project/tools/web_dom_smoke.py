from playwright.sync_api import sync_playwright
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
HTML=(ROOT/'android/apktool-app/assets/www/index.html').read_text('utf-8')
MAP=str(ROOT/'test-data/test_map.png')
errors=[]; console=[]
with sync_playwright() as p:
    browser=p.chromium.launch(headless=True, executable_path='/usr/bin/chromium', args=['--no-sandbox','--disable-dev-shm-usage'])
    page=browser.new_page(viewport={'width':390,'height':844}, locale='ru-RU')
    page.on('pageerror',lambda e: errors.append(str(e)))
    page.on('console',lambda m: console.append(m.text) if m.type=='error' else None)
    page.evaluate("""() => {
      const mem=new Map();
      const storage={getItem:k=>mem.has(String(k))?mem.get(String(k)):null,setItem:(k,v)=>mem.set(String(k),String(v)),removeItem:k=>mem.delete(String(k)),clear:()=>mem.clear(),key:i=>Array.from(mem.keys())[i]??null,get length(){return mem.size}};
      Object.defineProperty(window,'localStorage',{value:storage,configurable:true});
      Object.defineProperty(window,'sessionStorage',{value:storage,configurable:true});
      Object.defineProperty(window,'indexedDB',{value:null,configurable:true});
    }""")
    page.set_content(HTML,wait_until='domcontentloaded')
    page.wait_for_timeout(500)
    if page.locator('#startBtn').is_visible(): page.locator('#startBtn').click()
    page.locator('#mapFileTop').set_input_files(MAP)
    page.wait_for_function("document.querySelector('#zoneMap').naturalWidth > 0")
    for _ in range(5): page.locator('#zoomInBtn').click()
    vp=page.locator('#mapViewport').bounding_box()
    page.mouse.move(vp['x']+vp['width']/2,vp['y']+vp['height']/2); page.mouse.down(); page.mouse.move(vp['x']+vp['width']*3,vp['y']+vp['height']*3,steps=5); page.mouse.up()
    check=page.evaluate("""() => {const v=mapViewport.getBoundingClientRect(),i=zoneMap.getBoundingClientRect();return {ok:i.left<=v.left+2&&i.top<=v.top+2&&i.right>=v.right-2&&i.bottom>=v.bottom-2,overflow:document.documentElement.scrollWidth-document.documentElement.clientWidth}}""")
    assert check['ok'] and check['overflow']<=1,check
    page.locator('#centerBtn').click(); page.wait_for_timeout(100)
    page.locator('#addMarkerBtn').click(); page.locator('#mapViewport').click(position={'x':vp['width']*.55,'y':vp['height']*.45}); page.wait_for_selector('#markerModal.visible')
    page.locator('#markerTitle').fill('Тайник — тест ✓'); page.locator('#markerDesc').fill('<script>только текст</script>'); page.locator('#markerType').select_option('stash'); page.locator('#saveMarkerBtn').click()
    page.locator('[data-tab="tasksPanel"]').click(); assert page.locator('.task-card').count()==1
    page.locator('.task-card button',has_text='Передать').click(); page.wait_for_selector('#qrModal.visible'); page.wait_for_function("qrCanvas.width>100"); page.locator('#closeQrModal').click()
    page.locator('[data-tab="notesPanel"]').click(); page.locator('#newNoteBtn').click(); page.locator('#noteTitle').fill('Заметка'); page.locator('#noteBody').fill('Кириллица & <b>текст</b>'); page.locator('#saveNoteBtn').click(); assert page.locator('.note-card').count()==1
    for w,h in [(320,568),(360,800),(375,812),(390,844),(414,896),(768,1024),(1024,768),(1440,900)]:
        page.set_viewport_size({'width':w,'height':h}); page.wait_for_timeout(50); assert page.evaluate('document.documentElement.scrollWidth-document.documentElement.clientWidth')<=1
    browser.close()
if errors or console:
    print('PAGE_ERRORS',errors); print('CONSOLE_ERRORS',console); sys.exit(2)
print('WEB_DOM_SMOKE_OK')
