# Uniforme del Umbral

**Tipo:** conjunto equipable completo; nombre de producción.
**Estado de diseño:** aprobada para requisitos; propuesta visual concreta pendiente de aceptación.
**Issues:** [#34](https://github.com/Dioniss97/ShadowsOfKharuun/issues/34), [#36](https://github.com/Dioniss97/ShadowsOfKharuun/issues/36).

## Identidad

Primer conjunto del personaje: [túnica](../pieces/tunica-del-umbral.md) con [capa posterior integrada](../pieces/capa-posterior-del-umbral.md), [pantalones](../pieces/pantalones-del-umbral.md), [botas](../pieces/botas-del-umbral.md), [cinturón](../pieces/cinturon-del-umbral.md) y [guantes](../pieces/guantes-del-umbral.md) coordinados con las mangas. La capa no es un objeto de equipamiento independiente. No añade objeto de cabeza: la cabeza y sus accesorios permanecen fuera del uniforme.

## Diseño y comportamiento

La indumentaria es un solo artículo de inventario. Al equiparlo, cambian conjuntamente todas sus piezas, incluidos mangas, guantes, prendas inferiores y calzado; al retirarlo vuelve la ropa base. La cabeza y sus accesorios no forman parte del uniforme. Paleta grafito, pizarra, cuero oscuro y bronce contenido, con calidad de formas/materiales coherente con el Vigía.

La ropa comparte el esqueleto corporal. La candidata usa seis cadenas secundarias para los paneles del faldón y nueve para la capa posterior, con cápsulas SpringBone vinculadas a torso, brazos superiores y piernas. Las superficies interiores cubiertas se ocultan. Las cápsulas mitigan penetraciones en zonas concretas; la técnica no es una simulación por vértice ni certifica ausencia de clipping en todas las poses.

## Criterios observables

- Cambio integral y reversible de apariencia, con calzado del conjunto.
- Cabeza y equipo de cabeza permanecen fuera del uniforme; los guantes forman parte del conjunto y se equipan/retiran junto con las mangas y el resto de las prendas.
- Tela con respuesta al desplazamiento y giros, sin levantamientos ni penetraciones notorias en las acciones revisadas.
- Revisión artística y del coste dentro de Godot.

## Rutas

Fuente art/source/characters/adventurer.blend, grupo UniformOutfit de assets/models/characters/adventurer.glb. Movimiento y cobertura en scripts/character_rig.gd. Evidencia en art/references/character/.

Chaqueta, cuello, pantalón y cinturón se ajustan desde la anatomía con holgura y pesos transferidos; los guantes comparten las articulaciones de las manos. Las manos descubiertas pertenecen a BaseOutfit, los guantes a UniformOutfit y la cabeza/cuello a HeadVisible. El cuerpo interior y el conjunto base se ocultan al equipar; al retirar se restauran completos.

## Decisiones

### D37 — Guantes integrados en el uniforme (aprobada, 20-10-2026)

El uniforme completo incluye mangas y guantes coordinados con las demás prendas corporales. La cabeza y sus accesorios se siguen equipando aparte. Esto sustituye la formulación anterior de esta ficha y de #36 que mantenía las manos fuera del cambio del uniforme.

**Criterio observable:** equipar o retirar el uniforme cambia también sus guantes y mangas, y nunca altera el equipamiento de cabeza. **Issue:** #36, desglosada en #45.
