# Pipeline del Vigía del Umbral

La iteración 08 implementa localmente A04-11: transición interior continua entre torso y capucha, unión palmar superior regularizada y corrección del color de caras UV que quedaban sin muestra al hornear. Se conservan la estola plana oscura y las runas rojo mate de A04-10, las proporciones de manos/muñecas y el arma. La inscripción aprobada es el **Código Sith completo, sus seis versos en inglés escritos con runas**, repartidos entre ambas bandas. Se mantienen tres materiales y ausencia de emisión.

La inscripción usa **Sith AF, de Ender Smith/AurekFonts**, tipografía de terceros de estilo Kittât Legends con licencia [CC BY 3.0 US](https://creativecommons.org/licenses/by/3.0/us/), identificada en la [página del autor](https://www.dafont.com/sith-af.font) y en los metadatos OTF. El original y los créditos se conservan en `tools/blender/fonts/`; la procedencia se registra en `ASSETS.md`. Es una transliteración gráfica del inglés, no una traducción a la lengua Sith ni la grafía oficial acreditada del holocrón. Sustituye los motivos ornamentales del primer ensayo; composición, espaciado y lectura siguen pendientes de revisión visual.

La composición actual conserva los contornos de la fuente (`offset = 0`), con glifos de 105 mm de alto nominal e incisiones superficiales de 2 mm. Los cortadores de texto se sueldan y comprueban como sólidos cerrados antes de la operación booleana. De frente se leen los versos 1–3 en la banda izquierda y 4–6 en la derecha; dentro de cada banda, filas de arriba abajo y letras de izquierda a derecha. Se distribuyen hasta seis caracteres por fila, contando espacios: 17 filas a la izquierda y 15 a la derecha; cada verso comienza una fila nueva. Se conservan todas las letras y espacios; las comas y puntos latinos se omiten en la geometría porque no se presupone su equivalencia en la fuente. `SITH_CODE` y el [manifiesto de inscripción](../../art/references/vigia_umbral/inscription_layout.json) conservan los seis versos con su puntuación original; el manifiesto añade filas, orden de lectura y parámetros.

La zona de escritura tiene una cara plana transversal con bordes de 25 mm y se adapta a la túnica longitudinalmente. La transición superior conserva la curvatura de VI entre 4,10 y 4,85 m. El volumen se cierra hacia el interior según Y, sin Solidify por normales que produciría salientes junto a la capucha. `Vigia_Pigment` guarda dos máscaras por esquina de cara: oscurecimiento de estola/borde de capucha y pigmento rojo en las caras de las incisiones. El material pétreo mezcla color y desgaste procedurales con esas máscaras, manteniendo rugosidad de piedra y emisión cero. El exportador hornea su resultado en los mapas existentes y elimina el atributo de las copias antes de exportar, evitando duplicar el tinte en Godot. Las dos bandas reservan proyecciones UV frontales continuas dentro del atlas de piedra; las islas automáticas estrechas perdían pigmento de letras enteras. El resto de piedra mantiene Smart UV en la mitad derecha del atlas; su resolución total continúa siendo 2048². La limpieza geométrica usa tolerancias pequeñas para conservar los triángulos finos del grabado.

Se conserva la unión de mangas y manto con bordes compartidos de A04-08, la silueta vertical, el arma y la caída de las mangas. La dirección elegida es aproximadamente 50 % humanoide / 50 % estatua. El usuario acepta VIII para integrarlo mediante A04-12. Ambas instancias ya están en la demo; [QA_0_4_0.md](../../QA_0_4_0.md) documenta regresiones, comparación y aceptación de presentación todavía pendiente.

El remate del torso se prolonga con secciones más estrechas y retraídas hasta quedar embebido detrás de la cavidad de capucha, eliminando la antigua tapa horizontal expuesta. El exterior de la capucha se conserva; su interior comparte el tono pétreo oscuro. En la mano superior, palma y pulgar se fusionan antes de cortar el canal de agarre definitivo y la punta del pulgar queda más atrás. La mano inferior mantiene la construcción de VII.

Las correcciones posteriores sitúan ambos pulgares detrás de la empuñadura y oscurecen la figura hacia gris pizarra frente a la piedra más clara del arma. Cada regeneración aplica también estos acuerdos.

Se conservan los parámetros generales de la base 04: reducción del ancho exterior de aproximadamente un 22 %, con transición cerca del eje para mantener el agarre; empuñadura 0,22 m más baja y hoja acortada con punta fija. Son parámetros del generador, no medidas aprobadas por el usuario. `HAND_HEIGHTS` y `SWORD_DROP` coordinan manos, mangas y arma; pedestal y altura total se conservan.

Parámetros de prueba de la revisión 06: los radios inicial/final de las muñecas pasan de 0,087/0,097 m a 0,120/0,113 m y su factor vertical de 0,82 a 0,90. Se ensancha la zona proximal de la palma; el factor X de la mano pasa de 0,92 a 0,98, con factores Z de 1,055 e Y de 1,02. La revisión visual debe comprobar que esta robustez mantiene holgura dentro de las mangas.

## Generar y exportar

Se necesita **Blender 5.2.2 LTS**, sin complementos. Desde la raíz del repositorio, en PowerShell:

```powershell
$blenderExe = "$env:LOCALAPPDATA\Programs\Blender Foundation\Blender 5.2.2\blender-5.2.2-windows-x64\blender.exe"
& $blenderExe --background --python-exit-code 1 --python tools/blender/create_vigia.py
# Continuar solo si la orden anterior termina sin error.
& $blenderExe --background --python-exit-code 1 --python tools/blender/export_vigia.py
```

Si Blender está en otra ruta, cambia solo `$blenderExe`. En un sandbox de Windows, `$env:LOCALAPPDATA` puede apuntar a otro directorio: usa la ruta absoluta real de la instalación. Para revisar geometría rápidamente se puede añadir `-- --draft` al generador (Eevee, menor resolución); la ejecución normal produce diez renders con Cycles: cinco vistas generales y cinco detalles (`detail_cowl.png`, `detail_shoulders.png`, `detail_stole.png`, `detail_inscription.png` y `detail_hands.png`). El detalle de inscripción acerca la cámara para revisar la lectura de los glifos. `-- --no-renders` guarda la fuente editable y el manifiesto sin renderizar imágenes.

El generador **reconstruye** `art/source/statues/vigia_umbral.blend`; no ejecutarlo tras cambios manuales que se quieran conservar. Los ajustes reproducibles se realizan en `create_vigia.py`. La fuente conserva 19 piezas editables con nombres y tres materiales procedurales propios. Las raíces de las mangas se conectan a ventanas del manto mediante bordes compartidos y puentes de Hermite que controlan la pendiente, sin las antiguas tapas planas. Esta superficie se fusiona por volumen con túnica y capucha. Cada mano se construye por secciones desde la muñeca hasta los nudillos, con planos tallados y un canal booleano para la empuñadura; los dedos permanecen juntos y los pulgares detrás. El pedestal y las partes del arma siguen separados. El transporte del marco de las mangas evita la inversión que antes deformaba los codos.

El exportador abre la fuente, evalúa copias de sus mallas, las agrupa en tres materiales, crea UV y hornea mapas de color, rugosidad y normal. La fuente original no se guarda modificada. Produce:

- `assets/models/environment/vigia_umbral.glb`: modelo con todos sus mapas incrustados, sin archivos externos necesarios para jugar.
- `art/source/statues/vigia_umbral_textures/`: nueve PNG originales del horneado; por defecto, 2048² para piedra dominante, 1024² para piedra clara y 512² para bronce.
- `art/references/vigia_umbral/export_report.json`: tamaño, hash, geometría y comprobación de tres materiales/nueve imágenes incrustadas.

La opción del exportador `-- --texture-size 1024` reduce la resolución del atlas principal para ensayos. La exportación normal usa 2048. Los mapas se generan localmente, sin texturas descargadas. La reconstrucción utiliza el OTF incluido en `tools/blender/fonts/` y no necesita descargarlo durante la ejecución.

La intensidad del normal exportado se mantiene en 0,25 como calibración del microrelieve. El defecto histórico de pequeños triángulos oscuros de [#26](https://github.com/Dioniss97/ShadowsOfKharuun/issues/26) se aisló en el color base: también aparecía sin iluminación y desaparecía con un material neutro. Los píxeles de reserva de imágenes generadas se estaban escribiendo como valores lineales dentro de PNG sRGB; las caras UV subpíxel que no recibían muestras quedaban demasiado oscuras al decodificarse. El exportador codifica esa reserva a sRGB y completa los texeles aún sin muestra de caras muy finas con colores muestreados de caras vecinas en la superficie, respetando sus máscaras de pigmento. Esto evita sustituir las manchas negras por facetas claras y conserva las dimensiones de los atlas. NumPy se usa desde el Python incluido con Blender; no se instala una dependencia adicional.

## Revisar el GLB en Godot

Los `.gdignore` en `art/source/` y `art/references/` excluyen fuentes/renders del importador del motor. Godot importa el GLB de `assets/`; no necesita tener Blender configurado. Si se guardan respaldos `.blend` en otra carpeta del proyecto, hay que excluir esa carpeta también.

El `.glb.import` usa `gltf/embedded_image_handling=3` (Embed as Uncompressed): mantiene las texturas dentro de la escena importada sin pérdida y evita generar nueve PNG duplicados junto al modelo. Es el modo documentado por [Godot](https://docs.godotengine.org/en/stable/classes/class_gltfstate.html#enum-gltfstate-handlebinaryimagemode); la memoria y compresión finales aún se revisarán con ambas instancias.

Con Godot 4.7.2 y una GPU compatible con Forward+, ejecutar desde la raíz:

```powershell
& tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import --log-file tools/logs/vigia-import.log
& tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --script res://tools/blender/preview_vigia.gd --resolution 960x720 --fixed-fps 60 --quit-after 1200 --log-file tools/logs/vigia-preview.log
```

Revisar que la importación no registre `ERROR:` y que la captura termine con `VIGIA_PREVIEW_OK`. La revisión 08 genera nueve capturas del estudio independiente: `godot_front.png`, `godot_three_quarter.png`, `godot_profile_right.png`, `godot_back.png`, `godot_detail_cowl.png`, `godot_detail_shoulders.png`, `godot_detail_stole.png`, `godot_detail_inscription.png` y `godot_detail_hands.png`, además de `godot_import_report.json`. La ejecución del 16-10-2026 terminó sin errores con Godot 4.7.2 Forward+/Vulkan en RX 6600, a 960×1200 y sin dependencias externas. Sus informes coinciden en el SHA-256 del GLB `192a22bc4f519bbdaa0cb594756344b0b75f055211ae4d128bec1841824b248e`: 169.352 triángulos, 84.706 vértices, 18.214.180 bytes, tres materiales y nueve mapas; sin emisión ni atributos de máscara en ejecución. Las vistas revisadas ya no muestran las motas triangulares anteriores. La [comparación VIII](../../art/references/vigia_umbral/review_08/README.md) recoge geometría y diagnóstico del horneado. Los informes y renders de VII se conservan como historial en `art/references/vigia_umbral/iterations/07/`.

La fuente es Z-up y mira hacia Blender +Y. El exportador gira la copia 180° sobre Z antes de convertir a glTF. Las capturas desde Godot +Z muestran el frente de la figura; la comparación de integración comprueba esta lectura bajo las transformaciones y luces reales del templo.

Los renders de Blender y las capturas del estudio Godot permiten iterar el asset. La [comparación dentro del nivel](../../art/references/vigia_umbral/integration/README.md) acredita ambas instancias con las mismas posiciones y colisiones. El asset VIII está aceptado para integración; la presentación final del nivel y la publicación esperan las decisiones registradas en QA. La candidata es 0.4.0-rc1; el tag estable publicado sigue siendo v0.3.0. Los campos de aceptación de los JSON artísticos reflejan el momento de su generación anterior a A04-12; no sustituyen el registro posterior del usuario.

## Licencia pendiente

La publicación de los dos scripts que usan `bpy` espera la decisión informada de Q04-06. La [página oficial de Blender](https://www.blender.org/about/license/) describe sus condiciones; GPL permite uso comercial y sus condiciones sobre scripts no imponen GPL a los modelos exportados ni al juego. No se ha aplicado una licencia nueva al proyecto.
