# Capa posterior del Umbral

**Tipo:** componente visual integrado de la Túnica del Umbral; no tiene ranura de equipamiento propia.
**Estado de diseño:** componente de la candidata 0.5.0; apariencia final pendiente de aceptación visual.
**Conjunto:** [uniforme-del-umbral](../sets/uniforme-del-umbral.md).

## Diseño

Paño trasero de tela grafito que nace de los hombros y cae hasta la pantorrilla. Conserva pliegues verticales amplios, un borde reforzado y un cierre pequeño de bronce. Su silueta y volumen deben leerse a distancia y mantener el carácter sobrio del Vigía.

## Movimiento

Nueve cadenas secundarias distribuidas por el paño aportan inercia durante el desplazamiento. Ocho cápsulas auxiliares cubren torso, cintura, brazos superiores y piernas para reducir penetraciones. Es dinámica secundaria por huesos; no representa la simulación completa de una malla textil con autocolisión.

El borde superior comparte el anclaje rígido del cierre a la espalda; los siguientes 22 cm transicionan hacia las cadenas secundarias. El bajo conserva holgura posterior respecto al faldón y las cadenas siguen esa caída. Esta separación reduce la penetración observada al detenerse; las cápsulas corporales no constituyen colisión entre prendas.

## Criterios observables

Se muestra y retira junto al uniforme entero. La capa sigue el rig, reacciona al correr y girar, permanece finita y no presenta penetraciones llamativas en las poses/transiciones revisadas. La evaluación técnica no sustituye la aceptación visual humana.

## Rutas de producción

Mallas UniformCape, UniformCapeHem y UniformCapeClasp en art/source/characters/adventurer.blend, exportadas dentro de UniformOutfit en assets/models/characters/adventurer.glb. Rig en scripts/character_rig.gd; evidencia y estado en [#36](https://github.com/Dioniss97/ShadowsOfKharuun/issues/36).
