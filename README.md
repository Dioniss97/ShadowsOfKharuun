# Shadows of Kharuun

Haz doble clic en **PLAY.bat**. Abre el juego directamente; no necesitas abrir el editor. **Duelo táctico · nueva iteración** prueba el combate con rondas y órdenes. **Nueva partida · misión original** conserva el asalto completo al templo.

Versión jugable actual: **0.2.0**, identificada por la etiqueta Git `v0.2.0`. Historial de entregas en [CHANGELOG.md](CHANGELOG.md) y rutina de trabajo en [ORGANIZACION.md](ORGANIZACION.md).

La segunda vuelta, prevista como **0.3.0**, está en fase de diseño. Sus decisiones están guardadas en [DISENO_DEMO.md](DISENO_DEMO.md) y las tareas en [PENDIENTES.md](PENDIENTES.md); los controles de abajo corresponden a la entrega que puedes jugar ahora.

## Duelo táctico

El duelo comienza pausado. Haz clic en el centinela o pulsa Tab, prepara órdenes y pulsa Espacio para reanudar. Cada combatiente tiene su propio ritmo; el enemigo no espera a que des órdenes. Al vaciarse la cola, tu personaje continúa con ataques básicos automáticos contra su objetivo.

| Control | Acción en el duelo |
|---|---|
| Clic izquierdo sobre enemigo / Tab | Seleccionar objetivo |
| Botón derecho mantenido + ratón | Girar cámara |
| Espacio | Pausa táctica; puedes preparar y cancelar órdenes |
| 1 / 2 / 3 / 4 | Encolar empuje / descarga / ataque / defensa |
| Clic sobre orden pendiente | Cancelar esa orden |
| F / botón Retirarse | Detener ataque automático y cancelar órdenes |
| WASD | Mover manualmente e interrumpir el enfrentamiento |
| Escape | Menú de pausa |

Hay una acción en ejecución y hasta cuatro pendientes. El personaje se acerca para alcanzar al objetivo; el impacto se resuelve durante la animación y puede fallar por precisión, defensa, obstáculos o distancia. Los poderes cobran energía al ejecutarse y conservan sus recargas. Una habilidad que espera recarga mantiene su lugar en la cola. Defensa protege durante dos rondas. Cambiar de objetivo conserva el destinatario de las órdenes ya pendientes.

El duelo es una prueba corta del núcleo táctico de los pasos 1–3. Las reglas concretas están en [COMBATE.md](COMBATE.md). El equilibrio de tres acólitos y jefe con este sistema, los modelos Blender y el compañero corresponden a las siguientes iteraciones.

## Misión original

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
- `tools/TACTICAL_TEST.bat`: pruebas de rondas, órdenes, controles y bot del duelo.
- `tools/TACTICAL_CAPTURE.bat`: esas pruebas con GPU y cuatro capturas del duelo.
- Los informes están en `tests/*_report.json`; los logs locales, en `tools/logs/`.

Los lanzadores `.bat` no necesitan cambiar la política de ejecución de PowerShell. `tools/QA.ps1` ofrece la misma verificación para terminales de desarrollo que admitan scripts locales.

El lanzador admite opciones adicionales: `PLAY.bat --fullscreen` o `PLAY.bat --rendering-method gl_compatibility` para otro ordenador que no disponga de Vulkan. El segundo modo reduce algunos efectos; no es la configuración verificada principal.
