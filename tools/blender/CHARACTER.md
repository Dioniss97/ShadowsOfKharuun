# Personaje y vestuario Blender–Godot

## Correcciones tras la auditoría — calidad 12

La [comparativa 14](../../art/references/character/iterations/quality_14/README.md) documenta el último pase regional; la [13](../../art/references/character/iterations/quality_13/README.md) conserva la corrección de agarre y axila, y la [12](../../art/references/character/iterations/quality_12/README.md) sus ajustes de piel, ropa y materiales. `character_surfaces.py` conserva el atlas anatómico CC0 y genera mapas propios de piel de 1024² y UV de tejido con escala física común. Las piezas comparten el nombre `UVMap` antes del join. `human_base.py` construye ribetes desde los bordes de la ropa y los ajusta por proximidad a su superficie con espesor. Las secciones históricas inferiores describen sus respectivos pases.

El correctivo `art/source/characters/grip_contact_fit.json` se aplica en reposo a la mano y al guante después de subdividirlos; el exportador exige correspondencia de al menos el 98% de sus puntos a 0,15 mm. Cambiar anatomía, pesos o pose exige revisar el contacto. Rotaciones locales de dedos/muñecas componen reposo por delta; marco del arma calibrado respecto a la mano, flexiones distintas por dedo y oposición del pulgar. Es un agarre concreto, no un solucionador para cualquier arma.

