# Revisión visual — Vigía del Umbral, iteración 07

**Revisión 07 — A04-10:** la estola ofrece bandas más anchas y planas de frente, con bordes tallados y transición suave a la capucha. Comparte con su borde frontal una piedra varios tonos más oscura que la figura. El Código Sith se talla con glifos mayores y pigmento rojo apagado y desgastado, mate y sin emisión. Se conservan las muñecas y manos de VI, las mangas, el arma, la silueta y el pedestal.

La inscripción aprobada en Q04-07 es el **Código Sith completo, sus seis versos en la versión inglesa original escritos con runas** entre las dos bandas. Se realiza con texto convertido a geometría para incidir la piedra, usando **Sith AF, de Ender Smith/AurekFonts**, fuente de terceros de estilo Kittât Legends bajo [CC BY 3.0 US](https://creativecommons.org/licenses/by/3.0/us/); el OTF y los créditos se conservan en `tools/blender/fonts/`, con procedencia en `ASSETS.md`. Es una transliteración gráfica del inglés, no una traducción a la lengua Sith ni la grafía oficial acreditada del holocrón. Los motivos ornamentales iniciales quedan sustituidos; la composición y legibilidad siguen pendientes de revisión.

**Lectura desde el frente:** versos 1–3 en la banda izquierda, seguidos de 4–6 en la derecha; filas de arriba abajo y letras de izquierda a derecha. Hay hasta seis caracteres por fila, contando espacios: 17 filas a la izquierda y 15 a la derecha; cada verso comienza una fila nueva. La geometría conserva letras y espacios y omite comas y puntos latinos, cuya equivalencia en la fuente no se presupone. El [manifiesto de inscripción](inscription_layout.json) conserva los versos originales con puntuación y su distribución. Los glifos mantienen los contornos de Sith AF, con 105 mm de alto nominal e incisiones superficiales de 2 mm; el primer plano de inscripción permite valorar su lectura.

Se mantienen tres materiales y ausencia de emisión. Cada mano sigue siendo una masa continua con dedos juntos y pulgares detrás de la empuñadura. Estos cambios implementados localmente requieren revisión visual humana.

Se conservan la altura y anchura global, el rostro oscuro, la unión de hombros de A04-08, el arma, los codos y la caída de las mangas. La figura conserva la piedra pizarra oscura frente a la hoja/carcasa más claras y los acentos de bronce. La dirección sigue siendo aproximadamente 50 % humanoide / 50 % estatua. La aceptación final y la integración definitiva en el templo necesitan aprobación visual del usuario.

La fuente editable está en [vigia_umbral.blend](../../source/statues/vigia_umbral.blend). Los comandos de generación/exportación y revisión están en [tools/blender/README.md](../../../tools/blender/README.md). La imagen externa del usuario se usa como guía de la conversación y no se redistribuye.

## Renders Blender

El generador produce diez renders del mismo modelo con Cycles en Blender 5.2.2 LTS: cinco vistas generales y cinco detalles. La revisión requiere comparar el frontal con el encuadre anterior, los tres cuartos, ambos hombros, el agarre, la estola y el acercamiento a la inscripción, valorando también la continuidad tridimensional. No son capturas del nivel ni imágenes conceptuales que sustituyan la geometría real.

**Evidencia de la revisión 07, 16-10-2026:** diez renders Cycles y siete capturas reales de Godot a 960×1200. La fuente conserva 19 piezas editables; el [informe geométrico](geometry_review.json) registra cuerpo y ambas manos como componentes únicos cerrados, sin bordes abiertos/no manifold. Las otras 18 piezas —incluidas manos, arma y pedestal— conservan vértices y transformaciones de VI. Se midieron seis secciones transversales de estola a tres alturas: variación de profundidad máxima de 1,65 mm, incluyendo el grabado de 2 mm. Los informes anteriores están archivados en [iterations/06/README.md](iterations/06/README.md).

El GLB VII contiene 173.792 triángulos, 86.926 vértices, tres materiales y nueve imágenes PBR incrustadas; ocupa 18.456.084 bytes. SHA-256: `7f7d9de5e04c08254938ec473bbdb6ed27381ab41b89bae1dddf3b79ba22e87d`, idéntico en exportación e importación Godot. El hash de la fuente coincide entre exportación e inspección geométrica. Se comprueba emisión cero y ausencia de máscaras de color sin hornear en el GLB. El texto se ha reconstruido desde las filas del manifiesto para comprobar todas las letras y espacios internos de los seis versos; cada verso comienza en una fila nueva.

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

La revisión 07 genera siete capturas cargando el GLB exportado en un estudio con Godot 4.7.2 Forward+/Vulkan y RX 6600. Importación y ejecución terminan sin errores; el informe registra mapas PBR presentes y ninguna dependencia externa. La cámara frontal situada en +Z muestra el frente de la figura. Las capturas e informes de la revisión 06 son evidencia histórica.

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

**Hallazgo técnico abierto ([#26](https://github.com/Dioniss97/ShadowsOfKharuun/issues/26)):** VII conserva pequeños puntos/triángulos oscuros en el render texturizado de GPU, visibles en zonas de mangas/manos. El GLB carga tres materiales/nueve mapas sin errores; eso no significa que el sombreado esté aceptado. En las revisiones anteriores se comprobaron normales desactivadas, sombras/SSAO, LOD, MSAA, filtrado y compresión de atributos; ninguna de esas pruebas aisladas resolvió el defecto. Los atlas importados analizados no contenían píxeles negros y las UV eran finitas y estaban dentro de 0–1. La causa de ese hallazgo no se da por identificada; falta corregirla antes de la integración final. La pérdida de pigmento de letras en el primer horneado VII se corrigió por separado con proyecciones UV continuas de la estola.

La [frontal inicial](iterations/01/front_materials.png) y los [tres cuartos iniciales](iterations/01/three_quarter.png) se conservan como historial de la revisión rechazada, no como diseño vigente.

La [frontal II](iterations/02/front_materials.png), el [perfil II](iterations/02/profile_right.png) y los [tres cuartos II](iterations/02/three_quarter.png) conservan la base sobre la que se solicitaron A04-05 y las manos continuas. No representan aceptación artística.

La [frontal III](iterations/03/front_materials.png), los [tres cuartos III](iterations/03/three_quarter.png), el [perfil III](iterations/03/profile_right.png) y el [detalle de manos III](iterations/03/detail_hands.png) conservan las proporciones anteriores y el feedback que motiva A04-06/A04-07.

La [frontal IV](iterations/04/front_materials.png), los [tres cuartos IV](iterations/04/three_quarter.png), el [perfil IV](iterations/04/profile_right.png) y el [detalle de manos IV](iterations/04/detail_hands.png) conservan la base de comparación para A04-08, sin implicar aceptación final.

La [frontal V](iterations/05/front_materials.png), los [tres cuartos V](iterations/05/three_quarter.png) y el [detalle de manos V](iterations/05/detail_hands.png) conservan la base de comparación para A04-09. Su [informe geométrico](iterations/05/geometry_review.json) y la [comparación crítica con IV](iterations/05/README.md) pertenecen a aquella revisión.

La [frontal VI](iterations/06/front_materials.png), los [tres cuartos VI](iterations/06/three_quarter.png), la [estola VI](iterations/06/detail_stole.png) y el [grabado VI](iterations/06/detail_inscription.png) conservan la base anterior a A04-10 y sus informes. No representan aprobación final.

## Comparación crítica con VI

La [última búsqueda de retoques sobre VII](review_07/README.md) distingue defectos comprobados y propuestas de intervención local. Incluye vistas neutras de inspección; no constituye una nueva iteración ni aprobación final.

- La zona de escritura deja de envolver el volumen redondo de la túnica: ofrece un frente transversal plano más ancho, con bordes tallados y adaptación longitudinal. La transición superior conserva la curvatura previa; el volumen se cierra hacia el interior sin salientes de Solidify.
- Estola y borde frontal de la capucha usan el mismo oscurecimiento de piedra; la iluminación provoca variaciones visibles entre sus planos. La piedra conserva porosidad y rugosidad, sin apariencia de tela teñida o banda brillante.
- El pigmento rojo y los glifos nominalmente un 42 % mayores permiten distinguir la inscripción en el frontal completo de Cycles. La banda en sombra se lee menos que la iluminada; el detalle cercano sigue siendo la mejor vista para revisar letras y desgaste. No se registra aceptación de lectura a distancia de juego.
- La profundidad pasa de 14 a 2 mm: las ranuras anteriores eran demasiado profundas respecto al grosor de los trazos y ocultaban el pigmento en Cycles. La revisión utiliza un grabado superficial pintado, mate y sin emisión.
- El primer horneado perdía pigmento en letras enteras por sus islas UV estrechas. Dos proyecciones continuas dentro del mismo atlas de piedra corrigen esa pérdida y conservan el rojo en la captura Godot. No se aumenta el tamaño de las texturas; el resto de piedra dispone de menos anchura UV. Se mantiene la revisión visual del microrelieve del conjunto.
- El coste geométrico pasa de 177.133 a 173.792 triángulos, aproximadamente un 1,9 % menos. Falta medir el coste real de las dos instancias y sus materiales dentro del templo.
- Se conservan agarre, manos, muñecas, arma, pedestal, altura y orientación de hombros. La mejora local no equivale a aceptación artística final; siguen pendientes la revisión humana, el defecto GPU de #26 y la QA posterior en el templo.
