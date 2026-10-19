# Personaje y vestuario Blender–Godot

Requiere la instalación Blender 5.2.2 LTS utilizada para el Vigía. Ejecutar Blender en segundo plano con --python-exit-code 1 --python tools/blender/create_character.py desde el repositorio. El script reconstruye la fuente; guardar aparte ediciones manuales antes de regenerar.

La base anatómica CC0 está fijada en art/source/characters/vendor/makehuman. human_base.py adapta la anatomía y calcula pesos en Blender. create_character.py crea el rig compartido, la ropa base y el uniforme con materiales propios; guarda art/source/characters/adventurer.blend y exporta assets/models/characters/adventurer.glb.

La fuente conserva piezas editables; la exportación reúne copias en cuatro grupos de apariencia. Se conserva la fuente original sin agrupar destructivamente. Godot importa mapas incrustados, con skins nombrados, compresión de vértices desactivada y LOD automático desactivado para no simplificar paneles deformables.

KhCharacterRig conserva los pivotes/reloj de KhRig y traduce sus acciones a poses del Skeleton3D. Las rotaciones locales de reposo se mantienen al aplicar el delta de animación. Se conservan arma derecha, palma izquierda y eventos de daño del combate.

La túnica integra seis paneles sueltos con bordes solapados y una capa posterior. Godot aplica seis cadenas de huesos secundarios al faldón y nueve a la capa, con ocho cápsulas SpringBone ligadas a torso, cintura, brazos superiores y piernas. El cuerpo oculto bajo la chaqueta/pantalón se desactiva al equipar el conjunto; cabeza y manos se conservan. El movimiento usa dinámica secundaria ósea en tiempo real, no un solver por vértice, y las cápsulas SpringBone no son cuerpos de PhysicsServer3D ni garantizan autocolisión completa. La capa tiene hombros fijados al torso, pliegues anchos y borde reforzado; el movimiento y los posibles clipping se revisan con las poses y transiciones reales.

La estructura de hombros mantiene anclada la tela y reserva la deformación para las cadenas del faldón y la espalda. En Blender, el pinning por grupos de vértices, las colisiones y el bake son el flujo de referencia para una simulación de tela offline; no se usa para esta apariencia ejecutada en tiempo real. Se mantiene una silueta legible, pliegues amplios y pocos acentos para conservar la escala visual del Vigía.

Referencias técnicas: [skinning en Blender](https://docs.blender.org/manual/en/latest/animation/armatures/skinning/index.html), [pinning de tela en Blender](https://docs.blender.org/manual/en/5.1/physics/cloth/settings/shape.html), [colisiones de tela en Blender](https://docs.blender.org/api/5.2/bpy.types.ClothCollisionSettings.html), [SpringBoneSimulator3D de Godot](https://docs.godotengine.org/en/4.7/classes/class_springbonesimulator3d.html), [cápsulas SpringBone de Godot](https://docs.godotengine.org/en/4.7/classes/class_springbonecollisioncapsule3d.html), [guía de forma y detalle para personajes de juego](https://www.creativebloq.com/3d/how-to-build-quality-3d-characters-within-the-constraints-of-mobile-game-fidelity) y [licencia de assets MakeHuman](https://static.makehumancommunity.org/about/license.html). El rig compartido mantiene la ropa base y el uniforme coordinados; los colisionadores reducen intersecciones locales, no prueban todos los fotogramas.

## Iteración de hombros y materiales

La revisión de la túnica reduce el volumen de la hombrera, perfila la manga con una transición suave de hombro a antebrazo, estrecha con suavidad la silueta anatómica sobre el hombro y acorta el cuello alto. El tejido y el cuero conservan mapas empaquetados de color y rugosidad de 512²; la piel recibe variación tonal y de rugosidad más tenue. Son cambios procedurales reproducibles, sin mapas externos. Se comparan capturas antes/después con la misma cámara e iluminación. Se priorizan lectura de silueta, articulación y separación material por rugosidad antes de sumar microdetalle, siguiendo la guía de Oleh Bozhko (3D Character Art Team Lead en Plarium): [calidad de personajes 3D con presupuesto de fidelidad](https://www.creativebloq.com/3d/how-to-build-quality-3d-characters-within-the-constraints-of-mobile-game-fidelity). Blender documenta cómo los pesos del modificador de armadura mezclan la influencia de los huesos y cómo la rugosidad controla la respuesta especular del Principled BSDF: [Armature Modifier](https://docs.blender.org/manual/en/latest/modeling/modifiers/deform/armature.html), [Principled BSDF 5.2](https://docs.blender.org/manual/en/5.2/render/shader_nodes/shader/principled.html).

Revisión: ejecutar Godot --path . --script res://tools/blender/preview_character.gd para capturas GPU del estudio. Para entradas y flujo integrado, usar --script res://tests/wardrobe_runner.gd; añadir -- --wardrobe-capture con GPU para capturar inventario y templo. No usar el argumento genérico --capture: pertenece a la suite histórica y activa otro runner desde main.

## Manos y muñecas — pase regional 04

El rig tiene 76 huesos: los 46 anteriores y 30 articulaciones de dedos. `human_base.py` deriva sus cadenas de los marcadores de la anatomía CC0 y alinea el roll hacia la normal de la palma. La influencia se limita a segmentos de dedos y se suaviza en los bucles existentes. Antes de exportar se conservan cuatro pesos normalizados por vértice.

`HumanHands` es una pieza fuente separada de la cabeza, con subdivisión de un nivel y frontera de antebrazo fijada mediante creases. El GLB conserva los cuatro roles anteriores. La selección de manos usa coordenadas retargeteadas para incluir el pulgar entero; la recesión de piel bajo ropa se limita a vértices dominados por cadera/columna. El warp local desplaza la mano sin la compresión transversal del torso.

`KhCharacterRig` posa los dedos y gira las muñecas para agarre derecho y poder izquierdo. La empuñadura del jugador mide 4 cm de diámetro y sigue la palma del esqueleto; no se añaden acciones ni se modifican sus tiempos. Los guantes completos siguen siendo trabajo de #45: actualmente las manos visibles son las del cuerpo.

Capturas regionales: `--script res://tools/blender/preview_detail.gd -- --out=res://art/references/character/iterations/quality_04/after`. La [comparativa 04](../../art/references/character/iterations/quality_04/README.md) documenta fuentes, límites y aceptación pendiente.

## Brazos y codos — pase regional 05

`arm_x` compensa la sección del brazo alrededor de su eje existente, usando pesos anatómicos para proteger el torso y transiciones en muñeca/deltoides. El esqueleto sigue teniendo 76 huesos; los antebrazos existentes ahora flexionan de forma moderada. Espada y marcador de poderes siguen las manos posadas.

La unión de `BodyCovered` y `HumanHands` comparte normales ponderadas por área y muestreo UV XZ para los mapas tenues de piel. Esto corrige el salto de sombreado/tono que producía separar las piezas y desenvolverlas por separado. La proyección no sirve como layout anatómico pintado; si se incorpora uno, debe mantener continuidad en esta frontera. La suite comprueba normales y UV del GLB importado. Capturas con `--region=arm`; [comparativa 05](../../art/references/character/iterations/quality_05/README.md).
