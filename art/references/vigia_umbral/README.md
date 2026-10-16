# Revisión visual — Vigía del Umbral, iteración 08

**Revisión 08 — A04-11:** pasada local sobre VII. Se elimina la repisa horizontal del torso dentro de la capucha mediante una transición retraída continua, se regulariza el pequeño pellizco palmar superior junto a la empuñadura y se corrigen los texeles sin muestra que producían motas triangulares en el GLB. Se conservan la silueta, hombros, proporciones de manos/muñecas, arma, pedestal y estola plana oscura con Código Sith rojo desgastado, mate y sin emisión. La [comparación antes/después](review_08/README.md) separa los cambios geométricos del arreglo de horneado.

La inscripción aprobada en Q04-07 es el **Código Sith completo, sus seis versos en la versión inglesa original escritos con runas** entre las dos bandas. Se realiza con texto convertido a geometría para incidir la piedra, usando **Sith AF, de Ender Smith/AurekFonts**, fuente de terceros de estilo Kittât Legends bajo [CC BY 3.0 US](https://creativecommons.org/licenses/by/3.0/us/); el OTF y los créditos se conservan en `tools/blender/fonts/`, con procedencia en `ASSETS.md`. Es una transliteración gráfica del inglés, no una traducción a la lengua Sith ni la grafía oficial acreditada del holocrón. Los motivos ornamentales iniciales quedan sustituidos; la composición y legibilidad siguen pendientes de revisión.

**Lectura desde el frente:** versos 1–3 en la banda izquierda, seguidos de 4–6 en la derecha; filas de arriba abajo y letras de izquierda a derecha. Hay hasta seis caracteres por fila, contando espacios: 17 filas a la izquierda y 15 a la derecha; cada verso comienza una fila nueva. La geometría conserva letras y espacios y omite comas y puntos latinos, cuya equivalencia en la fuente no se presupone. El [manifiesto de inscripción](inscription_layout.json) conserva los versos originales con puntuación y su distribución. Los glifos mantienen los contornos de Sith AF, con 105 mm de alto nominal e incisiones superficiales de 2 mm; el primer plano de inscripción permite valorar su lectura.

Se mantienen tres materiales y ausencia de emisión. Cada mano sigue siendo una masa continua con dedos juntos y pulgares detrás de la empuñadura. El usuario acepta VIII para integrarlo mediante A04-12 (16-10-2026). La [comparación dentro del nivel](integration/README.md) muestra ambas instancias; la aceptación de presentación y la entrega se registran en [QA_0_4_0.md](../../../QA_0_4_0.md).

Se conservan la altura y anchura global, el rostro oscuro, la unión de hombros de A04-08, el arma, los codos y la caída de las mangas. La figura conserva la piedra pizarra oscura frente a la hoja/carcasa más claras y los acentos de bronce. La dirección sigue siendo aproximadamente 50 % humanoide / 50 % estatua. Los informes artísticos conservan sus campos de aceptación al momento de generarse, antes de A04-12; el registro posterior del usuario está en QA.

La fuente editable está en [vigia_umbral.blend](../../source/statues/vigia_umbral.blend). Los comandos de generación/exportación y revisión están en [tools/blender/README.md](../../../tools/blender/README.md). La imagen externa del usuario se usa como guía de la conversación y no se redistribuye.

## Renders Blender

El generador produce diez renders del mismo modelo con Cycles en Blender 5.2.2 LTS: cinco vistas generales y cinco detalles. La revisión requiere comparar el frontal con el encuadre anterior, los tres cuartos, ambos hombros, el agarre, la estola y el acercamiento a la inscripción, valorando también la continuidad tridimensional. No son capturas del nivel ni imágenes conceptuales que sustituyan la geometría real.

**Evidencia de la revisión 08, 16-10-2026:** diez renders Cycles y nueve capturas reales de Godot a 960×1200. La fuente conserva 19 piezas editables; el [informe geométrico](geometry_review.json) registra cuerpo y ambas manos como componentes únicos cerrados, sin bordes abiertos/no manifold. Diecisiete piezas —mano inferior, arma y pedestal— conservan vértices y transformaciones de VII. En 41.148 muestras del cuerpo fuera del interior intervenido, la distancia máxima respecto a VII es 1,70 mm y la media 0,0022 mm tras la fusión/decimación. Las seis secciones transversales de estola conservan un frente plano: variación máxima de 1,67 mm, incluyendo el grabado de 2 mm. Los informes anteriores están archivados en [iterations/07/README.md](iterations/07/README.md).

El GLB VIII contiene 169.352 triángulos, 84.706 vértices, tres materiales y nueve imágenes PBR incrustadas; ocupa 18.214.180 bytes. SHA-256: `192a22bc4f519bbdaa0cb594756344b0b75f055211ae4d128bec1841824b248e`, idéntico en exportación e importación Godot. La fuente tiene SHA-256 `0a51277b706a62154cf82af036694d286300a7a4a1b278f99bcbf8ca4e87dad2`, coincidente entre exportación e inspección geométrica. Se comprueba emisión cero y ausencia de máscaras de color sin hornear en el GLB. El texto se ha reconstruido desde las filas del manifiesto para comprobar todas las letras y espacios internos de los seis versos; cada verso comienza en una fila nueva.

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

La revisión 08 genera nueve capturas cargando el GLB exportado en un estudio con Godot 4.7.2 Forward+/Vulkan y RX 6600. Importación y ejecución terminan sin errores; el informe registra mapas PBR presentes y ninguna dependencia externa. La cámara frontal situada en +Z muestra el frente de la figura. Las capturas e informes de VII son evidencia histórica.

| Evidencia | Archivo |
|---|---|
| Frontal del GLB | [godot_front.png](godot_front.png) |
| Tres cuartos del GLB | [godot_three_quarter.png](godot_three_quarter.png) |
| Perfil derecho del GLB | [godot_profile_right.png](godot_profile_right.png) |
| Posterior del GLB | [godot_back.png](godot_back.png) |
| Detalle de capucha del GLB | [godot_detail_cowl.png](godot_detail_cowl.png) |
| Ambos hombros del GLB | [godot_detail_shoulders.png](godot_detail_shoulders.png) |
| Estola y grabados del GLB | [godot_detail_stole.png](godot_detail_stole.png) |
| Lectura de la inscripción del GLB | [godot_detail_inscription.png](godot_detail_inscription.png) |
| Detalle de puños del GLB | [godot_detail_hands.png](godot_detail_hands.png) |
| Informe de exportación | [export_report.json](export_report.json) |
| Informe de importación y capturas | [godot_import_report.json](godot_import_report.json) |
| Texto, filas y orden de lectura de la inscripción | [inscription_layout.json](inscription_layout.json) |

La iluminación de este estudio es distinta a la de Blender y la del templo. Estas imágenes permiten revisar materiales/orientación; no sustituyen las vistas de aceptación dentro de la misión. La [galería de integración](integration/README.md) aporta ahora esas vistas; su revisión humana se registra por separado.

**Corrección técnica local de [#26](https://github.com/Dioniss97/ShadowsOfKharuun/issues/26):** las motas persistían con color base sin iluminación y desaparecían con material neutro. Las caras UV muy finas sin muestras de horneado retenían un color de reserva lineal escrito directamente en un PNG sRGB; al decodificarse quedaba casi negro. VIII codifica esa reserva correctamente y completa únicamente texeles todavía sin muestra mediante color de superficie vecina compatible con las máscaras de pigmento. Se repararon 44.494 texeles de piedra oscura y 110 de piedra clara, sin ampliar atlas ni añadir materiales. Las nueve vistas finales revisadas ya no muestran las motas negras ni las facetas claras del ensayo intermedio; las runas conservan su pigmento. La [revisión técnica](review_08/README.md) conserva el diagnóstico. La pérdida anterior de pigmento en letras enteras se había corregido en VII mediante UV continuas; era un defecto distinto. La validación en el templo y la aceptación humana siguen pendientes.

La [frontal inicial](iterations/01/front_materials.png) y los [tres cuartos iniciales](iterations/01/three_quarter.png) se conservan como historial de la revisión rechazada, no como diseño vigente.

La [frontal II](iterations/02/front_materials.png), el [perfil II](iterations/02/profile_right.png) y los [tres cuartos II](iterations/02/three_quarter.png) conservan la base sobre la que se solicitaron A04-05 y las manos continuas. No representan aceptación artística.

La [frontal III](iterations/03/front_materials.png), los [tres cuartos III](iterations/03/three_quarter.png), el [perfil III](iterations/03/profile_right.png) y el [detalle de manos III](iterations/03/detail_hands.png) conservan las proporciones anteriores y el feedback que motiva A04-06/A04-07.

La [frontal IV](iterations/04/front_materials.png), los [tres cuartos IV](iterations/04/three_quarter.png), el [perfil IV](iterations/04/profile_right.png) y el [detalle de manos IV](iterations/04/detail_hands.png) conservan la base de comparación para A04-08, sin implicar aceptación final.

La [frontal V](iterations/05/front_materials.png), los [tres cuartos V](iterations/05/three_quarter.png) y el [detalle de manos V](iterations/05/detail_hands.png) conservan la base de comparación para A04-09. Su [informe geométrico](iterations/05/geometry_review.json) y la [comparación crítica con IV](iterations/05/README.md) pertenecen a aquella revisión.

La [frontal VI](iterations/06/front_materials.png), los [tres cuartos VI](iterations/06/three_quarter.png), la [estola VI](iterations/06/detail_stole.png) y el [grabado VI](iterations/06/detail_inscription.png) conservan la base anterior a A04-10 y sus informes. No representan aprobación final.

La [frontal VII](iterations/07/front_materials.png), los [tres cuartos VII](iterations/07/three_quarter.png), la [capucha VII](iterations/07/detail_cowl.png) y las [manos VII](iterations/07/detail_hands.png) conservan la base de esta pasada A04-11 y sus informes. No representan aprobación final.

## Comparación crítica con VII

La [búsqueda de retoques VII](review_07/README.md) es el diagnóstico histórico que motivó A04-11. La [comparación VIII](review_08/README.md) recoge la intervención implementada y vistas antes/después.

- El torso deja de terminar con una tapa horizontal visible dentro de la capucha. Se estrecha y retrae gradualmente hasta quedar detrás de la cavidad. El perfil central muestreado cada 2 cm pasa de un salto máximo de 75,1 a 3,16 cm; el render neutro frontal y oblicuo permite comprobar la continuidad sin depender de la sombra.
- La unión palmar superior se fusiona antes del corte definitivo del canal de agarre; el pulgar termina más atrás. Se conserva el volumen fuerte, la muñeca y los dedos juntos. El cambio local se aprecia mejor desde el ángulo opuesto al render habitual; no busca borrar la hendidura natural del agarre.
- El GLB deja de presentar las motas oscuras anteriores en las vistas revisadas. La corrección corresponde al color base horneado; no se ha intentado resolverla aumentando la intensidad del normal ni suavizando la escultura.
- La luz frontal del estudio Godot aún revela la superficie interior de capucha y su relieve longitudinal, aunque ya no una repisa horizontal. El render artístico la mantiene más sumida en sombra. La galería de integración permite valorar esa intención con las luces reales del templo.
- Se conservan la escritura, tamaño de glifos, rojo mate y espaciado de VII. El detalle cercano sigue siendo la mejor vista para valorar letras/desgaste; no se registra aceptación de lectura a distancia de juego. La separación extra entre versos no formaba parte de los tres retoques priorizados.
- El coste pasa de 173.792 a 169.352 triángulos, aproximadamente un 2,55 % menos. La medición de ambas instancias dentro del templo y sus límites están en la galería de integración.
- Se conservan silueta, altura, orientación de hombros y caída de mangas. VIII queda aceptada para integración mediante A04-12; la presentación final del nivel se revisa aparte, con regresiones ya ejecutadas.
