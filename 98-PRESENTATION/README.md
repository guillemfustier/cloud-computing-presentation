# Presentación del seminario

`PRESENTACION.html` es la presentación completa en un solo archivo: se abre con doble clic, sin conexión.
Navegación: ← → para pasar diapositivas, F pantalla completa, Q calidad.

## Reparto

| Ponente | Diapositivas |
|---|---|
| Lucía | 1–7 · título, ruta e infraestructura cloud de NVIDIA |
| Matteo | 8–14 · Isaac Sim, Isaac Lab, Launchable, Cosmos |
| Miquel | 15–18 y 20 · alternativas y conclusiones |
| Guillem y Jorge | 19 y 21 · demo en vivo y preguntas |

## Editar

Se edita solo `src/template.html` y se regenera con:

```bash
python3 src/build.py
```

`PRESENTACION.html` es generado: no editarlo a mano. Las capturas de `src/img/` (documentación de NVIDIA Isaac Sim e Isaac Lab) se embeben al compilar.
