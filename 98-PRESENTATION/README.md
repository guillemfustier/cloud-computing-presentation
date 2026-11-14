# Seminar presentation

`PRESENTACION.html` is the complete presentation in a single file: open it with a double click, no connection needed.
Navigation: ← → to change slides, F for full screen, Q for quality.

## Speakers

| Speaker | Slides |
|---|---|
| Lucía | 1–7 · title, roadmap and NVIDIA cloud infrastructure |
| Matteo | 8–14 · Isaac Sim, Isaac Lab, Launchable, Cosmos |
| Miquel | 15–18 and 20 · alternatives and conclusions |
| Guillem and Jorge | 19 and 21 · live demo and questions |

## Editing

Only `src/template.html` is edited, and the presentation is regenerated with:

```bash
python3 src/build.py
```

`PRESENTACION.html` is generated: do not edit it by hand. The screenshots in `src/img/` (from the NVIDIA Isaac Sim and Isaac Lab documentation) are embedded at build time.
