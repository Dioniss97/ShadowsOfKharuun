# Shadows of Kharuun

Haz doble clic en **PLAY.bat**. Abre el juego directamente; no necesitas abrir el editor. Selecciona **Nueva partida**.

Asalta el templo, responde al guardián, derrota a sus tres acólitos y acaba con él. El diálogo se activa al llegar a las escaleras. Al caer los acólitos recuperas hasta 75 puntos de vitalidad y toda la energía. La victoria permite repetir o volver al menú; la derrota permite reiniciar.

| Control | Acción |
|---|---|
| WASD | Mover |
| Ratón | Girar la cámara |
| Shift | Correr |
| Clic izquierdo | Ataque de arma luminosa, alcance 2,8 m |
| 1 | Empuje: área de 5,5 m, coste 24, recarga 7 s |
| 2 | Descarga: alcance 11 m, coste 32, recarga 10 s |
| E | Hablar cerca del umbral / continuar diálogo |
| 1, 2, 3 o ratón | Elegir respuesta durante el diálogo |
| Escape | Pausar, liberar el ratón / continuar |

El arma y la descarga eligen automáticamente el enemigo más cercano que esté a su alcance y visible. **Retrocede ante los círculos rojos**: anuncian ataques; el círculo grande del guardián anuncia una onda de área. La energía se regenera. No hay inventario ni puertas que abrir.

## Dependencias

Godot **4.7.2 Stable estándar**, portátil, incluido localmente en `tools/godot/`. Forward+ / Vulkan, probado con RX 6600. No requiere .NET, Blender ni instalación global. Si copias el proyecto, copia también esa carpeta: los ejecutables están excluidos de Git.

La voz usa el TTS de Windows si Godot encuentra una voz española; siempre hay subtítulos. Audio y geometría se generan en Godot. El proyecto funciona sin conexión después de preparar el motor.

## Verificación

- `tools/TEST.bat`: pruebas funcionales en modo headless.
- `tools/CAPTURE.bat`: las mismas pruebas con GPU y capturas reales en `screenshots/`.
- `tools/PLAYTEST.bat`: bot que juega usando las reglas normales de combate.
- Los informes están en `tests/*_report.json`; los logs locales, en `tools/logs/`.

Los lanzadores `.bat` no necesitan cambiar la política de ejecución de PowerShell. `tools/QA.ps1` ofrece la misma verificación para terminales de desarrollo que admitan scripts locales.

El lanzador admite opciones adicionales: `PLAY.bat --fullscreen` o `PLAY.bat --rendering-method gl_compatibility` para otro ordenador que no disponga de Vulkan. El segundo modo reduce algunos efectos; no es la configuración verificada principal.
