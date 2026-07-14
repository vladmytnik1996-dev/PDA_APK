#!/usr/bin/env python3
from pathlib import Path
import re, sys, json

ROOT = Path(__file__).resolve().parents[1]
SMALI_ROOT = ROOT / 'android' / 'apktool-app' / 'smali'
RESULTS = ROOT / 'test-results'
RESULTS.mkdir(exist_ok=True)

errors=[]; warnings=[]; stats={'files':0,'classes':0,'methods':0,'handlers':0,'instructions':0}

def err(path, line, msg): errors.append(f'{path.relative_to(ROOT)}:{line}: {msg}')
def warn(path, line, msg): warnings.append(f'{path.relative_to(ROOT)}:{line}: {msg}')

def descriptor_param_slots(desc, is_static):
    m=re.match(r'\((.*?)\)',desc)
    if not m: return None
    s=m.group(1); i=0; slots=0 if is_static else 1
    while i<len(s):
        c=s[i]
        if c in 'ZBCSIF': slots+=1; i+=1
        elif c in 'JD': slots+=2; i+=1
        elif c=='L':
            j=s.find(';',i)
            if j<0: return None
            slots+=1; i=j+1
        elif c=='[':
            while i<len(s) and s[i]=='[': i+=1
            if i<len(s) and s[i]=='L':
                j=s.find(';',i)
                if j<0: return None
                i=j+1
            else: i+=1
            slots+=1
        else: return None
    return slots

def is_exec(s):
    s=s.strip()
    return bool(s and not s.startswith(('.',':','#')))

def is_terminal(op):
    return op.startswith('return') or op.startswith('throw') or op.startswith('goto')

