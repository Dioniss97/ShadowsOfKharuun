# Biblioteca de diseño

**Estado de esta convención: aprobada.** Esta biblioteca conserva especificaciones de diseño vigentes y reutilizables del proyecto. No es un plan de versión ni una carpeta de entregas.

## Fuentes de verdad

| Qué necesito consultar | Fuente |
|---|---|
| Diseño actual de un mundo, sistema, personaje, asset, sonido o pantalla | Ficha canónica de esta biblioteca |
| Alcance de una versión y trabajo por hacer | Issues y milestone de GitHub |
| Avance de una tarea | Estado y etiquetas de su Issue |
| Qué se publicó | Tag y entrada correspondiente en el changelog |
| Créditos y licencias de recursos | [Inventario de recursos](../project/ASSETS.md) |

Las fichas registran el estado de diseño: propuesta, pendiente de decisión, aprobada o descartada/sustituida. Una ficha aprobada describe un diseño aceptado; no demuestra que ya esté producido o integrado en el juego. Las Issues conservan el estado del trabajo y enlazan las fichas pertinentes.

## Organización

El README de cada categoría funciona como índice de sus fichas. No se mantiene una lista única con todos los elementos. Crear una carpeta de categoría y su índice al incorporar la primera ficha de ese tipo; esta taxonomía orienta la ubicación y puede ampliarse cuando aparezca contenido nuevo.

- **foundations/**: principios compartidos de lenguaje visual, narrativa, gameplay, audio e interfaz.
- `worlds/<world-id>/`: planeta y contexto, clima, biomas, regiones, geografía y ecología. El README del mundo es un hub que enlaza los elementos que lo componen.
- **gameplay/**: sistemas y contenido como combate, exploración, progresión, inventario, habilidades e interactuables.
- **narrative/**: personajes, facciones, misiones, escenas, diálogos, culturas y otros elementos narrativos.
- **catalog/**: fichas de objetos concretos de producción, incluso si solo se usan en un mundo: arquitectura, entorno, criaturas, vestuario, props, armas, equipo, vehículos, materiales, animaciones y efectos visuales.
- **audio/**: música, ambientes, efectos sonoros y voces.
- **ui/**: flujos, pantallas, componentes y estados de interacción.

Las rutas son orientativas: crear solo las carpetas necesarias. Un concepto de arquitectura propio de una cultura puede enlazarse desde su ficha narrativa; una columna o edificio concreto tiene ficha en el catálogo. Los mundos enlazan las fichas canónicas del catálogo, también cuando un elemento sea exclusivo de ellos.

Cada elemento con identidad y criterios propios tiene su ficha. Una ficha de conjunto puede enlazar fichas de sus piezas: por ejemplo, un uniforme y sus prendas individuales. Las variantes de color se describen dentro de la ficha de la prenda; una variante con identidad de diseño propia puede tener ficha independiente.

Usar nombres de archivo cortos, estables y descriptivos. Por ejemplo: `catalog/clothing/pieces/tunica-del-vigia.md`. Si una ficha pierde vigencia, conservar la razón y enlazar la ficha o decisión que la sustituye.

## Versiones e Issues

El diseño persistente no se copia a carpetas de versión. La Issue de propuesta define el alcance de una versión; las Issues de trabajo enlazan las fichas que diseñan o producen. Actualizar la ficha cuando cambie el diseño vigente y la Issue cuando cambie el trabajo. El changelog registra las entregas publicadas.

Las fichas de diseño pueden enlazar varias Issues. No copiar en ellas etiquetas, milestones, fechas de entrega ni otros estados operativos. El cuerpo de una Issue mantiene el alcance y los criterios de esa tarea; la ficha es la referencia canónica del diseño compartido o reutilizable.

## Referencias y artefactos

Registrar de dónde viene cada referencia visual, sonora o textual y qué aporta al diseño. Para fuentes externas, créditos y licencias, enlazar también el [inventario de recursos](../project/ASSETS.md).

Incluir rutas reales a las fuentes y salidas de producción cuando existan, por ejemplo archivos Blender, texturas, recursos Godot, audio o escenas de UI. Si todavía no se han producido, indicar que la ruta está pendiente en vez de inventarla.

La plantilla común está en [_templates/elemento.md](_templates/elemento.md). Usarla como base y conservar solo los bloques que correspondan al tipo de ficha.
