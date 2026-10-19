# Ropa base sin uniforme

**Tipo:** estado de apariencia predeterminado.
**Estado de diseño:** aprobada; aspecto del modelo sujeto a revisión visual.
**Issues:** [#34](https://github.com/Dioniss97/ShadowsOfKharuun/issues/34), [#35](https://github.com/Dioniss97/ShadowsOfKharuun/issues/35).

## Diseño

Es el aspecto que el usuario llama “ir desnudo” o “sin uniforme” en referencia a KOTOR: cuerpo con [camiseta básica](../pieces/camiseta-base.md), [shorts](../pieces/shorts-base.md) y [calzado base](../pieces/calzado-base.md). No es un objeto que deba equiparse; aparece automáticamente cuando la ranura de uniforme está vacía.

## Criterios observables

Nueva partida y retirar el uniforme muestran todas las piezas base. Equipar un conjunto sustituye también el calzado. Los polígonos ocultos por las prendas no deben aparecer atravesándolas.

## Producción

Fuente y export compartidos con [el cuerpo](../../characters/cuerpo-aventurero.md). El grupo BaseOutfit del GLB y las zonas expuestas BodyCovered constituyen este estado.
