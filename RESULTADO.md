# Resultado: candidata 0.3.0 RC2 para QA humana

Comprobada el 14 de octubre de 2026, versión interna **0.3.0-rc.2**, rama `feature/temple-tactical-demo`. La QA de RC1 llevó a D33–D36: conducción del actor, vida solo de la selección, orbe por ratón y HUD compacto. D27 queda sustituida por D33. El alcance sigue siendo 0.3.0, con B1–B8; la [PR #14](https://github.com/Dioniss97/ShadowsOfKharuun/pull/14) permanece en borrador. No hay merge ni etiqueta final; la última entrega estable es v0.2.0.

Abre `PLAY.bat`: el menú identifica **0.3.0 RC2**. [QA_0_3_0.md](QA_0_3_0.md) propone el recorrido humano. Controles en [README.md](README.md), reglas en [COMBATE.md](COMBATE.md), decisiones en [DISENO_DEMO.md](DISENO_DEMO.md).

## Cambios de esta QA

- A/D gira continuamente al personaje; W lo conduce según su frente y W+A/D describe curvas/círculos. S no invierte el frente. RMB conserva la órbita de cámara en reposo/pausa y el retorno durante desplazamiento. Durante combate el actor encara su destinatario y F libera el movimiento; pausa congela su giro.
- Eliminadas las barras 3D de enemigos. Solo la selección viva/visible tiene nombre y vida, incluso si es neutral. Las acciones ofensivas siguen ocultas fuera del combate. Cambiar selección conserva las órdenes anteriores.
- Abajo izquierda: curación propia primero, botiquines después, huecos futuros desactivados. Menú de aproximadamente **232×84 px**, antes 300×178.
- Cola central de aproximadamente **244×90 px**, antes 608×172: cuatro iconos pendientes, acción actual a la derecha, recuperación y Cancelar debajo. Los destinos aparecen al pasar el ratón. Huecos vacíos quedan en blanco y la acción actual no duplica el primer icono pendiente. Se conserva cancelación individual, limpieza, pausa, capacidad y recursos.
- Retrato y barras verticales de recursos compactos a la derecha. Tarjeta de acción del objetivo de unos 150×72 px y cabecera independiente de nombre/vida. La interfaz deja libre la escena.
- El orbe se reclama con clic y mano: raycast del objeto o pequeño marcador sobre el altar. El marcador mantiene visible la interacción si el propio avatar tapa la esfera. Si está lejos, el personaje se aproxima físicamente; W/S cancela el acercamiento y pausa lo congela. Puerta, resolución del guardián y obstáculos siguen siendo obligatorios; E no reclama el núcleo.

## Evidencia vigente

| Comprobación | Resultado |
|---|---|
| Suite completa sin ventana | **213 comprobaciones, 0 fallos**; `tests/demo_logic_report.json`, `tools/logs/demo-test.log` |
| Suite completa con GPU | **238 comprobaciones, 0 fallos**: los mismos 213 casos y 25 capturas reales de 1280×720; `tests/demo_capture_report.json`, `tools/logs/demo-capture.log` |
| UI/interacción en ventana ancha | **72 comprobaciones, 0 fallos**, 6 capturas de 1920×1080; `tests/demo_hud_capture_report.json`, `tools/logs/demo-hud-wide.log`. Es una suite parcial, no otra partida completa |
| Entradas | Clics reales de selección, voz, órdenes, rueda/flechas, curación/botiquín y orbe/marcador; teclado A/D, W/S, F, RMB, pausa/Escape |
| Flujos | Colas A/B, recursos insuficientes con o sin otras órdenes, ambos contactos de ráfaga, curación con salud llena, persecución/colisiones, pausa, tres ramas del guardián, acceso/final y reinicio |
| Bot normal | Victoria en **98.15 s simulados**, salud **203/340**, **33 acciones**, 4 bajas y 1 botiquín restante |
| Integridad del bot | Estadísticas de producción, movimiento real y órdenes; 0 teletransportes y 0 llamadas de daño directo. Daño recibido 274.5, curación 137.5 |
| Motor | Godot 4.7.2 estándar, Vulkan / Forward+ en RX 6600; suites finales sin errores de scripts o recursos |

Capturas revisadas: `demo_hud_mixed_targets.png`, `demo_b4_neutral_voice.png`, `demo_b5_contextual_basic.png`, `demo_rc2_orb_hand.png`, cámara/gestos/diálogos y finales. Las copias anchas tienen prefijo `rc2_1920_`, para conservarlas al repetir capturas de 1280×720.

Las pruebas aíslan casos mediante fixtures que pueden colocar/congelar actores o aplicar daño directo a una transición. El bot de partida normal se ejecuta aparte y registra sus condiciones. Sus tiempos son simulados y no predicen duración ni dificultad humana; no son una medición de rendimiento. Las capturas son comprobaciones visuales, no una validación humana del usuario.

Lanzadores: `tools/DEMO_TEST.bat`, `tools/DEMO_CAPTURE.bat` o `tools/QA.ps1`. Suite ancha: Godot `--path . --resolution 1920x1080 --fixed-fps 60 -- --hud-capture`. En el sandbox se redirigió APPDATA a `tools/sandbox-appdata`; no se cambió la configuración global de Windows. Motor, logs, informes y capturas permanecen locales y están excluidos de Git.

## Historial y cierre pendiente

RC1 (`22ee5fd`) comprobó 187 casos lógicos, 211 con GPU y 24 capturas. La implementación anterior `b54514e` comprobó 157/179 y la primera integración `2a6cd6b` permanece en Git. Esas cifras y la órbita A/D retirada no aceptan D33–D36.

Falta tu QA humana de RC2: controles, claridad y equilibrio, incluyendo ambas rutas. Con tu aceptación se integra la PR, cierran los issues cubiertos y el milestone, y etiqueta v0.3.0. Después se detiene el trabajo hasta definir 0.4. Sin ampliación de mapa/universo, multijugador, nuevos modelos Blender, escudos, formas, granadas, compañeros, karma ni progresión. Los costes/daños siguen siendo valores propios provisionales.

Engram confirmó lectura exclusiva del proyecto `shadowsofkharuun`. El host no confirmó identidad de sesión para escrituras; decisiones y resumen de este turno quedan en MD/Git, sin crear otra sesión ni guardar por CLI. Próximo paso: recibir QA humana y atender únicamente los defectos de 0.3.0 que reporte.
