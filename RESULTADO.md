# Resultado de la sesión

Entrega local del 12 de octubre de 2026. **Demo jugable completa**, con Godot 4.7.2 estándar portátil y lanzador `PLAY.bat`. No necesita abrir el editor ni conectarse a Internet.

## Funcionalidad implementada y comprobada

- Menú → exploración → diálogo → tres acólitos → guardián → victoria.
- Derrota, reinicio, repetición de misión, vuelta al menú y pausa que detiene la IA.
- Movimiento con WASD, cámara con ratón, carrera, colisiones, bordes seguros y escalera con rampa física independiente de los escalones visuales.
- Humanoides procedurales, arma luminosa, ataque básico, empuje y descarga. Alcance y visibilidad limitan los ataques; energía y cooldowns limitan habilidades.
- Enemigos con persecución, separación, ataques anunciados, daño, barras de salud y muerte. El guardián tiene más salud y una onda de área.
- Tres respuestas distintas del guardián y elección registrada; diálogo sin agresión. Textos en español.
- HUD de salud, energía, habilidades, objetivo, enemigo cercano y tiempo; pantallas finales.
- Patio principal de 40 × 55 m, templo elevado, dos estatuas, columnas, obeliscos, banderas, braseros, horizonte, cielo procedural, iluminación, niebla y efectos originales.

## Evidencia de verificación

| Comprobación | Resultado / evidencia local |
|---|---|
| Motor oficial | `--version`: 4.7.2.stable.official.ed1daf0bf; SHA256 y SHA512 verificados; firma Authenticode **Valid**, Prehensile Tales B.V. |
| Importación final | Código de salida 0, sin errores de scripts o recursos; `tools/logs/import-final.log` |
| Pruebas headless | 33 comprobaciones; `tests/logic_report.json`, `tools/logs/logic.log` |
| Pruebas con GPU | 42 comprobaciones, incluidas entrada de teclado, cámara con ratón y límites del panel de diálogo; `tests/capture_report.json` |
| Capturas reales | Ocho PNG de 1280 × 720 en `screenshots/`, obtenidos tras `RenderingServer.frame_post_draw` e inspeccionados visualmente |
| Partida con reglas normales | Victoria: 4 bajas, 86 ataques básicos, 28 usos de habilidad, 142,13 s totales; `tests/playthrough_report.json` |
| Renderizador real | Vulkan 1.4.315 / Forward+ en AMD Radeon RX 6600; `tools/logs/capture.log` |
| Rendimiento orientativo | Muestra de menú a 1920 × 1080: 165 FPS, 6,06 ms por fotograma, con VSync. Prueba breve, no benchmark sostenido del combate; `tools/logs/performance.log` |
| Hardware efectivo | Ryzen 5 3600, RX 6600 y aproximadamente 32 GB RAM; `tools/hardware.json` |
| TTS | Se encontró la voz española **Pablo** y se invocó el TTS con su identificador real. Siempre hay subtítulos. No se ha validado la audición humana |

El test de estados usa daño directo para comprobar señales de muerte y transiciones. **La partida del bot es una prueba separada**: se mueve, esquiva, ataca y usa habilidades normales, sin cambiar salud, daño o cooldowns. La victoria de esa partida confirma que el jefe puede derrotarse bajo las reglas de juego.

## Fallos encontrados y corregidos

La primera importación detectó una constante incorrecta del entorno; se retiró la asignación redundante. La revisión gráfica detectó niebla que ocultaba el cielo, barras de enemigo detrás de su fondo y escaso margen inferior en el diálogo; se corrigieron y se repitieron las pruebas. Un aviso de recursos de audio al cerrar headless se resolvió evitando reproducir audio en ese modo. Las comprobaciones finales no presentan errores críticos conocidos.

## Límites y calidad alcanzada

La calidad alcanzada es la de un **prototipo 3D estilizado de geometría simple**, con composición monumental, cielo, sombras, partículas y brillo. Los personajes y el terreno siguen siendo visiblemente procedurales; no alcanza el acabado de un RPG comercial de 2010–2013.

La ruta optimizada del bot dura 2 min 22 s. El objetivo de 3–7 minutos para una primera partida humana es orientativo y **no se ha confirmado con jugadores humanos**. El bot conoce exactamente los anuncios de ataque y esquiva mejor que un jugador nuevo.

No se ha realizado una partida humana manual completa. Se verificaron eventos de teclado y ratón dentro de Godot, movimiento físico, lógica y capturas reales. No hay exportación Windows independiente del motor; el lanzador utiliza el ejecutable portátil incluido. El fallback OpenGL está disponible por opción de lanzamiento, pero no se ha certificado en esta sesión.

Las mejoras posteriores serían modelos y animaciones más elaborados, terreno menos angular, sonido espacial y ajuste de dificultad y duración con jugadores. No se ha añadido una segunda misión ni sistemas ajenos al alcance solicitado.
