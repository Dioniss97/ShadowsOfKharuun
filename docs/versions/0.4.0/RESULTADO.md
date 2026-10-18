# Resultado: 0.4.0 integrada y aceptada

16-10-2026. El Vigía VIII está integrado en las dos posiciones de la demo con el mismo GLB, conservando los módulos y sus colisiones. El usuario acepta el asset y autoriza integración/cierre mediante A04-12; A04-13 aprueba expresamente la presentación del nivel. La entrega `v0.4.0`, [PR #29](https://github.com/Dioniss97/ShadowsOfKharuun/pull/29), pasa **213 comprobaciones headless y 238 con GPU, cero fallos**; el comparador conserva las 49 formas físicas y las cámaras de cinco pares de capturas.

Evidencia reproducible, límites, coste observado y aceptación en [QA_0_4_0.md](QA_0_4_0.md). [Comparación del nivel](../../../art/references/vigia_umbral/integration/README.md) y [aprendizajes](APRENDIZAJES_0_4_0.md). Q04-06 autoriza GPL-2.0-or-later solo para los dos scripts Blender. Las reglas jugables de 0.3.0 se conservan; su etiqueta y evidencia siguen inmutables.

## Historial: 0.3.0 con QA humana aprobada

QA humana aprobada el **14 de octubre de 2026** mediante la respuesta del usuario: «Apruebo el QA de la 0.3.0». La candidata aceptada es RC2, commit `f8ada97`, que incorpora D33–D36: conducción del actor, vida solo de la selección, orbe por ratón y HUD compacto. D27 queda sustituida por D33. La [PR #14](https://github.com/Dioniss97/ShadowsOfKharuun/pull/14) está fusionada en `main` (`1304678`), con D01–D36/B1–B8; entrega estable [v0.3.0](https://github.com/Dioniss97/ShadowsOfKharuun/tree/v0.3.0). No se ha recibido un informe humano desglosado por caso ni una nueva medición de duración; se registra la aceptación global expresa.

Abre `PLAY.bat`: el menú identifica **0.3.0**. El cierre cambia únicamente metadatos de versión, textos de menú/título y documentación; las reglas jugables aceptadas son las de RC2. [QA_0_3_0.md](../0.3.0/QA_0_3_0.md) conserva el recorrido humano. Controles en [README.md](../../../README.md), reglas en [COMBATE.md](../0.3.0/COMBATE.md), decisiones en [DISENO_DEMO.md](../0.3.0/DISENO_DEMO.md).

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
| Promoción final | Arranque headless de 0.3.0 con `--quit-after 5`: código 0, sin errores; `git diff --check` correcto. Solo versión, textos y documentación cambiados desde RC2 |

Capturas revisadas: `demo_hud_mixed_targets.png`, `demo_b4_neutral_voice.png`, `demo_b5_contextual_basic.png`, `demo_rc2_orb_hand.png`, cámara/gestos/diálogos y finales. Las copias anchas tienen prefijo `rc2_1920_`, para conservarlas al repetir capturas de 1280×720.

La evidencia automática de la tabla corresponde a RC2 (`f8ada97`), cuyo comportamiento se conserva en 0.3.0. Las pruebas aíslan casos mediante fixtures que pueden colocar/congelar actores o aplicar daño directo a una transición. El bot de partida normal se ejecuta aparte y registra sus condiciones. Sus tiempos son simulados y no predicen duración ni dificultad humana; no son una medición de rendimiento. Las capturas son comprobaciones visuales; la aprobación humana se registra por separado al comienzo de este informe.

Lanzadores: `tools/DEMO_TEST.bat`, `tools/DEMO_CAPTURE.bat` o `tools/QA.ps1`. Suite ancha: Godot `--path . --resolution 1920x1080 --fixed-fps 60 -- --hud-capture`. En el sandbox se redirigió APPDATA a `tools/sandbox-appdata`; no se cambió la configuración global de Windows. Motor, logs, informes y capturas permanecen locales y están excluidos de Git.

## Historial y cierre de versión

RC1 (`22ee5fd`) comprobó 187 casos lógicos, 211 con GPU y 24 capturas. La implementación anterior `b54514e` comprobó 157/179 y la primera integración `2a6cd6b` permanece en Git. Esas cifras y la órbita A/D retirada no aceptan D33–D36.

La aceptación humana global cierra DEMO-10/11 y B1–B8 para esta entrega. PR integrada, 21 issues y milestone cerrados; etiqueta `v0.3.0` identifica la entrega final. El trabajo se detiene hasta definir 0.4. Los costes/daños siguen siendo valores propios provisionales; mapa/universo, multijugador, modelos Blender, escudos, formas, granadas, compañeros, karma y progresión quedan fuera de esta versión.

Engram confirmó lectura exclusiva del proyecto `shadowsofkharuun`. El host no confirmó identidad de sesión para escrituras; la aprobación y el cierre quedan en MD/Git, sin crear otra sesión ni guardar por CLI. Próximo paso tras publicar: esperar la definición humana de 0.4.
