# Assembles the self-contained presentation: template + three.js + fonts + Unitree robots.
import base64, re
from pathlib import Path
here = Path(__file__).resolve().parent
v = here / 'vendor'
tpl = (here / 'template.html').read_text(encoding='utf-8')
out = (tpl.replace('/*@@FONTS@@*/', (v / 'fonts.inline.css').read_text(encoding='utf-8'))
          .replace('/*@@THREE@@*/', (v / 'three.min.js').read_text(encoding='utf-8'))
          .replace('/*@@ROBOTS@@*/', (v / 'robots.json').read_text(encoding='utf-8')))
# screenshots from img/ embedded as data URIs: @@IMG:name@@ -> img/name.jpg
out = re.sub(r'@@IMG:([\w-]+)@@', lambda m: 'data:image/jpeg;base64,' + base64.b64encode((here / 'img' / (m.group(1) + '.jpg')).read_bytes()).decode(), out)
dst = here.parent / 'PRESENTACION.html'
dst.write_text(out, encoding='utf-8')
print(dst, round(dst.stat().st_size / 1e6, 2), 'MB')
