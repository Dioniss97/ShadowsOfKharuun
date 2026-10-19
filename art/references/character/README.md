# Personaje y vestuario — primera candidata integrada

19-10-2026. Capturas auténticas de Godot 4.7.2, Vulkan Forward+, Radeon RX 6600. Se presenta la primera implementación para revisión de [#35](https://github.com/Dioniss97/ShadowsOfKharuun/issues/35), [#36](https://github.com/Dioniss97/ShadowsOfKharuun/issues/36), [#37](https://github.com/Dioniss97/ShadowsOfKharuun/issues/37) y [#38](https://github.com/Dioniss97/ShadowsOfKharuun/issues/38). El alcance aprobado está en [#34](https://github.com/Dioniss97/ShadowsOfKharuun/issues/34).

## Apariencias

| Sin uniforme equipado | Uniforme completo |
|---|---|
| ![Ropa base](studio/base_three_quarter.png) | ![Uniforme](studio/tunic_three_quarter.png) |

La fuente editable adapta anatomía CC0 de MakeHuman y contiene ropa, materiales y rig producidos con Blender. El conjunto cambia túnica, prendas inferiores, cinturón y botas. Cabeza y manos se conservan. Al retirarlo reaparece el conjunto base completo, incluido su calzado.

| Vista integrada base | Vista integrada uniforme |
|---|---|
| ![Base en templo](integration/temple_base.png) | ![Uniforme en templo](integration/temple_uniform.png) |

Estas vistas del templo congelan la posición y usan una cámara de inspección dentro del nivel real. Las vistas de `studio/` son del GLB en un estudio de Godot, a 960×1200. Hay frontal, posterior, tres cuartos, andar y gesto de poder para ambas apariencias. No son renders Blender ni imágenes generadas.

## Inventario

![Inventario equipado](integration/inventory_uniform.png)

Se abre con I durante la partida; Equipar/Retirar cambia a la vez el personaje real y la vista 3D. I, ESC o Volver cierran. El juego se pausa y conserva la pausa táctica anterior. Las capturas del inventario son de la UI real a 1280×720.

## Evidencia técnica

- [Exportación](export_report.json): hash del GLB, 4 grupos de apariencia, 40 piezas editables, 28 huesos y geometría total de ambas apariencias. Este total no equivale a todos los triángulos visibles simultáneamente.
- [Prueba de entradas sin render](integration/logic_report.json): 20 comprobaciones, 0 fallos.
- [Prueba con GPU](integration/gpu_report.json): 24 comprobaciones, 0 fallos, capturas y mediciones por vista.
- [Importación limpia](integration/clean_import_report.json): copia de scripts/escenas/assets/tests sin caché `.godot`, importación del editor y las mismas 20 comprobaciones, 0 fallos.
- [Estudio](studio/report.json): motor y hash del GLB representado.
- [Regresión](integration/regression_report.json): misión, combate, pausas, diálogo, cámara, derrota/reinicio y recorrido automático hasta victoria. Los informes distinguen ejecución automática de QA humana.

Reproducir con [las instrucciones del pipeline](../../../tools/blender/CHARACTER.md). La suite de vestuario usa `--wardrobe-capture`; el argumento `--demo-capture` pertenece a la regresión histórica y debe ejecutarse en otro proceso.

## Coste observado y límites

El GLB ocupa aproximadamente 4,55 MB; su hash y cifras exactas están en el informe de exportación. El informe GPU incluye 30 intervalos de presentación por vista, mediana/p95, llamadas de dibujo, primitivas y memoria de texturas. Son muestras cortas de esta máquina y configuración; incluyen CPU, renderizado y presentación. Las mediciones con inventario incluyen su vista 3D y la escena subyacente; no aíslan el coste exclusivo del personaje ni certifican FPS de otras máquinas.

El faldón utiliza seis cadenas de huesos secundarios y cuatro cápsulas de colisión. La prueba confirma movimiento y poses finitas; no certifica autocolisión de toda la tela ni ausencia de penetraciones en cada transición. Las regiones interiores cubiertas se ocultan para evitar que el cuerpo sobresalga del uniforme.

## Revisión artística y jugable

La aceptación humana está pendiente. Deben valorarse anatomía/cabeza, acabado de prendas y materiales frente al Vigía, movimiento del faldón, encuentros de cuello/axilas/cintura/dobladillos y comportamiento al correr, girar, atacar y lanzar poderes. Las formas y texturas de esta primera candidata todavía necesitan esa evaluación; no se declara alcanzada la calidad artística final.

Esta galería conserva evidencia de la candidata. El estado de trabajo y la aceptación se mantienen en GitHub Issues.
