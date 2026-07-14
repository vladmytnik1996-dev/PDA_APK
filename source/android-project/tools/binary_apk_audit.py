#!/usr/bin/env python3
from pathlib import Path
import sys, zipfile, struct, hashlib, json
ROOT=Path(__file__).resolve().parents[1]
try:
    from loguru import logger; logger.remove()
    from androguard.misc import AnalyzeAPK
except Exception as e:
    print('SKIP: androguard unavailable:',e)
    sys.exit(0)

apk=Path(sys.argv[1] if len(sys.argv)>1 else ROOT/'build/outputs/app-debug.apk')
errors=[]; info={}
if not apk.exists():
    print('APK missing',apk); sys.exit(2)
with zipfile.ZipFile(apk) as z:
    names=z.namelist(); info['entries']=len(names)
    if names.count('classes.dex')!=1: errors.append('expected exactly one classes.dex')
    for required in ('AndroidManifest.xml','classes.dex','resources.arsc','assets/www/index.html'):
        if required not in names: errors.append('missing '+required)
    # Local header data offset alignment for STORED entries.
    raw=apk.read_bytes()
    bad_align=[]
    for zi in z.infolist():
        if zi.compress_type!=zipfile.ZIP_STORED: continue
        off=zi.header_offset
        if raw[off:off+4]!=b'PK\x03\x04': errors.append('bad local header '+zi.filename); continue
        fn,extra=struct.unpack_from('<HH',raw,off+26)
        data_off=off+30+fn+extra
        if data_off%4: bad_align.append((zi.filename,data_off%4))
    if bad_align: errors.append('unaligned stored entries: '+repr(bad_align))
    if 'assets/www/index.html' in names:
        info['html_sha256']=hashlib.sha256(z.read('assets/www/index.html')).hexdigest()

a,ds,dx=AnalyzeAPK(str(apk))
info.update(package=a.get_package(),version_code=a.get_androidversion_code(),version_name=a.get_androidversion_name(),dex_count=len(ds),permissions=sorted(a.get_permissions()))
expected_perms=sorted(['android.permission.CAMERA','android.permission.ACCESS_FINE_LOCATION','android.permission.ACCESS_COARSE_LOCATION'])
if info['permissions']!=expected_perms: errors.append(f'permissions mismatch {info["permissions"]}')
if len(ds)!=1: errors.append('dex_count != 1')
classes=[]; method_sigs=set(); external_invokes=[]; handlers=0
for d in ds:
    for c in d.get_classes():
        if not c.get_name().startswith('Lby/smorhon/stalkerpda/'): continue
        classes.append(c.get_name())
        for m in c.get_methods():
            key=(c.get_name(),m.get_name(),m.get_descriptor())
            if key in method_sigs: errors.append('duplicate method '+repr(key))
            method_sigs.add(key)
            code=m.get_code()
            if not code: continue
            ins=[]; off=0
            for i in code.get_bc().get_instructions():
                ins.append((off,i)); off+=i.get_length()
                if i.get_name().startswith('invoke-') and 'Lby/smorhon' not in i.get_output(): external_invokes.append(i.get_output())
            imap={o:i for o,i in ins}
            hs=code.get_handlers()
            if hs is None: continue
            for h in hs.get_list():
                for pair in h.get_handlers():
                    handlers+=1; ho=pair.get_addr()*2
                    hi=imap.get(ho)
                    if not hi or hi.get_name()!='move-exception': errors.append(f'{key}: handler {ho:#x} not move-exception')
                    prev=[x for x in ins if x[0]<ho]
                    if prev:
                        po,pi=prev[-1]; op=pi.get_name()
                        if not (op.startswith('return') or op.startswith('throw') or op.startswith('goto')):
                            errors.append(f'{key}: fallthrough into handler at {ho:#x} from {po:#x} {op}')
info['classes']=sorted(classes); info['methods']=len(method_sigs); info['handlers']=handlers
if any('->setContentAccess(Z)V' in x for x in external_invokes): errors.append('invalid WebSettings.setContentAccess present')
needed=['Landroid/webkit/WebSettings;->setAllowContentAccess(Z)V','Landroid/webkit/WebViewClient;->shouldInterceptRequest']
for n in needed:
    if not any(n in x for x in external_invokes): errors.append('missing expected invoke '+n)
info['ok']=not errors; info['errors']=errors
out=ROOT/'test-results'/('binary-audit-'+apk.stem+'.json')
out.write_text(json.dumps(info,ensure_ascii=False,indent=2),'utf-8')
print(json.dumps(info,ensure_ascii=False,indent=2))
sys.exit(1 if errors else 0)
