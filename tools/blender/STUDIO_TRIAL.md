# Prueba de deformación Blender Studio

Ensayo autorizado el 21-10-2026 después de la comparación anatómica. Seguimiento en [#35](https://github.com/Dioniss97/ShadowsOfKharuun/issues/35) y [#48](https://github.com/Dioniss97/ShadowsOfKharuun/issues/48). Examina una posible base de sustitución. La aceptación visual y la adaptación a vestuario/combate se registran por separado.

## Abrir y revisar

Ejecutar `tools/STUDIO_TRIAL.bat` en la rama candidata. Incluye importación previa con Godot 4.7.2. En el worktree de esta máquina está en `C:/proyectos-personales/ShadowsOfKharuun/tools/logs/production-050/tools/STUDIO_TRIAL.bat`.

- Botones: reposo, A-pose original, marcha, giro, agarre y hombro/codo.
- A/D: órbita; W/S: escala de vista; Esc: salir.
- Detalle de mano: acerca la cámara a la mano derecha.
- El modo agarre muestra la pose de sujeción. El mango tiene 38 mm de diámetro. La mano abierta se revisa en reposo.

La marcha es un ciclo de diagnóstico sobre el sitio, con IK de dos huesos para los apoyos. El giro rota el modelo mientras hace ese ciclo. El ensayo no representa el controlador ni las animaciones definitivas de combate. Material mate y máscara oscura de pelvis son ayudas de estudio, no piel ni ropa base terminadas. Las luces no proyectan sombras para evitar que su sesgo o resolución oculten la lectura de la superficie; tampoco se acredita aquí la iluminación de la misión.

## Procedencia y archivos

- **Human Base Meshes v1.4.1**, colección **Body Male - Realistic**, autor **Dan Ulrich**, metadata **CC0**. [Distribución oficial](https://www.blender.org/download/demo-files/#assets) y [ZIP fijado](https://download.blender.org/demo/asset-bundles/human-base-meshes/human-base-meshes-bundle-v1.4.1.zip).
- SHA-256 del ZIP: `811f43accbb31a88266d932f8f5563b2d13586fca0ba2693aad1f5fe582b3515`.
- Se conserva la geometría evaluada a Multires 1, se gira rígidamente y se escala uniformemente a 1,80 m. No hay esculpido permanente para el mango.
- Fuente editable: `art/source/characters/studio_trial/studio_rig_trial.blend`.
- Exportado: `assets/models/characters/studio_trial/studio_rig_trial.glb` y `rig_metadata.json`.
- Rig propio de 53 huesos; pesos térmicos de cuerpo y pesos anatómicos de dedos/pulgar, máximo cuatro influencias normalizadas. Las manos forman parte del cuerpo original.
- Se incluyen los dos ojos originales. No se utiliza el esqueleto anatómico de la biblioteca como si fuera un rig.
- [Evidencia, informes y límites](../../art/references/character/studio_rig_trial/README.md).

## Reproducir

1. Descargar el ZIP oficial, comprobar su hash y extraer en `tools/logs/base-model-comparison/vendor/`. La ruta final esperada es `human-base-meshes-bundle-v1.4.1/human_base_meshes_bundle.blend`. Esa carpeta temporal necesita `.gdignore` en su directorio padre.
2. Con Blender 5.2.2 LTS: `blender --background --factory-startup --python-exit-code 1 --python tools/blender/create_studio_trial.py`.
3. Los ángulos revisados se conservan en `studio_trial_poses.json`. `fit_studio_grip.py` permite recalcularlos por FK/skinning sin modificar la malla. Recalcular requiere volver a revisar capturas, contacto y forma; una pérdida numérica baja no aprueba el resultado artístico.
4. Importar: `Godot --headless --editor --import --path .`.
5. Comprobar lógica: `Godot --headless --path . --script res://tools/blender/preview_studio_trial.gd -- --verify`.
6. Capturar en GPU: `Godot --path . --script res://tools/blender/preview_studio_trial.gd --resolution 1100x1100`.
7. Capturar visor: añadir `-- --interactive --ui-smoke`.
8. Componer la lámina y GIF de movimiento con `art/references/character/studio_rig_trial/compose_evidence.ps1`.

Los informes registran el hash del GLB, versión del motor y método de render. La sonda aplica los pesos y bind poses del GLB importado a los vértices; comprueba también triángulos recortados contra el cilindro finito del mango. El margen de 0,5 mm es tolerancia geométrica, no prueba de ausencia universal de clipping. No comprueba colisiones entre dedos, guantes, tela, guardia o hoja. Se conservan 21 muestras de interpolación diagnóstica entre mano abierta y cerrada: sus intersecciones se registran por separado y no acreditan una animación de recoger/equipar el sable. El visor usa las poses de reposo y sujeción separadas.
