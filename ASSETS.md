# Recursos y procedencia

La geometría, materiales, animaciones, efectos e interfaz se han creado para esta demo mediante código. Los shaders están en `assets/`. Los efectos y el ambiente son ondas sintetizadas en `scripts/audio.gd`, sin muestras descargadas. La escritura de la estola del Vigía utiliza la tipografía externa acreditada abajo.

No se han descargado modelos, texturas, música, voces ni recursos de videojuegos comerciales. El Vigía del Umbral de 0.4.0 es una creación original generada con los scripts y la fuente Blender del repositorio. Su piedra y bronce emplean materiales procedurales propios horneados a nueve mapas PBR; no proceden de una biblioteca externa.

Las cinco vistas principales y los cinco detalles `detail_*.png` de la revisión 08 en `art/references/vigia_umbral/` son renders de Blender. Los nueve `godot_*.png` son capturas auténticas de un estudio de revisión de Godot, generado con `tools/blender/preview_vigia.gd`; no corresponden al nivel del templo ni acreditan QA de la misión. Las vistas neutras de `review_07/` y `review_08/` son renders de diagnóstico de la geometría real. Las capturas de `screenshots/` proceden del Viewport real del juego. Ninguna de estas imágenes es un bitmap inventado por un generador de imágenes.

La carpeta [integration/](art/references/vigia_umbral/integration/README.md) conserva las comparaciones antes/después del **nivel real**, informes de colisiones/cámaras y evidencia de regresión de 0.4.0; no son imágenes del estudio ni renders Blender. A04-12 acepta el modelo VIII para integración. La aceptación de presentación del nivel y su publicación se documentan en [QA_0_4_0.md](QA_0_4_0.md).

El usuario aportó una fotografía de una figura encapuchada y tres imágenes de vibroespadas/arma de asta como referencias de forma. Se conservan como guías de la conversación; no se redistribuyen en el repositorio ni se incorporan como texturas o modelos, pues su origen/licencia no se han acreditado. La vibrohoja de la estatua es una interpretación geométrica propia, sin emisión ni recursos extraídos.

Para A04-09 aportó además una imagen de un holocrón Sith como referencia de escritura. Después confirmó que la inscripción debe ser el Código Sith completo en su versión inglesa, representado con runas. El grabado usa **Sith AF**, interpretación de Kittât de Legends de **Ender Smith / AurekFonts**, con licencia **CC BY 3.0 US**. Se conserva el OTF original sin modificar; los glifos se convierten a malla, se ajustan a la estola y se tallan. Los avisos y cambios están en [LICENSE-SithAF.md](tools/blender/fonts/LICENSE-SithAF.md). El texto pertenece a la ficción de Star Wars; no se afirma una traducción a la lengua Sith ni una caligrafía oficial del holocrón. La imagen de referencia no se redistribuye. El orden de lectura y la división del texto se registran en [inscription_layout.json](art/references/vigia_umbral/inscription_layout.json).

Para A04-10 el usuario aportó una imagen de estola como guía de forma plana y superficie para escritura; no se copia su ornamentación ni su color intenso y no se redistribuye esa imagen. El oscurecimiento de la estola/borde de capucha y el rojo desgastado de las runas son variaciones procedurales propias del material pétreo, horneadas dentro de los mismos mapas; no usan emisión ni texturas externas.

| Dependencia externa | Procedencia | Licencia / uso |
|---|---|---|
| Sith AF, Ender Smith / AurekFonts | [Página y declaración del autor](https://www.dafont.com/sith-af.font), OTF original en `tools/blender/fonts/` | [CC BY 3.0 US](https://creativecommons.org/licenses/by/3.0/us/); atribución y cambios en [LICENSE-SithAF.md](tools/blender/fonts/LICENSE-SithAF.md). Solo para regenerar el grabado; Godot consume su geometría en el GLB, sin cargar la fuente. |
| Godot 4.7.2 estándar para Windows x86_64 | https://godotengine.org/download/windows/ y https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable | MIT; https://godotengine.org/license/ |
| Blender 5.2.2 LTS para edición y exportación del Vigía (no requerido para ejecutar el juego) | https://www.blender.org/download/ | GNU GPL para el software; el arte creado con Blender pertenece a su autor. El ejecutable portátil no se incluye en el repositorio; https://www.blender.org/about/license/ |
| Tipografía predeterminada de Godot | Incluida en el motor | Licencias de terceros del motor: https://godotengine.org/license/ |
| Georgia / Times New Roman del sistema | SystemFont de Windows, sin copiar archivos | Uso de la fuente instalada; fallback del sistema si falta |
| Voz española de Windows | DisplayServer TTS; identificador consultado en tiempo de ejecución | Servicio local del sistema, no se redistribuye la voz |

La descarga del motor se verificó contra el digest SHA256 de la API oficial de GitHub y el archivo oficial `SHA512-SUMS.txt`. La URL y el SHA256 están en `tools/godot-source.json`.

La ambientación Sith y la inspiración KOTOR son referencias del encargo para una demo pública original. No se han utilizado logotipos ni recursos técnicos o audiovisuales de esas obras.
