#!/usr/bin/env python3
from pathlib import Path
from html.parser import HTMLParser
import re, json, subprocess, tempfile, sys
ROOT=Path(__file__).resolve().parents[1]
HTML=ROOT/'android/apktool-app/assets/www/index.html'
text=HTML.read_text('utf-8')
class P(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=False); self.ids=[]; self.external=[]; self.scripts=[]; self._in_script=False; self._buf=[]
    def handle_starttag(self,tag,attrs):
        a=dict(attrs)
        if 'id' in a: self.ids.append(a['id'])
        if tag=='script':
            if a.get('src'): self.external.append(('script',a['src']))
            self._in_script=True; self._buf=[]
        if tag=='link' and a.get('rel') and 'stylesheet' in a.get('rel','').lower() and a.get('href'): self.external.append(('stylesheet',a['href']))
        if tag in ('img','audio','video','source') and a.get('src') and not a['src'].startswith(('data:','blob:')): self.external.append((tag,a['src']))
    def handle_endtag(self,tag):
        if tag=='script' and self._in_script:
            self.scripts.append(''.join(self._buf)); self._in_script=False; self._buf=[]
    def handle_data(self,data):
        if self._in_script: self._buf.append(data)
p=P(); p.feed(text)
ids=p.ids; dup=sorted({x for x in ids if ids.count(x)>1})
refs=sorted(set(re.findall(r"\bbyId\(\s*['\"]([^'\"]+)['\"]\s*\)",text)))
missing=sorted(set(refs)-set(ids))
js_results=[]
for i,script in enumerate(p.scripts,1):
    if not script.strip(): continue
    f=ROOT/'test-results'/f'inline-script-{i}.js'; f.write_text(script,'utf-8')
    r=subprocess.run(['node','--check',str(f)],capture_output=True,text=True)
    js_results.append({'script':i,'ok':r.returncode==0,'stderr':r.stderr.strip()})
forbidden={pat:bool(re.search(pat,text,re.I)) for pat in [r'\beval\s*\(',r'new\s+Function\s*\(',r'\.innerHTML\s*=',r'\.outerHTML\s*=',r'document\.write\s*\(',r'console\.log\s*\(',r'\bdebugger\b',r'\bTODO\b',r'\bFIXME\b']}
result={
 'html':str(HTML), 'bytes':HTML.stat().st_size, 'ids':len(ids), 'duplicate_ids':dup,
 'byId_refs':len(refs),'missing_byId_refs':missing,'external_runtime_resources':p.external,
 'inline_scripts':js_results,'forbidden_patterns':forbidden,
 'start_data_count': len(re.findall(r"(?:title|description|body)\s*:\s*['\"][^'\"]+['\"]", text[text.find("const state"):text.find("function byId") if "function byId" in text else len(text)])) if "const state" in text else None
}
out=ROOT/'test-results/static-audit.json'; out.write_text(json.dumps(result,ensure_ascii=False,indent=2),'utf-8')
lines=[
 f"HTML: {HTML}",f"Размер: {HTML.stat().st_size} байт",f"ID: {len(ids)}; дубликаты: {dup or 'нет'}",
 f"byId-ссылок: {len(refs)}; отсутствуют: {missing or 'нет'}",f"Внешние runtime-ресурсы: {p.external or 'нет'}",
]
lines += [f"JS блок {x['script']}: {'OK' if x['ok'] else 'FAIL'} {x['stderr']}" for x in js_results]
lines += [f"{k}: {'НАЙДЕНО' if v else 'нет'}" for k,v in forbidden.items()]
(ROOT/'test-results/static-audit.txt').write_text('\n'.join(lines)+'\n','utf-8')
fail=bool(dup or missing or p.external or any(not x['ok'] for x in js_results) or any(forbidden.values()))
print('\n'.join(lines))
sys.exit(1 if fail else 0)
