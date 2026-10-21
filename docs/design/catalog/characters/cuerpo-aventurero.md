# Cuerpo del aventurero

**Tipo:** personaje humanoide de producción.
**Estado de diseño:** aprobada para requisitos funcionales y coherencia artística. La apariencia concreta del modelo necesita aceptación visual.
**Contexto:** misión existente del templo; nombre de producción sin canon narrativo nuevo.
**Issues:** [alcance #34](https://github.com/Dioniss97/ShadowsOfKharuun/issues/34), [producción #35](https://github.com/Dioniss97/ShadowsOfKharuun/issues/35).

## Diseño actual

Personaje adulto humanoide creado y editable en Blender, con rig compartido entre cuerpo y prendas. El primer estado visible es [sin uniforme equipado](../clothing/sets/ropa-base.md): ropa interior sencilla y calzado base. El [uniforme completo](../clothing/sets/uniforme-del-umbral.md) cambia las prendas corporales y el calzado; los objetos de cabeza se gestionan aparte.

El nivel de acabado y los materiales deben leerse como parte del mismo juego que el [Vigía](../environment/vigia-del-umbral.md). La anatomía de producción se adapta desde la malla base CC0 de MakeHuman; proporciones, rig, selección de superficies y vestuario se trabajan en Blender. Su procedencia se conserva en el inventario de recursos.

## Criterios observables

- Apariencia base completa, sin desnudez literal y sin huecos o penetraciones visibles.
- Deformaciones coherentes en reposo, andar, correr, giro, guardia, ataque y gestos de poderes.
- Arma en mano derecha y origen de poderes en palma izquierda conservados.
- Revisión del modelo en cámara jugable y vistas cercanas de Godot; aceptación artística humana.

## Rutas de producción

La candidata conserva el atlas UV anatómico CC0 con mapas propios de piel de 1024² y material explícito en Godot. Muñecas y falanges componen reposo por delta; la mano derecha tiene pose y correctivo de contacto específicos para el mango actual. Ajustes suaves de cintura, deltoides y muñecas, evidencia y límites en [calidad 12](../../../../art/references/character/iterations/quality_12/README.md). Implementación sin aceptación artística implícita.

- Fuente: art/source/characters/adventurer.blend.
- Base CC0 y licencia: art/source/characters/vendor/makehuman/.
- GLB: assets/models/characters/adventurer.glb.
- Generación: tools/blender/create_character.py y human_base.py.
- Adaptador de animación: scripts/character_rig.gd.
- Capturas e informes: art/references/character/.

## Decisiones

19-10-2026: producción autorizada por el usuario tras revisar la hoja de ruta. Las capturas KOTOR son referencias de estados visuales; no se importan assets de esos juegos. La revisión inicial del modelo no representa un diseño final de protagonista o una aprobación de su apariencia concreta.

21-10-2026: comparación de alternativas anatómicas autorizada tras el rechazo visual de manos y postura. La [evaluación en Blender](../../../../art/references/character/base_model_comparison_20261021/README.md) compara la base actual, su origen MakeHuman y el cuerpo masculino realista CC0 de Blender Studio. **Propuesta pendiente de elección:** usar ese cuerpo completo como nueva base y riggearlo conservando sus proporciones; mantener materiales, paleta y vestuario propios. La comparación también aísla un óvalo dorsal causado por el correctivo de contacto actual. No se ha sustituido la anatomía de producción ni se ha aprobado la apariencia candidata.

21-10-2026, decisión posterior: el usuario valora mejor Blender Studio y **aprueba una prueba acotada de rig y movimiento** con ese cuerpo completo. Esta autorización concreta la evaluación propuesta: reposo relajado, hombro/codo, mano abierta/sujeción, marcha y giro en Godot. [Fuente, visor y evidencia del ensayo](../../../../art/references/character/studio_rig_trial/README.md). La adopción definitiva, el acabado artístico y el reemplazo del personaje equipado quedan pendientes del resultado y de aceptación humana. Se preservan proporciones y manos originales; los ajustes se aplican a rig, pesos y pose. La regla vigente de ropa base y uniformes completos se mantiene.
