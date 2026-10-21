# Prueba Blender Studio: rig, agarre y ropa base

Ensayo autorizado el 21-10-2026 después de comparar bases anatómicas. Se mantiene aislado del personaje de producción. Seguimiento y aceptación humana en [#35](https://github.com/Dioniss97/ShadowsOfKharuun/issues/35), [#40](https://github.com/Dioniss97/ShadowsOfKharuun/issues/40), [#48](https://github.com/Dioniss97/ShadowsOfKharuun/issues/48) y PR #39.

## Abrir y revisar

Ejecutar `tools/STUDIO_TRIAL.bat` dentro de la rama candidata. En esta máquina: `C:/proyectos-personales/ShadowsOfKharuun/tools/logs/production-050/tools/STUDIO_TRIAL.bat`.

- Botones: reposo, A-pose original, marcha, giro, agarre y hombro/codo.
- A/D: órbita; W/S: escala de vista; Esc: salir.
- El detalle de mano centra la cámara en la mano derecha.
- En agarre el mango cilíndrico tiene 38 mm de diámetro. Mano abierta y cerrada son poses diagnósticas separadas.

La marcha es un ciclo en el sitio con IK de dos huesos. No representa locomoción jugable ni animación final de combate. El ciclo abierto/cerrado de agarre mantiene el mango fijo y sirve para inspeccionar las poses; no es una animación de recoger/equipar. El shader mate y la iluminación neutra sirven para leer forma; no son materiales finales ni demuestran el aspecto dentro de la misión.

La candidata contiene un primer ajuste de camiseta, shorts y zapatos cerrados, separados del cuerpo y con pesos al mismo rig. No son el uniforme final: carecen de mapas propios/acabado y los zapatos aún necesitan revisión de silueta y cobertura. No hay física de tela ni validación exhaustiva de intersecciones entre prendas y cuerpo.

## Procedencia y archivos

- **Human Base Meshes v1.4.1**, colección **Body Male - Realistic**, autor **Dan Ulrich**, metadata **CC0**. [Distribución oficial](https://www.blender.org/download/demo-files/#assets) y [ZIP fijado](https://download.blender.org/demo/asset-bundles/human-base-meshes/human-base-meshes-bundle-v1.4.1.zip).
- SHA-256 del ZIP: `811f43accbb31a88266d932f8f5563b2d13586fca0ba2693aad1f5fe582b3515`.
- Se conserva la geometría evaluada a Multires 1, se gira rígidamente y se escala uniformemente a 1,80 m. El mango no esculpe permanentemente el cuerpo.
- Fuente editable: `art/source/characters/studio_trial/studio_rig_trial.blend`.
- Exportación: `assets/models/characters/studio_trial/studio_rig_trial.glb` y `rig_metadata.json`.
- Rig propio de 53 huesos; pesos de cuerpo/manos y prendas normalizados, máximo cuatro influencias. Las manos forman parte de la malla original.
- Se incluyen los dos ojos originales, ligados a cabeza. El esqueleto anatómico de la biblioteca es una malla, no se usa como armature.
- [Capturas, informes y límites](../../art/references/character/studio_rig_trial/README.md).

## Reproducir el proceso

1. Descargar el ZIP oficial, comprobar su hash y extraer en `tools/logs/base-model-comparison/vendor/`. La ruta esperada es `human-base-meshes-bundle-v1.4.1/human_base_meshes_bundle.blend`; la carpeta temporal necesita `.gdignore` en el directorio padre.
2. Con Blender 5.2.2 LTS, ejecutar: `blender --background --factory-startup --python-exit-code 1 --python tools/blender/create_studio_trial.py`.
3. Los ángulos/pose están en `studio_trial_poses.json`. `fit_studio_grip.py` recalcula los ángulos por FK/skinning; después hay que revisar forma, contacto y capturas.
4. Importar con Godot: `Godot --headless --editor --import --path .`.
5. Verificar: `Godot --headless --path . --script res://tools/blender/preview_studio_trial.gd -- --verify`.
6. Para vistas GPU: `Godot --path . --script res://tools/blender/preview_studio_trial.gd --resolution 1100x1100`.
7. Para el visor: añadir `-- --interactive --ui-smoke`.

Los informes registran el hash del GLB, motor y método. La sonda transforma pesos/bind poses del GLB importado y recorta los triángulos contra el cilindro finito del mango. El margen de 0,5 mm es tolerancia geométrica: no prueba ausencia universal de clipping. No comprueba autocolisiones de dedos, guantes, guardia, hoja o ropa. El lote GPU registra 48 vistas, pero hubo errores intermitentes de escritura PNG; usar únicamente los archivos presentes e inspeccionados como evidencia visual.
