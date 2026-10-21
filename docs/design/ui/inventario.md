# Pantalla de inventario

**Tipo:** interfaz.
**Estado de diseño:** aprobada para flujo; propuesta visual de producción para revisar.
**Issues:** [#37](https://github.com/Dioniss97/ShadowsOfKharuun/issues/37).

## Flujo y presentación

Pantalla en la paleta oscura, marfil y bronce de la demo. Lista de conjuntos a la izquierda, descripción y botones Equipar/Retirar; vista 3D de la apariencia actual a la derecha con botones de giro. Volver, I o ESC cierran el panel. La cabeza se identifica como equipo aparte.

La lista y los botones muestran el estado equipado; no se permite duplicar el conjunto ni perder las prendas base. La vista 3D usa los mismos recursos del personaje y se actualiza al equipar/retirar. La representación 3D solo se renderiza mientras el panel está visible.

La vista muestra el cuerpo entero, incluidos guantes y calzado, con margen para la cabeza y las suelas. Arranca ligeramente girada para leer la capa y los volúmenes; los botones giran 45° en ambos sentidos sin alterar la orientación del personaje del juego. Una luz de relleno fría complementa la principal cálida. La aceptación de esta presentación se registra en la issue, separada del flujo aprobado.

## Criterios observables

Legibilidad a 1280×720, navegación con foco de teclado y ratón, selección equipable coherente, retorno a gameplay/pausa táctica anterior sin clics sobre la escena subyacente.

## Producción

scripts/inventory_ui.gd. Capturas en art/references/character/integration/inventory_base.png e inventory_uniform.png. Reglas en [Inventario y equipamiento](../gameplay/inventario-equipamiento.md).
