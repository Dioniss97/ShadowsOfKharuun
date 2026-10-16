# Revisión visual — Vigía del Umbral, iteración 06

**Revisión 06 — A04-09:** muñecas más robustas y palmas proporcionadas al agarre, manteniendo holgura en las mangas. La estola conecta con la capucha en el pecho y desciende en dos bandas pétreas hasta el bajo de la túnica, sustituyendo los paños cortos anteriores.

La inscripción aprobada en Q04-07 es el **Código Sith completo, sus seis versos en la versión inglesa original escritos con runas** entre las dos bandas. Se realiza con texto convertido a geometría para incidir la piedra, usando **Sith AF, de Ender Smith/AurekFonts**, fuente de terceros de estilo Kittât Legends bajo [CC BY 3.0 US](https://creativecommons.org/licenses/by/3.0/us/); el OTF y los créditos se conservan en `tools/blender/fonts/`, con procedencia en `ASSETS.md`. Es una transliteración gráfica del inglés, no una traducción a la lengua Sith ni la grafía oficial acreditada del holocrón. Los motivos ornamentales iniciales quedan sustituidos; la composición y legibilidad siguen pendientes de revisión.

**Lectura desde el frente:** versos 1–3 en la banda izquierda, seguidos de 4–6 en la derecha; filas de arriba abajo y letras de izquierda a derecha. Hay hasta cuatro caracteres por fila, contando espacios: 25 filas a la izquierda y 22 a la derecha. La geometría conserva letras y espacios y omite comas y puntos latinos, cuya equivalencia en la fuente no se presupone. El [manifiesto de inscripción](inscription_layout.json) conserva los versos originales con puntuación y su distribución. Los glifos mantienen los contornos de Sith AF, con 74 mm de alto e incisiones de 14 mm; el primer plano de inscripción permite valorar su lectura.

Se mantienen tres materiales y ausencia de emisión. Cada mano sigue siendo una masa continua con dedos juntos y pulgares detrás de la empuñadura. Estos cambios implementados localmente requieren revisión visual humana.

Se conservan la altura y anchura global, el rostro oscuro, la unión de hombros de A04-08, el arma, los codos y la caída de las mangas. La figura conserva la piedra pizarra oscura frente a la hoja/carcasa más claras y los acentos de bronce. La dirección sigue siendo aproximadamente 50 % humanoide / 50 % estatua. La aceptación final y la integración definitiva en el templo necesitan aprobación visual del usuario.

La fuente editable está en [vigia_umbral.blend](../../source/statues/vigia_umbral.blend). Los comandos de generación/exportación y revisión están en [tools/blender/README.md](../../../tools/blender/README.md). La imagen externa del usuario se usa como guía de la conversación y no se redistribuye.

## Renders Blender

El generador produce diez renders del mismo modelo con Cycles en Blender 5.2.2 LTS: cinco vistas generales y cinco detalles. La revisión requiere comparar el frontal con el encuadre anterior, los tres cuartos, ambos hombros, el agarre, la estola y el acercamiento a la inscripción, valorando también la continuidad tridimensional. No son capturas del nivel ni imágenes conceptuales que sustituyan la geometría real.

**Evidencia de la revisión 06, 16-10-2026:** diez renders Cycles y siete capturas reales de Godot a 960×1200. La fuente conserva 19 piezas editables; el [informe geométrico](geometry_review.json) registra cuerpo y ambas manos como componentes únicos cerrados, sin bordes abiertos/no manifold, y los vértices y transformaciones del arma/pedestal idénticos a V. Los informes anteriores están archivados en [iterations/05/README.md](iterations/05/README.md).

El GLB VI contiene 177.133 triángulos, 88.597 vértices, tres materiales y nueve imágenes PBR incrustadas; ocupa 18.373.136 bytes. SHA-256: `d0a5b70144f9446780b8c375ef2b5adc8e674cc2f4b621a39d45005ca60f6999`, idéntico en exportación e importación Godot. El hash de la fuente coincide entre exportación e inspección geométrica. El texto se ha reconstruido desde las filas del manifiesto para comprobar todas las letras y espacios internos de los seis versos; cada verso comienza en una fila nueva.

| Vista | Archivo |
|---|---|
| Frontal con materiales | [front_materials.png](front_materials.png) |
| Perfil derecho | [profile_right.png](profile_right.png) |
| Tres cuartos | [three_quarter.png](three_quarter.png) |
| Posterior | [back.png](back.png) |
| Silueta plana | [silhouette.png](silhouette.png) |
| Capucha, nuca y hombros | [detail_cowl.png](detail_cowl.png) |
| Ambos hombros y nacimiento de las mangas | [detail_shoulders.png](detail_shoulders.png) |
| Estola y grabados | [detail_stole.png](detail_stole.png) |
| Acercamiento para lectura de la inscripción | [detail_inscription.png](detail_inscription.png) |
| Puños y agarre | [detail_hands.png](detail_hands.png) |

## Capturas auténticas de Godot

La revisión 06 genera siete capturas cargando el GLB exportado en un estudio con Godot 4.7.2 Forward+/Vulkan y RX 6600. Importación y ejecución terminan sin errores; el informe registra mapas PBR presentes y ninguna dependencia externa. La cámara frontal situada en +Z muestra el frente de la figura. Las capturas e informes de la revisión 05 son evidencia histórica.

| Evidencia | Archivo |
|---|---|
| Frontal del GLB | [godot_front.png](godot_front.png) |
| Tres cuartos del GLB | [godot_three_quarter.png](godot_three_quarter.png) |
| Detalle de capucha del GLB | [godot_detail_cowl.png](godot_detail_cowl.png) |
| Ambos hombros del GLB | [godot_detail_shoulders.png](godot_detail_shoulders.png) |
| Estola y grabados del GLB | [godot_detail_stole.png](godot_detail_stole.png) |
| Lectura de la inscripción del GLB | [godot_detail_inscription.png](godot_detail_inscription.png) |
| Detalle de puños del GLB | [godot_detail_hands.png](godot_detail_hands.png) |
| Informe de exportación | [export_report.json](export_report.json) |
| Informe de importación y capturas | [godot_import_report.json](godot_import_report.json) |
| Texto, filas y orden de lectura de la inscripción | [inscription_layout.json](inscription_layout.json) |

La iluminación de este estudio es distinta a la de Blender y la del templo. Estas imágenes permiten revisar materiales/orientación; no sustituyen las cuatro vistas de aceptación dentro de la misión ni su QA. La aprobación humana del diseño continúa pendiente.

**Hallazgo técnico abierto ([#26](https://github.com/Dioniss97/ShadowsOfKharuun/issues/26)):** VI conserva pequeños puntos/triángulos oscuros en el render texturizado de GPU que no aparecen en Cycles; son visibles en mangas/manos y complican la lectura del grabado. El GLB carga tres materiales/nueve mapas sin errores; eso no significa que el sombreado esté aceptado. En las revisiones anteriores se comprobaron normales desactivadas, sombras/SSAO, LOD, MSAA, filtrado y compresión de atributos; ninguna de esas pruebas aisladas resolvió el defecto. Los atlas importados analizados no contenían píxeles negros y las UV eran finitas y estaban dentro de 0–1. La causa no se da por identificada; falta corregirla antes de la integración final.

La [frontal inicial](iterations/01/front_materials.png) y los [tres cuartos iniciales](iterations/01/three_quarter.png) se conservan como historial de la revisión rechazada, no como diseño vigente.

La [frontal II](iterations/02/front_materials.png), el [perfil II](iterations/02/profile_right.png) y los [tres cuartos II](iterations/02/three_quarter.png) conservan la base sobre la que se solicitaron A04-05 y las manos continuas. No representan aceptación artística.

La [frontal III](iterations/03/front_materials.png), los [tres cuartos III](iterations/03/three_quarter.png), el [perfil III](iterations/03/profile_right.png) y el [detalle de manos III](iterations/03/detail_hands.png) conservan las proporciones anteriores y el feedback que motiva A04-06/A04-07.

La [frontal IV](iterations/04/front_materials.png), los [tres cuartos IV](iterations/04/three_quarter.png), el [perfil IV](iterations/04/profile_right.png) y el [detalle de manos IV](iterations/04/detail_hands.png) conservan la base de comparación para A04-08, sin implicar aceptación final.

La [frontal V](iterations/05/front_materials.png), los [tres cuartos V](iterations/05/three_quarter.png) y el [detalle de manos V](iterations/05/detail_hands.png) conservan la base de comparación para A04-09. Su [informe geométrico](iterations/05/geometry_review.json) y la [comparación crítica con IV](iterations/05/README.md) pertenecen a aquella revisión.

## Comparación crítica con V

- Las muñecas dejan de parecer tallos estrechos; las palmas crecen moderadamente y mantienen más volumen que la muñeca. Las aberturas siguen siendo mayores que el brazo y conservan caída inferior. Los puños continúan siendo una simplificación tallada; su grado de fuerza y naturalidad requiere valoración humana.
- Las bandas de la estola prolongan los bordes de la capucha hasta el bajo sin seguir ni envolver las mangas. Acompañan la verticalidad también en tres cuartos, conservando la separación del arma y la asimetría previa.
- Los seis versos están completos y ordenados. Las incisiones se leen en el acercamiento Cycles, pero son muy discretas en la vista completa y pierden claridad en Godot. No se registra legibilidad aceptada a distancia de juego.
- El coste exportado pasa de 156.478 a 177.133 triángulos (aproximadamente +13,2 %). Falta evaluar el coste real de ambas instancias durante la integración autorizada posterior.
- La continuidad de hombros, altura, silueta y arma se conservan. La mejora local no equivale a aceptación artística final. Siguen pendientes la aprobación visual del usuario y el defecto GPU de #26.
