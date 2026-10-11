# Recursos y procedencia

**Todos los recursos del juego se han creado para esta demo** mediante código: escenario, módulos arquitectónicos, personajes, armas, runas, banderas, rocas, montañas, cielo, materiales, animaciones, partículas e interfaz. Los shaders están en `assets/`. Los efectos y el ambiente son ondas sintetizadas en `scripts/audio.gd`, sin muestras descargadas.

No se han descargado modelos, texturas, música, voces ni recursos de videojuegos comerciales. Las capturas de `screenshots/` proceden del Viewport real de Godot; no son imágenes generadas con IA.

| Dependencia externa | Procedencia | Licencia / uso |
|---|---|---|
| Godot 4.7.2 estándar para Windows x86_64 | https://godotengine.org/download/windows/ y https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable | MIT; https://godotengine.org/license/ |
| Tipografía predeterminada de Godot | Incluida en el motor | Licencias de terceros del motor: https://godotengine.org/license/ |
| Georgia / Times New Roman del sistema | SystemFont de Windows, sin copiar archivos | Uso de la fuente instalada; fallback del sistema si falta |
| Voz española de Windows | DisplayServer TTS; identificador consultado en tiempo de ejecución | Servicio local del sistema, no se redistribuye la voz |

La descarga del motor se verificó contra el digest SHA256 de la API oficial de GitHub y el archivo oficial `SHA512-SUMS.txt`. La URL y el SHA256 están en `tools/godot-source.json`.

La ambientación Sith y la inspiración KOTOR son referencias del encargo para una demo privada. No se han utilizado logotipos ni recursos técnicos o audiovisuales de esas obras.
