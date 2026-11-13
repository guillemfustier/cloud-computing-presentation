# Ensambla la presentación autocontenida: plantilla + three.js + fuentes + robots Unitree.
from pathlib import Path
here = Path(__file__).resolve().parent
v = here / 'vendor'
tpl = (here / 'template.html').read_text(encoding='utf-8')
out = (tpl.replace('/*@@FONTS@@*/', (v / 'fonts.inline.css').read_text(encoding='utf-8'))
          .replace('/*@@THREE@@*/', (v / 'three.min.js').read_text(encoding='utf-8'))
          .replace('/*@@ROBOTS@@*/', (v / 'robots.json').read_text(encoding='utf-8')))
dst = here.parent / 'PRESENTACION.html'
dst.write_text(out, encoding='utf-8')
print(dst, round(dst.stat().st_size / 1e6, 2), 'MB')
