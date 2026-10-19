# Personaje y vestuario Blender–Godot

Requiere la instalación Blender 5.2.2 LTS utilizada para el Vigía. Ejecutar Blender en segundo plano con --python-exit-code 1 --python tools/blender/create_character.py desde el repositorio. El script reconstruye la fuente; guardar aparte ediciones manuales antes de regenerar.

La base anatómica CC0 está fijada en art/source/characters/vendor/makehuman. human_base.py adapta la anatomía y calcula pesos en Blender. create_character.py crea el rig compartido, la ropa base y el uniforme con materiales propios; guarda art/source/characters/adventurer.blend y exporta assets/models/characters/adventurer.glb.

La fuente conserva piezas editables; la exportación reúne copias en cuatro grupos de apariencia. Se conserva la fuente original sin agrupar destructivamente. Godot importa mapas incrustados, con skins nombrados, compresión de vértices desactivada y LOD automático desactivado para no simplificar paneles deformables.

KhCharacterRig conserva los pivotes/reloj de KhRig y traduce sus acciones a poses del Skeleton3D. Las rotaciones locales de reposo se mantienen al aplicar el delta de animación. Se conservan arma derecha, palma izquierda y eventos de daño del combate.

La túnica usa seis cadenas de huesos secundarios con SpringBoneSimulator3D y cuatro cápsulas vinculadas a piernas. Las regiones interiores se ocultan al equipar el conjunto; el estado de cabeza permanece separado. El movimiento de huesos no equivale a una simulación de tela con autocolisión de toda la prenda.

Referencias técnicas: [skinning en Blender](https://docs.blender.org/manual/en/latest/animation/armatures/skinning/index.html), [SpringBoneSimulator3D de Godot](https://docs.godotengine.org/en/stable/classes/class_springbonesimulator3d.html) y [licencia de assets MakeHuman](https://static.makehumancommunity.org/about/license.html). La ropa comparte rig; los huesos secundarios aportan inercia a sus paneles. La cobertura y los colisionadores se complementan para reducir penetraciones; deben revisarse en las poses reales.

Revisión: ejecutar Godot --path . --script res://tools/blender/preview_character.gd para capturas GPU del estudio. Para entradas y flujo integrado, usar --script res://tests/wardrobe_runner.gd; añadir -- --wardrobe-capture con GPU para capturar inventario y templo. No usar el argumento genérico --capture: pertenece a la suite histórica y activa otro runner desde main.
