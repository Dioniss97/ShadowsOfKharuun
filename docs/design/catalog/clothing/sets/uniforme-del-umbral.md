# Uniforme del Umbral

**Tipo:** conjunto equipable completo; nombre de producción.
**Estado de diseño:** aprobada para requisitos; propuesta visual concreta pendiente de aceptación.
**Issues:** [#34](https://github.com/Dioniss97/ShadowsOfKharuun/issues/34), [#36](https://github.com/Dioniss97/ShadowsOfKharuun/issues/36).

## Identidad

Primer conjunto del personaje: [túnica](../pieces/tunica-del-umbral.md) con [capa posterior integrada](../pieces/capa-posterior-del-umbral.md), [pantalones](../pieces/pantalones-del-umbral.md), [botas](../pieces/botas-del-umbral.md) y [cinturón](../pieces/cinturon-del-umbral.md). La capa no es un objeto de equipamiento independiente. Este diseño deja las manos libres y no añade objeto de cabeza; cabeza y manos permanecen fuera del cambio corporal.

## Diseño y comportamiento

La indumentaria es un solo artículo de inventario. Al equiparlo, cambian conjuntamente todas sus piezas, incluidos zapatos; al retirarlo vuelve la ropa base. Paleta grafito, pizarra, cuero oscuro y bronce contenido, con calidad de formas/materiales coherente con el Vigía.

La ropa comparte el esqueleto corporal. La candidata usa seis cadenas secundarias para los paneles del faldón y nueve para la capa posterior, con cápsulas SpringBone vinculadas a torso, brazos superiores y piernas. Las superficies interiores cubiertas se ocultan. Las cápsulas mitigan penetraciones en zonas concretas; la técnica no es una simulación por vértice ni certifica ausencia de clipping en todas las poses.

## Criterios observables

- Cambio integral y reversible de apariencia, con calzado del conjunto.
- Cabeza y manos permanecen visibles; equipo de cabeza independiente.
- Tela con respuesta al desplazamiento y giros, sin levantamientos ni penetraciones notorias en las acciones revisadas.
- Revisión artística y del coste dentro de Godot.

## Rutas

Fuente art/source/characters/adventurer.blend, grupo UniformOutfit de assets/models/characters/adventurer.glb. Movimiento y cobertura en scripts/character_rig.gd. Evidencia en art/references/character/.
