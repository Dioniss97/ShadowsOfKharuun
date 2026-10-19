# Personaje y vestuario — primera candidata integrada

20-10-2026. Capturas auténticas de Godot 4.7.2, Vulkan Forward+, Radeon RX 6600. La cuarta iteración de calidad corresponde al pase regional de manos [#40](https://github.com/Dioniss97/ShadowsOfKharuun/issues/40), dentro de [#35](https://github.com/Dioniss97/ShadowsOfKharuun/issues/35). El conjunto sigue en revisión para #35–38; el alcance aprobado está en [#34](https://github.com/Dioniss97/ShadowsOfKharuun/issues/34).

## Apariencias

| Sin uniforme equipado | Uniforme completo |
|---|---|
| ![Ropa base](studio/base_three_quarter.png) | ![Uniforme](studio/tunic_three_quarter.png) |

La fuente editable adapta anatomía CC0 de MakeHuman y contiene ropa, materiales y rig producidos con Blender. El conjunto cambia túnica, prendas inferiores, cinturón y botas. Cabeza y manos se conservan. Al retirarlo reaparece el conjunto base completo, incluido su calzado.

La túnica ahora incluye una capa posterior integrada, sin ranura independiente. Reduce el volumen de los hombros, define pliegues más amplios y conserva un borde interior visible. La captura de caminata desde atrás permite revisar su oscilación dentro de Godot:

| Reposo | En movimiento |
|---|---|
| ![Capa posterior en reposo](studio/tunic_back.png) | ![Capa posterior durante la caminata](studio/tunic_back_walk.png) |

| Vista integrada base | Vista integrada uniforme |
|---|---|
| ![Base en templo](integration/temple_base.png) | ![Uniforme en templo](integration/temple_uniform.png) |

Estas vistas del templo congelan la posición y usan una cámara de inspección dentro del nivel real. Las vistas de `studio/` son del GLB en un estudio de Godot, a 960×1200. Hay frontal, posterior, tres cuartos, andar y gesto de poder para ambas apariencias. No son renders Blender ni imágenes generadas.

## Iteración de calidad 03

La anatomía reduce la anchura exterior del hombro de forma gradual; la túnica integra hombreras menos abultadas, mangas con transición de volumen hasta el puño y un cuello algo más bajo. Los materiales generados ahora llevan mapas empaquetados de color y rugosidad de 512²: variación moderada para la tela y el cuero, más tenue para la piel. La paleta de la túnica se aclaró para hacer legibles sus paneles bajo la iluminación del nivel. El objetivo fue mejorar la lectura de silueta, articulación y materiales antes de sumar microdetalle, siguiendo recomendaciones de profesionales sobre forma, proporción y rugosidad.

| Cuerpo base, antes | Cuerpo base, después |
|---|---|
| ![Cuerpo base antes de la revisión 03](iterations/quality_02/before/base_three_quarter.png) | ![Cuerpo base después de la revisión 03](iterations/quality_02/after/base_three_quarter.png) |

| Uniforme, antes | Uniforme, después |
|---|---|
| ![Uniforme antes de la revisión 03](iterations/quality_02/before/tunic_three_quarter.png) | ![Uniforme después de la revisión 03](iterations/quality_02/after/tunic_three_quarter.png) |

| En el templo, antes | En el templo, después |
|---|---|
| ![Uniforme en el templo antes](iterations/quality_02/before/temple_uniform.png) | ![Uniforme en el templo después](iterations/quality_02/after/temple_uniform.png) |

Esta revisión 03 usó el GLB `e57bad1ffba8b9113f6bea5b5204191a06db86ef8b90c14fe595359356eae352` (5.958.144 bytes, 46 huesos, 45.981 vértices, 90.616 triángulos). Sus comparativas se conservan como historial.

## Iteración de calidad 04 — manos y muñecas

La [comparativa regional](iterations/quality_04/README.md) contiene 42 vistas antes y 42 después con las mismas cámaras e iluminación: reposo, guardia, ataque y poder, ambas apariencias. Las manos conservan mejor su volumen, incorporan 30 articulaciones de dedos y tienen poses de agarre y poder. Se corrigieron el corte del pulgar entre regiones de apariencia y la recesión accidental del antebrazo. La empuñadura del jugador mide 4 cm de diámetro y sigue la palma posada.

GLB actual: `6e016ac872f5398e4fd532b65f17705d94d54e1fe03cc93ed49c82aef6739623` (6.701.868 bytes, 76 huesos, 56.329 vértices, 111.472 triángulos). Vestuario: 26 comprobaciones headless y 30 GPU, cero fallos. Importación con caché vacía: 26/0. La aceptación artística y la revisión humana de clipping continúan pendientes.

## Inventario

![Inventario equipado](integration/inventory_uniform.png)

Se abre con I durante la partida; Equipar/Retirar cambia a la vez el personaje real y la vista 3D. I, ESC o Volver cierran. El juego se pausa y conserva la pausa táctica anterior. Las capturas del inventario son de la UI real a 1280×720.

## Evidencia técnica

- [Exportación](export_report.json): hash del GLB, 4 grupos de apariencia, 44 piezas editables, 76 huesos y geometría total de ambas apariencias. Este total no equivale a todos los triángulos visibles simultáneamente.
- [Prueba de entradas sin render](integration/logic_report.json): 26 comprobaciones, 0 fallos.
- [Prueba con GPU](integration/gpu_report.json): 30 comprobaciones, 0 fallos, capturas y mediciones por vista.
- [Importación limpia](integration/clean_import_report.json): GLB actual con caché `.godot` vacía, 26 comprobaciones, 0 fallos.
- [Estudio](studio/report.json): motor y hash del GLB representado.
- [Regresión](integration/regression_report.json): 213 comprobaciones headless y 238 con GPU; misión, combate, pausas, diálogo, cámara, derrota/reinicio y recorrido automático hasta victoria. Los informes distinguen ejecución automática de QA humana.

Reproducir con [las instrucciones del pipeline](../../../tools/blender/CHARACTER.md). La suite de vestuario usa `--wardrobe-capture`; el argumento `--demo-capture` pertenece a la regresión histórica y debe ejecutarse en otro proceso.

## Coste observado y límites

El GLB ocupa 6,70 MB decimales; su hash y cifras exactas están en el informe de exportación. El informe GPU incluye 30 intervalos de presentación por vista, mediana/p95, llamadas de dibujo, primitivas y memoria de texturas. Son muestras cortas de esta máquina y configuración; incluyen CPU, renderizado y presentación. Las mediciones con inventario incluyen su vista 3D y la escena subyacente; no aíslan el coste exclusivo del personaje ni certifican FPS de otras máquinas.

El faldón y la capa utilizan quince cadenas de huesos secundarios en total y ocho cápsulas SpringBone en torso, cintura, brazos superiores y piernas. La prueba separa 45 pasos en reposo del desplazamiento real; ambas prendas reaccionan y sus poses siguen finitas. Es dinámica secundaria por huesos: no hay solver de tela por vértices, autocolisión completa ni colisión de `PhysicsServer3D`. Las regiones interiores cubiertas se ocultan; los colisionadores reducen penetraciones localmente, pero la cobertura debe seguir revisándose visualmente en acciones y transiciones.

## Revisión artística y jugable

La aceptación humana está pendiente. Deben valorarse anatomía/cabeza, acabado de prendas y materiales frente al Vigía, movimiento del faldón, encuentros de cuello/axilas/cintura/dobladillos y comportamiento al correr, girar, atacar y lanzar poderes. Las formas y texturas de esta primera candidata todavía necesitan esa evaluación; no se declara alcanzada la calidad artística final.

Esta galería conserva evidencia de la candidata. El estado de trabajo y la aceptación se mantienen en GitHub Issues.
