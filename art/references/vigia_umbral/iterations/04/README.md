# Revisión visual — Vigía del Umbral, iteración 04

La segunda iteración se acercó a la referencia, pero no obtuvo aceptación final. El usuario pidió más amenaza, continuidad en nuca/cuello, hombros y codos, manos con fuerza y una vibroespada más estrecha y mecánica. La tercera fusiona capucha, caída posterior, túnica y mangas; retira el rostro ovoide y conserva una cavidad. Por petición expresa del usuario, cada mano es un puño continuo con dedos juntos y surcos superficiales. La presencia amenazante y la calidad de estos cambios siguen pendientes de revisión humana. El 50/50 estatua/humanoide permanece como alternativa, sin declararlo elegido.

Correcciones incorporadas durante esta revisión: los pulgares pasan detrás de la empuñadura, sin cruzar los índices por delante; la piedra de la figura se oscurece hacia pizarra y la hoja/carcasa permanecen más claras para separar la vibroespada del fondo.

**Revisión 04 — A04-06/A04-07:** figura más estrecha a la misma altura y sobre el mismo pedestal; manto continuo de hombros a capucha; mangas más amplias con abertura y tela que cae por debajo de la muñeca. El brazo derecho anatómico (izquierda en frontal) tiene un solo codo y un antebrazo más directo. La empuñadura baja y la hoja se acorta manteniendo la punta junto al pedestal. Los puños conservan dedos juntos, pero su contorno se afina hacia la muñeca y se ensancha en los nudillos; son más pequeños y se unen a muñecas que entran en las mangas. Estos son cambios implementados para revisar, no aprobación artística.

La fuente editable está en [vigia_umbral.blend](../../source/statues/vigia_umbral.blend). Los comandos de generación/exportación y revisión están en [tools/blender/README.md](../../../tools/blender/README.md). La imagen externa del usuario se usa como guía de la conversación y no se redistribuye.

## Renders Blender

Las cinco vistas generales y los dos detalles muestran el mismo modelo y proceden de Cycles en Blender 5.2.2 LTS. No son capturas del nivel ni imágenes conceptuales que sustituyan la geometría real.

| Vista | Archivo |
|---|---|
| Frontal con materiales | [front_materials.png](front_materials.png) |
| Perfil derecho | [profile_right.png](profile_right.png) |
| Tres cuartos | [three_quarter.png](three_quarter.png) |
| Posterior | [back.png](back.png) |
| Silueta plana | [silhouette.png](silhouette.png) |
| Capucha, nuca y hombros | [detail_cowl.png](detail_cowl.png) |
| Puños y agarre | [detail_hands.png](detail_hands.png) |

## Capturas auténticas de Godot

Se obtienen cargando el GLB exportado en un estudio de revisión con Godot 4.7.2 Forward+/Vulkan. Los tres materiales tienen mapas incrustados de color, rugosidad y normal. La cámara frontal situada en +Z muestra el frente de la figura.

| Evidencia | Archivo |
|---|---|
| Frontal del GLB | [godot_front.png](godot_front.png) |
| Tres cuartos del GLB | [godot_three_quarter.png](godot_three_quarter.png) |
| Detalle de capucha del GLB | [godot_detail_cowl.png](godot_detail_cowl.png) |
| Detalle de puños del GLB | [godot_detail_hands.png](godot_detail_hands.png) |
| Informe de exportación | [export_report.json](export_report.json) |
| Informe de importación y capturas | [godot_import_report.json](godot_import_report.json) |

La iluminación de este estudio es distinta a la de Blender y la del templo. Estas imágenes permiten revisar materiales/orientación; no sustituyen las cuatro vistas de aceptación dentro de la misión ni su QA. La aprobación humana del diseño continúa pendiente.

**Hallazgo técnico abierto ([#26](https://github.com/Dioniss97/ShadowsOfKharuun/issues/26)):** en el render texturizado de GPU persisten pequeños puntos/triángulos oscuros que no aparecen en Cycles. El GLB carga sus tres materiales/nueve mapas sin errores; eso no significa que su sombreado esté aceptado. Se comprobaron normales desactivadas, sombras/SSAO, LOD, MSAA, filtrado y compresión de atributos; ninguna de esas pruebas aisladas resuelve el defecto. Los atlas importados no contienen píxeles negros y las UV del GLB son finitas y están dentro de 0–1. La causa no se da por identificada; falta corregirla antes de la integración final.

La [frontal inicial](iterations/01/front_materials.png) y los [tres cuartos iniciales](iterations/01/three_quarter.png) se conservan como historial de la revisión rechazada, no como diseño vigente.

La [frontal II](iterations/02/front_materials.png), el [perfil II](iterations/02/profile_right.png) y los [tres cuartos II](iterations/02/three_quarter.png) conservan la base sobre la que se solicitaron A04-05 y las manos continuas. No representan aceptación artística.

La [frontal III](iterations/03/front_materials.png), los [tres cuartos III](iterations/03/three_quarter.png), el [perfil III](iterations/03/profile_right.png) y el [detalle de manos III](iterations/03/detail_hands.png) conservan las proporciones anteriores y el feedback que motiva A04-06/A04-07.
