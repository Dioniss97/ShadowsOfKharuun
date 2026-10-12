# Resultado: primera iteración táctica

Entrega local del 12 de octubre de 2026. Se han completado los pasos 1–3 del plan: reglas documentadas, corrección de arma y colisiones, y un duelo jugable para validar el núcleo del combate antes de adaptarlo a toda la misión.

Abre `PLAY.bat` y elige **Duelo táctico · nueva iteración**. Empieza pausado: selecciona al centinela con clic o Tab, prepara órdenes y pulsa Espacio. La misión del templo continúa disponible en **Nueva partida · misión original**.

## Cambios comprobados

- Espada orientada hacia delante, postura de combate y animación con preparación, contacto y recuperación. La locomoción conserva la orientación durante el golpe.
- Jugador y enemigos sólidos: el movimiento físico ya no permite atravesar al adversario. Se mantienen accesibles el patio, el umbral y la rampa del templo.
- Impacto diferido durante la animación, comprobado una sola vez y sujeto a alcance y visibilidad. La misión original también utiliza impacto diferido para el arma.
- Duelo en tiempo real con pausa y relojes propios por combatiente. Una acción activa y hasta cuatro órdenes pendientes, cancelables; cada orden conserva su objetivo.
- Selección con clic o Tab, aproximación física al objetivo, ataque básico automático con cola vacía, retirada y movimiento manual que interrumpe el enfrentamiento.
- Empuje, descarga y defensa; energía cobrada al ejecutar, recargas, tiradas de acierto y crítico. Empuje interrumpe el golpe enemigo preparado y evita impactos posteriores invisibles.
- Interfaz para objetivo, acción, recuperación, cola y resultados. Espacio congela movimiento, daño, energía y relojes, pero permite preparar órdenes. Escape conserva la pausa táctica al cerrar su menú.
- Victoria, derrota, repetición del duelo y regreso al menú. Controles y reglas en [README.md](README.md) y [COMBATE.md](COMBATE.md).

## Evidencia de verificación

| Comprobación | Resultado / evidencia local |
|---|---|
| Duelo, sin ventana | 56 comprobaciones, 0 fallos; `tests/tactical_logic_report.json`, `tools/logs/tactical-test.log` |
| Duelo, con GPU | 60 comprobaciones, 0 fallos; `tests/tactical_capture_report.json`, `tools/logs/tactical-capture.log` |
| Capturas del duelo | Cuatro PNG reales de 1280 × 720; pausa, ataque frontal, vista lateral y victoria en `screenshots/tactical_*.png`; inspeccionados visualmente |
| Partida normal del duelo | Victoria en 36,62 s simulados, 13 acciones del jugador, 11 ataques enemigos y 276 de salud restante; incluido en ambos informes tácticos |
| Regresión de la misión original | 34 comprobaciones sin ventana y 43 con GPU, 0 fallos; `tests/logic_report.json`, `tests/capture_report.json` |
| Partida normal de la misión original | Victoria con 4 bajas, 111 ataques básicos, 34 habilidades y 166,27 s totales; `tests/playthrough_report.json` |
| Controles reales dentro de Godot | Eventos de clic sobre enemigo y botones de habilidades, teclado, autorepetición, pausa y arrastre de cámara con botón derecho |
| Reloj de rondas | Mismo orden e impactos con pasos simulados a 30, 60 y 144 Hz; no constituye una medición de rendimiento |
| Motor y GPU | Godot 4.7.2 estándar portátil; Vulkan / Forward+ en Radeon RX 6600; procesos de prueba terminados con código 0 y sin errores de scripts o recursos |

Los tests de estados usan daño directo para comprobar señales y transiciones. Las partidas completas del bot son pruebas separadas: utilizan movimiento, órdenes, ataques y habilidades con salud, daño y recargas normales. No equivalen a una evaluación humana de dificultad.

## Correcciones encontradas durante la verificación

Se corrigieron la colocación inicial de cuerpos antes de registrarse en física, la selección al comenzar pausado, los golpes enemigos a través de obstáculos y el impacto pendiente tras un empuje. Los controles de la interfaz ignoran la repetición de teclas y no capturan Espacio como una segunda pulsación de botón. Los tests comprueban estos casos.

La entrada automatizada se transforma entre coordenadas de ventana y viewport para que el clic sea válido tanto con GPU a 1280 × 720 como en el modo sin ventana. Las capturas proceden del renderizado real de Godot.

## Alcance y siguiente iteración

El combate táctico se aplica por ahora a **un duelo contra el centinela**. Sus valores son ajustes propios de Kharuun inspirados en la estructura de KOTOR; no una reproducción completa de sus reglas. La misión original conserva su combate de acción, con las correcciones compartidas de arma y física.

Tu primera partida de la misión original duró **4 min 18 s**, según tu prueba. El duelo nuevo aún necesita esa evaluación humana para ajustar ritmo, claridad y dificultad; sus 36,62 s corresponden al bot y a un solo enemigo.

Los personajes siguen siendo modelos procedurales simples. Esta iteración mejora la orientación y la postura, pero no añade modelos Blender, compañero, nuevas zonas ni universo ampliado. El siguiente paso es afinar este duelo con la prueba humana y trasladar el sistema validado a los encuentros de la misión; después se avanzará con modelos, animaciones y contenido.

No se necesita instalar Blender para ejecutar esta entrega. Se utiliza el Godot portátil de `tools/godot/`, sin conexión. Código y documentación se guardan en Git local; informes, capturas, logs y ejecutables permanecen disponibles en el ordenador y se excluyen del historial.