for path in sorted(SMALI_ROOT.rglob('*.smali')):
    stats['files']+=1; stats['classes']+=1
    lines=path.read_text('utf-8').splitlines()
    class_name=None
    method_sigs=set()
    for i,l in enumerate(lines,1):
        if l.strip().startswith('.class '):
            class_name=l.strip().split()[-1]
            break
    if not class_name: err(path,1,'нет объявления .class')

    idx=0
    while idx<len(lines):
        line=lines[idx].strip()
        if not line.startswith('.method '): idx+=1; continue
        start=idx; header=line; stats['methods']+=1
        end=idx+1
        while end<len(lines) and lines[end].strip()!='.end method': end+=1
        if end>=len(lines):
            err(path,start+1,'метод не закрыт .end method'); break
        body=lines[start:end+1]
        sig=header.split()[-1]
        if sig in method_sigs: err(path,start+1,f'дублирующийся метод {sig}')
        method_sigs.add(sig)
        desc=sig[sig.find('('):] if '(' in sig else ''
        ret=desc[desc.rfind(')')+1:] if ')' in desc else ''
        is_static=' static ' in f' {header} '
        pslots=descriptor_param_slots(desc,is_static)

        locals_n=None
        for j,b in enumerate(body, start+1):
            m=re.match(r'\s*\.locals\s+(\d+)',b)
            if m: locals_n=int(m.group(1)); break
            m=re.match(r'\s*\.registers\s+(\d+)',b)
            if m: warn(path,j,'.registers не проверяется этим аудитом'); break
        if locals_n is None: err(path,start+1,'нет .locals/.registers')

        labels={}; refs=[]; catches=[]; execs=[]; move_ex=[]
        for rel,b in enumerate(body):
            absline=start+rel+1; st=b.strip()
            if st.startswith(':'):
                lab=st.split()[0]
                if lab in labels: err(path,absline,f'дублирующаяся метка {lab}')
                labels[lab]=(rel,absline)
            if is_exec(st):
                execs.append((rel,absline,st)); stats['instructions']+=1
                op=st.split()[0]
                if op=='move-exception': move_ex.append((rel,absline,st))
                if op.startswith(('goto','if-')):
                    found=re.findall(r'(:[A-Za-z0-9_.$-]+)',st)
                    for lab in found[-1:]: refs.append((lab,absline,op))
                if op in ('packed-switch','sparse-switch','fill-array-data'):
                    found=re.findall(r'(:[A-Za-z0-9_.$-]+)',st)
                    for lab in found[-1:]: refs.append((lab,absline,op))
            cm=re.match(r'\s*\.catch(?:all|\s+\S+)?\s*\{(:\S+)\s+\.\.\s+(:\S+)\}\s+(:\S+)',b)
            if cm:
                catches.append((cm.group(1),cm.group(2),cm.group(3),absline)); stats['handlers']+=1

        for lab,line_no,op in refs:
            if lab not in labels: err(path,line_no,f'{op}: отсутствует метка {lab}')

        handler_labels={h for _,_,h,_ in catches}
        for ts,te,h,line_no in catches:
            for lab in (ts,te,h):
                if lab not in labels: err(path,line_no,f'.catch с отсутствующей меткой {lab}')
            if ts in labels and te in labels and labels[ts][0]>=labels[te][0]:
                err(path,line_no,f'некорректный диапазон try {ts}..{te}')
            if h not in labels: continue
            hrel,hline=labels[h]
            first=next((x for x in execs if x[0]>hrel),None)
            if not first or not first[2].startswith('move-exception '):
                err(path,hline,f'обработчик {h} не начинается с move-exception')
            # move-exception must not be reachable via explicit normal branch
            for lab,rl,op in refs:
                if lab==h: err(path,rl,f'нормальный переход {op} в catch-обработчик {h}')
            # labels have zero width: if immediately previous instruction falls through, ART rejects it
            prev=next((x for x in reversed(execs) if x[0]<hrel),None)
            if prev and not is_terminal(prev[2].split()[0]):
                err(path,hline,f'возможен обычный fall-through из `{prev[2]}` в move-exception обработчика {h}')

        for rel,line_no,st in move_ex:
            # It must be the first executable instruction after one of handler labels.
            owners=[]
            for h in handler_labels:
                if h in labels:
                    first=next((x for x in execs if x[0]>labels[h][0]),None)
                    if first and first[0]==rel: owners.append(h)
            if not owners: err(path,line_no,'move-exception находится вне начала catch-обработчика')

        for k,(rel,line_no,st) in enumerate(execs):
            op=st.split()[0]
            if op.startswith('move-result'):
                if k==0:
                    err(path,line_no,'move-result без предыдущей инструкции')
                else:
                    prevop=execs[k-1][2].split()[0]
                    if not (prevop.startswith('invoke-') or prevop=='filled-new-array' or prevop=='filled-new-array/range'):
                        err(path,line_no,f'move-result после недопустимой инструкции {prevop}')
            if op.startswith('return'):
                expected = 'return-void' if ret=='V' else ('return-object' if ret.startswith(('L','[')) else ('return-wide' if ret in ('J','D') else 'return'))
                if op!=expected: err(path,line_no,f'{op} не соответствует типу возврата {ret} (ожидается {expected})')
            if locals_n is not None:
                for reg in re.findall(r'\bv(\d+)\b',st):
                    if int(reg)>=locals_n: err(path,line_no,f'регистр v{reg} выходит за .locals {locals_n}')
            if pslots is not None:
                for reg in re.findall(r'\bp(\d+)\b',st):
                    if int(reg)>=pslots: err(path,line_no,f'параметр p{reg} выходит за {pslots} регистров параметров')

        if execs and not is_terminal(execs[-1][2].split()[0]):
            err(path,execs[-1][1],f'метод заканчивается нетерминальной инструкцией `{execs[-1][2]}`')
        idx=end+1

# Known fatal typo regression and dangerous APIs.
all_text='\n'.join(p.read_text('utf-8') for p in SMALI_ROOT.rglob('*.smali'))
if '->setContentAccess(Z)V' in all_text: errors.append('FATAL: найден несуществующий WebSettings.setContentAccess')
for bad in ('Landroid/webkit/WebSettings;->setJavaScriptCanOpenWindowsAutomatically(Z)V',):
    if bad in all_text: warnings.append(f'нежелательный API: {bad}')

result={'ok':not errors,'stats':stats,'errors':errors,'warnings':warnings}
(RESULTS/'smali-audit.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),'utf-8')
text=['SMALI_AUDIT_'+('OK' if not errors else 'FAIL'),json.dumps(stats,ensure_ascii=False)]
text += ['ERROR: '+x for x in errors]
text += ['WARNING: '+x for x in warnings]
(RESULTS/'smali-audit.txt').write_text('\n'.join(text)+'\n','utf-8')
print('\n'.join(text))
sys.exit(1 if errors else 0)
