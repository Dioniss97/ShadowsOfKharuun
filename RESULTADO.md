# Resultado: demo táctica unificada en desarrollo

Build local del 12 de octubre de 2026, rama `feature/temple-tactical-demo`, prevista como **0.3.0**. El usuario autorizó producir tras revisar D01–D24 y las 13 issues. La última etiqueta estable sigue siendo `v0.2.0`; no se etiqueta una 0.3.0 final mientras Q01 y la aceptación humana estén pendientes. El informe histórico del duelo separado está conservado en `v0.2.0:RESULTADO.md`.

Base de la implementación: commit `2a6cd6b`; correcciones B1/B2 en este mismo árbol y [PR borrador #14](https://github.com/Dioniss97/ShadowsOfKharuun/pull/14). Esta build se ha subido a su rama; main y las etiquetas estables permanecen conservados.

Abre `PLAY.bat` y elige **Nueva partida · asalto al templo**. La misión completa usa el combate táctico. El duelo permanece accesible con `PLAY.bat --duel` como herramienta interna.

## Qué se puede probar

- Exploración, diálogo inicial, tres acólitos, diálogo ramificado del guardián, combate o acuerdo pacífico, entrada al templo y reclamación del núcleo con E. Resolver al guardián habilita el paso; la misión termina al reclamar el núcleo.
- Una acción actual y cuatro órdenes pendientes. Cada orden conserva su destinatario; `1A, 2B, 2A` continúa con básico automático A aunque la selección de interfaz sea B. Curación y botiquín actúan sobre el protagonista.
- Selectores de básico/ráfaga y empuje/descarga/curación mediante flechas o rueda; clic encola. Arrojadizos, escudo y formas quedan visibles y desactivados. Tres botiquines iniciales con contador.
- Recursos consumidos al ejecutar, sin recargas adicionales por poder. Curar con salud llena también consume ronda y recurso. Cancelar una orden pendiente conserva el recurso; F durante una acción iniciada corta el efecto pendiente sin devolver el gasto ya realizado.
- Ráfaga con dos contactos y tiradas dentro de una ronda; mano izquierda para poderes, descarga desde la palma y curación verde. Espada en mano derecha orientada hacia delante, cuerpos sólidos e impactos sujetos a alcance y visibilidad.
- Pausa inicial una vez por encuentro, preparación de órdenes durante pausa y WASD bloqueado hasta F. B1 conserva órbita al soltar RMB quieto/pausado y recentra solo al desplazarse; W/S mantiene el frente y A/D gira continuamente, con arcos/círculos al combinar con W. Los enemigos siguen persiguiendo por la zona accesible.
- B2 reemplaza los selectores fijos centrales por una tarjeta compacta (~198 × 119 px) sobre el enemigo seleccionado. Sigue actor/cámara, deja la cara libre y se oculta fuera de combate, tras F y con objetivos no visibles/válidos. Nombre y vida forman parte de esa tarjeta.
- Recursos conservados entre acólitos y guardián; diálogos con tiempo/recursos congelados. Ruta pacífica con guardián vivo y no agresivo. Derrota reinicia toda la misión y sus recursos/decisiones.

## Evidencia de esta build

| Comprobación | Resultado y evidencia local |
|---|---|
| Suite de misión, sin ventana | **157 comprobaciones, 0 fallos**; `tests/demo_logic_report.json` |
| Suite con GPU | **179 comprobaciones, 0 fallos**; `tests/demo_capture_report.json`, `tools/logs/demo-capture.log` |
| Renderizado | Godot 4.7.2 estándar; Vulkan / Forward+ en Radeon RX 6600; sin errores de scripts o recursos |
| Entradas reales | Clic en iconos/órdenes/retirada, flechas, rueda, teclado, WASD, F, Espacio/Escape y botón derecho; comprobados en Godot sin ventana y con GPU |
| Rondas | Dos impactos por ráfaga, una ronda, interrupción entre contactos y resultados iguales con pasos de 30/60/144 Hz; no es una medición de rendimiento |
| Narrativa | Rechazo, lección seguida de ataque y lección seguida de acuerdo. Tres finales completados mediante acceso y reclamación real, sin victoria anticipada |
| Bot de partida normal | Victoria en **106,67 s simulados**, salud final **312/340**, **36 acciones resueltas**, 4 bajas, 0 botiquines restantes; `tests/demo_playthrough_report.json` |
| Integridad del bot | 0 teletransportes y 0 llamadas de daño directo; estadísticas de producción, movimiento real y órdenes. Daño recibido 317,5 y curación observada 289,5 |
| Capturas reales | 22 PNG de 1280 × 720 en `screenshots/demo_*.png`; HUD con destinatarios, gestos/contactos, diálogo, interior, rutas y final. Además `ui_v03_*.png` para menú/ayuda/cola; inspeccionados visualmente |

Los fixtures aislados pueden congelar o colocar actores y aplicar daño directo para comprobar una transición. La partida normal se ejecuta aparte y deja constancia de estadísticas, movimiento, acciones, recursos y eventos. La victoria del bot no sustituye la evaluación humana de dificultad ni significa que un jugador tardará 106,67 s.

Lanzadores: `tools/DEMO_TEST.bat` y `tools/DEMO_CAPTURE.bat`; los lanzadores anteriores son alias de esa suite, incluido su bot normal. `tools/QA.ps1` usa el mismo marcador `KHARUUN_DEMO_RESULT`. Los runners y el motor de acción sustituidos se retiraron de esta rama y siguen disponibles en las etiquetas históricas.

## Fallos resueltos al verificar

- Cronómetro que heredaba el procesamiento durante pausa: la misión ahora se congela junto con física y recursos.
- El primer control lateral de rumbo fijo se sustituye tras la prueba humana B1: A/D ahora gira de forma continua y W+A/D describe círculos intencionales; S mantiene el frente. La órbita deja de retornar por sí sola estando quieto/pausado.
- HUD que aún consultaba recargas retiradas, solape de flechas con el panel de pausa y textos de selección confundidos con el destinatario de la próxima orden.
- Reentrancia cuando el último impacto abre el diálogo y resetea la cola; los impactos siguientes no continúan después de detener el encuentro.
- Altar oculto por el protagonista al acercarse: marcador de núcleo y E visible en el interior.

El helper de prueba de rueda debía emitir también la liberación del botón: dejarlo pulsado retenía el foco GUI e invalidaba clics posteriores. Se corrigió el helper; no se simuló el resultado llamando directamente a las señales del HUD.

Durante B2 se corrigió un fallo real de interacción: ocultar y mostrar el panel en cada fotograma cancelaba el estado del botón antes de soltarlo. El panel conserva su visibilidad mientras el objetivo siga válido y solo se oculta cuando corresponde. Las pruebas realizan clics y rueda reales contra A/B. Los fixtures que recolocan actores pausados sincronizan también sus colliders antes de probar selección, y convierten el desplazamiento del ratón entre ventana y viewport; no llaman a las señales de selección para simular un éxito.

El aviso de pausa se redujo y trasladó a una esquina para dejar libre también el centro de la escena y las caras. Si coincide con la tarjeta de objetivo se oculta el aviso opcional; el botón Reanudar de la cola conserva la indicación de pausa. Las regresiones B1/B2 comprueban órbita en reposo/pausa, retorno durante movimiento, retroceso, giro continuo, arcos, anclaje y ocultación, además de la misión normal.

## Pendientes antes de la entrega final

**Q01 no está resuelta.** Si una orden llega sin energía, esta build conserva la orden y pausa el mundo sin consumir recurso ni decidir una penalización o salto de cola. Cancela esa orden o pulsa F y reanuda para continuar probando. Es una protección temporal de desarrollo; se sustituirá por la regla definitiva cuando llegue la prueba del usuario en KOTOR.

Falta la prueba humana de comprensión y equilibrio, especialmente con tres enemigos, curación y retirada. Los daños, costes y duraciones son provisionales propios de Kharuun. Personajes procedurales simples; no hay nuevos modelos Blender, formas, escudos, arrojadizos, compañero, karma o progresión.

Engram lee el proyecto correctamente, pero el hook todavía rechaza escrituras por vínculo de sesión no confirmado. Se conservan acuerdos y trabajo en los MD y GitHub; no se elude ese bloqueo ni se modifican memorias ajenas. Logs, capturas, informes y motor portátil permanecen locales y están excluidos de Git.
