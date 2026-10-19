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

- Fuente: art/source/characters/adventurer.blend.
- Base CC0 y licencia: art/source/characters/vendor/makehuman/.
- GLB: assets/models/characters/adventurer.glb.
- Generación: tools/blender/create_character.py y human_base.py.
- Adaptador de animación: scripts/character_rig.gd.
- Capturas e informes: art/references/character/.

## Decisiones

19-10-2026: producción autorizada por el usuario tras revisar la hoja de ruta. Las capturas KOTOR son referencias de estados visuales; no se importan assets de esos juegos. La revisión inicial del modelo no representa un diseño final de protagonista o una aprobación de su apariencia concreta.