`scripts/character_materials.gd` aplica recetas explícitas compartidas: especular .32 piel, .22 tejido, .30 cuero, normal textil/cuero .65 y SSS de piel .06. No se confía en que los parámetros Blender se traduzcan idénticos a Godot. Se mantiene la paleta propia, sin mapas externos. [Propiedades del material Godot](https://docs.godotengine.org/en/4.7/classes/class_basematerial3d.html).

## Proporciones torso/brazos — calidad 14

`human_base.py` da un poco más de anchura/profundidad al torso con una influencia suavizada por pesos. Los perfiles de `BaseTop` y `UniformTorso` acompañan el cambio; el radio de las piezas `UniformShoulder_*` y `UniformAxilla_*` se reduce para limitar el bulto de la sisa. `KhCharacterRig` acerca los brazos colgantes hasta 0,22 rad y desvanece el ajuste al elevarlos. Comparación antes/después y resultados en [calidad 14](../../art/references/character/iterations/quality_14/README.md). Vestuario 35/40 y misión headless 213/213; misión GPU incompleta en esta ronda.

## Hombros y contacto de sable — calidad 13

`KhCharacterRig` acerca los brazos hasta 0,16 radianes en reposo y desvanece la corrección al elevarlos. `create_character.py` remalla una pieza pequeña bajo cada axila con `UniformJacket`. La calibración de agarre conserva las entradas previas y añade los puntos del GLB anterior a la ronda; si se mueven dedos, muñeca, marco o geometría, repetir capturas y la sonda de `wardrobe_runner.gd`. [Comparativa 13](../../art/references/character/iterations/quality_13/README.md), con pruebas 35/40 de vestuario y 213/238 de misión tanto en caché normal como después de una importación limpia. Acabado humano pendiente.

Requiere la instalación Blender 5.2.2 LTS utilizada para el Vigía. Ejecutar Blender en segundo plano con --python-exit-code 1 --python tools/blender/create_character.py desde el repositorio. El script reconstruye la fuente; guardar aparte ediciones manuales antes de regenerar.

La base anatómica CC0 está fijada en art/source/characters/vendor/makehuman. human_base.py adapta la anatomía y calcula pesos en Blender. create_character.py crea el rig compartido, la ropa base y el uniforme con materiales propios; guarda art/source/characters/adventurer.blend y exporta assets/models/characters/adventurer.glb.

La fuente conserva piezas editables; la exportación reúne copias en cuatro grupos de apariencia. Se conserva la fuente original sin agrupar destructivamente. Godot importa mapas incrustados, con skins nombrados, compresión de vértices desactivada y LOD automático desactivado para no simplificar paneles deformables.

KhCharacterRig conserva los pivotes/reloj de KhRig y traduce sus acciones a poses del Skeleton3D. Las rotaciones locales de reposo se mantienen al aplicar el delta de animación. Se conservan arma derecha, palma izquierda y eventos de daño del combate.

La túnica integra seis paneles sueltos con bordes solapados y una capa posterior. Godot aplica seis cadenas de huesos secundarios al faldón y nueve a la capa, con ocho cápsulas SpringBone ligadas a torso, cintura, brazos superiores y piernas. El cuerpo oculto y el conjunto base se desactivan al equipar; la cabeza permanece y las manos base se sustituyen por guantes. El movimiento usa dinámica secundaria ósea en tiempo real, no un solver por vértice, y las cápsulas SpringBone no son cuerpos de PhysicsServer3D ni garantizan autocolisión completa. La capa tiene hombros fijados al torso, pliegues anchos y borde reforzado; el movimiento y los posibles clipping se revisan con las poses y transiciones reales.

La estructura de hombros mantiene anclada la tela y reserva la deformación para las cadenas del faldón y la espalda. En Blender, el pinning por grupos de vértices, las colisiones y el bake son el flujo de referencia para una simulación de tela offline; no se usa para esta apariencia ejecutada en tiempo real. Se mantiene una silueta legible, pliegues amplios y pocos acentos para conservar la escala visual del Vigía.

Referencias técnicas: [skinning en Blender](https://docs.blender.org/manual/en/latest/animation/armatures/skinning/index.html), [pinning de tela en Blender](https://docs.blender.org/manual/en/5.1/physics/cloth/settings/shape.html), [colisiones de tela en Blender](https://docs.blender.org/api/5.2/bpy.types.ClothCollisionSettings.html), [SpringBoneSimulator3D de Godot](https://docs.godotengine.org/en/4.7/classes/class_springbonesimulator3d.html), [cápsulas SpringBone de Godot](https://docs.godotengine.org/en/4.7/classes/class_springbonecollisioncapsule3d.html), [guía de forma y detalle para personajes de juego](https://www.creativebloq.com/3d/how-to-build-quality-3d-characters-within-the-constraints-of-mobile-game-fidelity) y [licencia de assets MakeHuman](https://static.makehumancommunity.org/about/license.html). El rig compartido mantiene la ropa base y el uniforme coordinados; los colisionadores reducen intersecciones locales, no prueban todos los fotogramas.

## Iteración de hombros y materiales

La revisión de la túnica reduce el volumen de la hombrera, perfila la manga con una transición suave de hombro a antebrazo, estrecha con suavidad la silueta anatómica sobre el hombro y acorta el cuello alto. El tejido y el cuero conservan mapas empaquetados de color y rugosidad de 512²; la piel recibe variación tonal y de rugosidad más tenue. Son cambios procedurales reproducibles, sin mapas externos. Se comparan capturas antes/después con la misma cámara e iluminación. Se priorizan lectura de silueta, articulación y separación material por rugosidad antes de sumar microdetalle, siguiendo la guía de Oleh Bozhko (3D Character Art Team Lead en Plarium): [calidad de personajes 3D con presupuesto de fidelidad](https://www.creativebloq.com/3d/how-to-build-quality-3d-characters-within-the-constraints-of-mobile-game-fidelity). Blender documenta cómo los pesos del modificador de armadura mezclan la influencia de los huesos y cómo la rugosidad controla la respuesta especular del Principled BSDF: [Armature Modifier](https://docs.blender.org/manual/en/latest/modeling/modifiers/deform/armature.html), [Principled BSDF 5.2](https://docs.blender.org/manual/en/5.2/render/shader_nodes/shader/principled.html).

Revisión: ejecutar Godot --path . --script res://tools/blender/preview_character.gd para capturas GPU del estudio. Para entradas y flujo integrado, usar --script res://tests/wardrobe_runner.gd; añadir -- --wardrobe-capture con GPU para capturar inventario y templo. No usar el argumento genérico --capture: pertenece a la suite histórica y activa otro runner desde main.

## Manos y muñecas — pase regional 04

El rig tiene 76 huesos: los 46 anteriores y 30 articulaciones de dedos. `human_base.py` deriva sus cadenas de los marcadores de la anatomía CC0 y alinea el roll hacia la normal de la palma. La influencia se limita a segmentos de dedos y se suaviza en los bucles existentes. Antes de exportar se conservan cuatro pesos normalizados por vértice.

`HumanHands` es una pieza fuente separada de la cabeza, con subdivisión de un nivel y frontera de antebrazo fijada mediante creases. El GLB conserva los cuatro roles anteriores. La selección de manos usa coordenadas retargeteadas para incluir el pulgar entero; la recesión de piel bajo ropa se limita a vértices dominados por cadera/columna. El warp local desplaza la mano sin la compresión transversal del torso.

`KhCharacterRig` posa los dedos y gira las muñecas para agarre derecho y poder izquierdo. La empuñadura del jugador mide 4 cm de diámetro y sigue la palma del esqueleto; no se añaden acciones ni se modifican sus tiempos. En el pase 04 se conservaban las manos del cuerpo; desde el pase 09, #45 incorpora guantes del uniforme y mantiene las manos descubiertas en la apariencia base.

Capturas regionales: `--script res://tools/blender/preview_detail.gd -- --out=res://art/references/character/iterations/quality_04/after`. La [comparativa 04](../../art/references/character/iterations/quality_04/README.md) documenta fuentes, límites y aceptación pendiente.

## Brazos y codos — pase regional 05

`arm_x` compensa la sección del brazo alrededor de su eje existente, usando pesos anatómicos para proteger el torso y transiciones en muñeca/deltoides. El esqueleto sigue teniendo 76 huesos; los antebrazos existentes ahora flexionan de forma moderada. Espada y marcador de poderes siguen las manos posadas.

La unión de `BodyCovered` y `HumanHands` comparte normales ponderadas por área y muestreo UV XZ para los mapas tenues de piel. Esto corrige el salto de sombreado/tono que producía separar las piezas y desenvolverlas por separado. La proyección no sirve como layout anatómico pintado; si se incorpora uno, debe mantener continuidad en esta frontera. La suite comprueba normales y UV del GLB importado. Capturas con `--region=arm`; [comparativa 05](../../art/references/character/iterations/quality_05/README.md).

## Torso y cobertura — pase regional 06

`human_base.py` genera la camiseta base desde la anatomía con cortes interpolados para escote y sisas, conserva el componente torácico, suaviza el contorno sobre una BVH y transfiere pesos baricéntricos antes de dar espesor. La recesión de piel cubierta usa esos mismos campos con transición gradual; sustituye la compresión rectangular anterior. La fuente anatómica completa permanece como referencia oculta.

La unión del cuello conserva anchura y comparte normales/UV entre roles. La cabeza baja 2,5 cm sin cambiar su forma; su clasificación usa pesos de hueso para conservar mandíbula y cuello al ocultar el cuerpo bajo el uniforme. Para revisar frontal, espalda y acciones: `--region=torso`; [comparativa 06](../../art/references/character/iterations/quality_06/README.md).

## Piernas y apoyo — pase regional 07

`leg_x` conserva el eje y recupera sección de piernas, con transición hacia cadera/pie. El calzado base usa menor huella y un solape de tobillo; el pie interior queda oculto y la piel cubierta se retrae. El borde superior sigue la espinilla y la suela el hueso del pie. La contrapose de tobillo mantiene la orientación de la suela durante la zancada existente; no es un sistema de colocación IK ni garantiza contacto con el suelo.

`--region=leg` añade poses de andar, correr, giro y derrota. La [comparativa 07](../../art/references/character/iterations/quality_07/README.md) conserva 62 vistas por versión. La suite de vestuario comprueba la compensación durante movimiento real.

## Ropa base continua — pase regional 08

Los shorts usan el mismo generador anatómico de prendas que la camiseta, con holgura y espesor propios. Cintura y dobladillos tienen contornos interpolados y pesos transferidos; los dos dobladillos se conservan como dos componentes de una pieza editable. La pelvis y el muslo completos quedan debajo, con recesión gradual de la piel cubierta. Se eliminan las antiguas piezas de shorts que se atravesaban y sus aros separados del cuerpo.

El GLB conserva los cuatro roles de apariencia. [Comparativa 08](../../art/references/character/iterations/quality_08/README.md), con capturas de reposo, zancada, carrera y derrota.

## Uniforme completo y guantes — pase regional 09

Chaqueta con mangas, cuello, pantalón y cinturón se generan sobre la anatomía con holguras propias. Los guantes derivan de las manos, comparten sus treinta articulaciones y alisan detalles pequeños antes de subdividir. `HeadVisible` conserva cabeza/cuello; `BaseOutfit` incluye manos descubiertas y ropa base; `UniformOutfit` reúne todas las prendas del uniforme, guantes incluidos. Se mantienen cuatro roles y 76 huesos.

Solapas y hebilla se ajustan por proyección y transferencia de pesos. Las dos capas de las solapas se desplazan juntas para conservar espesor; en el cruce se separan ligeramente. Los paneles del faldón se ajustan al cinturón, y el borde superior de la capa y su cierre al dorso de la chaqueta. Los puños tienen vuelta geométrica y las botas cubren el bajo del pantalón. La paleta conserva grafito/pizarra, cuero y bronce contenido.

[Comparativa 09](../../art/references/character/iterations/quality_09/README.md): torso y guantes con idénticas cámaras antes/después. Las pruebas inspeccionan pesos reales de dedos en ambas apariencias y continuidad de la piel base.

Tejido y cuero incorporan normales tangentes originales de 512², con intensidad tenue, además de color/rugosidad. La piel conserva sus mapas anteriores. El importado se comprueba en Godot: material con normal activa, textura real y tangentes de malla; no basta con que el nodo exista en Blender.

## Dinámica y cobertura — pase regional 10

La capa fija su primera fila a `spine`, compartiendo anclaje con el cierre; un fade suave de unos 22 cm conecta con las nueve cadenas. Los pesos importados se inspeccionan en Godot. El bajo tiene holgura posterior y las cadenas siguen su caída: corrige el faldón visible a través de la capa al detenerse. Se mantienen las quince cadenas totales y ocho cápsulas, sin añadir un solver ni colisión entre prendas.

`preview_motion.gd` registra cuarenta vistas por versión en una trayectoria controlada: reposo, andar, carrera, giro de 180°, guardia, ataque, poder y asentamiento. Usa las acciones de producción y traslada la raíz; no simula entradas del jugador. `wardrobe_runner.gd` cubre por separado el controlador real. Las poses finales de SpringBone deben muestrearse en `modification_processed`, ya que `animate` vuelve a escribir la pose anterior al modificador. [Comparativa 10](../../art/references/character/iterations/quality_10/README.md).

## Capturas integradas y reproducción final

`--script res://tools/blender/preview_temple.gd` captura ambas apariencias con la cámara del jugador, una cámara cercana y una vista junto al Vigía existente. Solo fija posiciones y cámaras en la escena real; no altera iluminación, materiales ni escala de la estatua. Su informe identifica la colocación y el alcance, que no equivale a una partida humana.

Para repetir comprobaciones: `--headless --script res://tests/wardrobe_runner.gd --fixed-fps 60`, y con GPU `--script res://tests/wardrobe_runner.gd --fixed-fps 60 -- --wardrobe-capture`. La misión completa usa `--headless --fixed-fps 60 -- --demo-test` o GPU `--fixed-fps 60 -- --demo-capture`. Ejecutar las suites GPU de una en una. La importación limpia copia proyecto, scripts, escenas, assets y tests a un directorio nuevo sin `.godot`, ejecuta `--headless --editor --import --quit` allí y repite ambas suites de vestuario. Se conserva el GLB de esa revisión; regenerar antes cambia la revisión examinada.

La [galería](../../art/references/character/README.md) enlaza hashes, resultados y límites. La aceptación humana de proporciones, materiales, caída de tela y clipping debe registrarse en las issues antes de una entrega estable.
