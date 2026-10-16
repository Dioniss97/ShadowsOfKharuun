# Revisión visual — Vigía del Umbral, iteración 05

**Revisión 05 — A04-08:** corrección localizada sobre la base satisfactoria de la iteración 04. Las raíces de las mangas comparten bordes con ventanas del manto y se unen mediante puentes de Hermite, sustituyendo las tapas planas que dejaban un escalón. Se conserva la orientación vertical del hombro derecho anatómico (izquierda en frontal) y el izquierdo desciende de forma más directa, con asimetría natural.

Los puños se reconstruyen por secciones desde la muñeca hasta los nudillos, con palma en cuña, planos tallados, extremo del meñique más corto y canal booleano para la empuñadura. Cada mano sigue siendo una masa continua con dedos juntos; los pulgares pasan detrás del agarre. La fuente conserva 19 piezas. Estos cambios implementados localmente requieren revisión visual humana.

Se mantiene la altura y anchura global de la base 04, la capucha y el rostro oscuro, el arma, los codos y la caída de las mangas. La figura conserva la piedra pizarra oscura frente a la hoja/carcasa más claras y los acentos de bronce. **A04-08 elige aproximadamente 50 % humanoide / 50 % estatua**; la autoridad y amenaza contenida deben proceder de la postura y la calidad de las formas. La aceptación final y la integración definitiva en el templo necesitan aprobación visual del usuario.

La fuente editable está en [vigia_umbral.blend](../../source/statues/vigia_umbral.blend). Los comandos de generación/exportación y revisión están en [tools/blender/README.md](../../../tools/blender/README.md). La imagen externa del usuario se usa como guía de la conversación y no se redistribuye.

## Renders Blender

El generador produce ocho renders del mismo modelo con Cycles en Blender 5.2.2 LTS: cinco vistas generales y tres detalles. La revisión requiere comparar el frontal con el encuadre anterior, los tres cuartos, ambos hombros y el agarre, valorando también la continuidad tridimensional. No son capturas del nivel ni imágenes conceptuales que sustituyan la geometría real.

**Evidencia local del 16-10-2026:** ocho renders Cycles de 960 × 1200, fuente con 19 piezas y GLB de 156.478 triángulos, tres materiales y nueve mapas incrustados. La importación y las cinco capturas GPU terminan sin errores; los informes enlazados registran el mismo hash del GLB. Esto acredita el flujo técnico, con el defecto visual de #26 aún abierto.

| Vista | Archivo |
|---|---|
| Frontal con materiales | [front_materials.png](front_materials.png) |
| Perfil derecho | [profile_right.png](profile_right.png) |
| Tres cuartos | [three_quarter.png](three_quarter.png) |
| Posterior | [back.png](back.png) |
| Silueta plana | [silhouette.png](silhouette.png) |
| Capucha, nuca y hombros | [detail_cowl.png](detail_cowl.png) |
| Ambos hombros y nacimiento de las mangas | [detail_shoulders.png](detail_shoulders.png) |
| Puños y agarre | [detail_hands.png](detail_hands.png) |

## Capturas auténticas de Godot

Se obtienen cargando el GLB exportado en un estudio de revisión con Godot 4.7.2 Forward+/Vulkan. Los tres materiales tienen mapas incrustados de color, rugosidad y normal. La cámara frontal situada en +Z muestra el frente de la figura.

| Evidencia | Archivo |
|---|---|
| Frontal del GLB | [godot_front.png](godot_front.png) |
| Tres cuartos del GLB | [godot_three_quarter.png](godot_three_quarter.png) |
| Detalle de capucha del GLB | [godot_detail_cowl.png](godot_detail_cowl.png) |
| Ambos hombros del GLB | [godot_detail_shoulders.png](godot_detail_shoulders.png) |
| Detalle de puños del GLB | [godot_detail_hands.png](godot_detail_hands.png) |
| Informe de exportación | [export_report.json](export_report.json) |
| Informe de importación y capturas | [godot_import_report.json](godot_import_report.json) |
| Continuidad de mallas y comparación geométrica con IV | [geometry_review.json](geometry_review.json) |

La iluminación de este estudio es distinta a la de Blender y la del templo. Estas imágenes permiten revisar materiales/orientación; no sustituyen las cuatro vistas de aceptación dentro de la misión ni su QA. La aprobación humana del diseño continúa pendiente.

**Hallazgo técnico abierto ([#26](https://github.com/Dioniss97/ShadowsOfKharuun/issues/26)):** en el render texturizado de GPU persisten pequeños puntos/triángulos oscuros que no aparecen en Cycles. El GLB carga sus tres materiales/nueve mapas sin errores; eso no significa que su sombreado esté aceptado. Se comprobaron normales desactivadas, sombras/SSAO, LOD, MSAA, filtrado y compresión de atributos; ninguna de esas pruebas aisladas resuelve el defecto. Los atlas importados no contienen píxeles negros y las UV del GLB son finitas y están dentro de 0–1. La causa no se da por identificada; falta corregirla antes de la integración final.

La [frontal inicial](iterations/01/front_materials.png) y los [tres cuartos iniciales](iterations/01/three_quarter.png) se conservan como historial de la revisión rechazada, no como diseño vigente.

La [frontal II](iterations/02/front_materials.png), el [perfil II](iterations/02/profile_right.png) y los [tres cuartos II](iterations/02/three_quarter.png) conservan la base sobre la que se solicitaron A04-05 y las manos continuas. No representan aceptación artística.

La [frontal III](iterations/03/front_materials.png), los [tres cuartos III](iterations/03/three_quarter.png), el [perfil III](iterations/03/profile_right.png) y el [detalle de manos III](iterations/03/detail_hands.png) conservan las proporciones anteriores y el feedback que motiva A04-06/A04-07.

La [frontal IV](iterations/04/front_materials.png), los [tres cuartos IV](iterations/04/three_quarter.png), el [perfil IV](iterations/04/profile_right.png) y el [detalle de manos IV](iterations/04/detail_hands.png) conservan la base de comparación para A04-08, sin implicar aceptación final.

## Comparación crítica con IV

El escalón transversal del hombro derecho desaparece en frontal, perfil y tres cuartos, conservando su caída vertical. El izquierdo pierde parte del abombamiento superior independiente y se relaciona mejor con el manto; mantiene una concavidad interior de tela bastante concentrada, que merece atención en la revisión humana. Se ha regularizado también la pendiente lateral del paño para evitar un pellizco de la superficie.

Las manos dejan de depender de un contorno repetido en altura: la palma se estrecha hacia la muñeca y el extremo del meñique es más corto. La nueva construcción produjo inicialmente demasiado volumen redondeado; los planos oblicuos y la reducción local de anchura lo contienen. Los puños siguen siendo una interpretación escultórica simplificada, cuya firmeza y anatomía deben valorarse en el primer plano, además de la vista general.

El informe geométrico confirma un componente cerrado en el cuerpo y en cada mano, sin bordes abiertos ni no manifold. Arma y pedestal conservan exactamente sus vértices de IV. La nueva fusión y decimación introduce pequeñas diferencias de teselado fuera de las zonas intervenidas; la comparación de superficies queda registrada en el informe. Estas comprobaciones no certifican la calidad artística ni la presencia amenazante. La aprobación visual del usuario continúa pendiente.
