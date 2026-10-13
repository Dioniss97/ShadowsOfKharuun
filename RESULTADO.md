# Resultado: candidata 0.3.0 para QA humana

Comprobada el 13 de octubre de 2026, rama `feature/temple-tactical-demo`, versión interna **0.3.0-rc.1**. D01–D32 y B1–B6 están implementados y verificados en rama. Falta la aceptación humana de claridad, ritmo y equilibrio. La [PR #14](https://github.com/Dioniss97/ShadowsOfKharuun/pull/14) sigue en borrador; no hay merge ni etiqueta final `v0.3.0`. La última entrega estable es `v0.2.0`.

Abre `PLAY.bat` y elige **Nueva partida · asalto al templo**. El menú identifica la candidata. Recorrido de prueba humana en [QA_0_3_0.md](QA_0_3_0.md), controles en [README.md](README.md), reglas en [COMBATE.md](COMBATE.md).

## Comportamientos comprobados

- B1: A/D orbita cámara en reposo, pausa y combate sin mover al actor; W sigue la vista, S conserva el frente. Arrastre RMB persistente al soltar y retorno durante desplazamiento. Las pruebas antiguas de A/D girando al personaje fueron sustituidas por D27.
- B2: tarjeta compacta (~198 × 119 px) sobre el enemigo seleccionado, seguimiento de actor/cámara, nombre/vida coherentes y cara libre. Se oculta fuera de combate, tras F o con selección inválida/oculta.
- B3: sin órdenes y fuera de alcance cuerpo a cuerpo, protagonista quieto. Básico automático al entrar el enemigo en alcance; órdenes explícitas sí permiten acercarse. Los agresores mantienen sus relojes y persecución.
- B4: primer clic selecciona un neutral, segundo sobre actor/icono de voz inicia interacción. Acólitos con tres frases rotativas. Primera conversación del guardián automática al acercarse; después de los acólitos, espera hasta volver a hablar por clic. Puerta/orbe bloqueados hasta acuerdo o derrota. Sin voz disponible, los subtítulos permiten completar el flujo.
- B5: retícula segmentada y cursor propio; hover normal en no seleccionado, espada en hostil seleccionado y clic que encola básico al destinatario. Órdenes anteriores y sus objetivos conservados.
- B6: selectores inferiores independientes para consumibles y curación propia; el selector sobre el enemigo contiene solo poderes ofensivos/de control. Botiquín agotado pierde su icono y se distingue de huecos futuros. Rueda/flechas recorren sin encolar.
- D31: disponibilidad por energía; gasto al ejecutar; retirada de poderes o botiquines impagables y órdenes de su categoría. Si queda otra válida, ocupa esa oportunidad sin perder ronda; si no, recuperación de una ronda y básico posterior, sujeto al alcance. No hay pausa provisional Q01.
- Misión completa, destinos A/B, ráfaga con dos contactos y tiradas, curación con salud llena, cancelación y recursos, pausa/Escape, colisiones, gestos/efectos, las tres ramas del guardián, final común y reinicio.

## Evidencia vigente

| Comprobación | Resultado |
|---|---|
| Suite sin ventana | **187 comprobaciones, 0 fallos**; `tests/demo_logic_report.json`, `tools/logs/demo-test.log` |
| Suite con GPU | **211 comprobaciones, 0 fallos**: los mismos 187 casos más 24 capturas reales; `tests/demo_capture_report.json`, `tools/logs/demo-capture.log` |
| Motor y renderizado | Godot 4.7.2 estándar, Vulkan / Forward+ en RX 6600; sin errores de scripts o recursos en las suites finales |
| Entradas de prueba | Eventos reales de teclado/ratón inyectados en Godot: clic de actor/voz/órdenes, flechas, rueda, RMB, A/D, W/S, F, Espacio, Escape y E final |
| Gráficos | 24 PNG de 1280 × 720; revisión visual del HUD personal/ofensivo, retícula/voz, órbita, poderes, diálogos, interior y finales |
| Bot de partida normal | Victoria en **98.10 s simulados**, **203/340 salud**, **33 acciones**, **4 bajas**, **1 botiquín restante** |
| Integridad del bot | Estadísticas de producción, movimiento real y órdenes; 0 teletransportes y 0 llamadas de daño directo. Daño recibido 274.5, curación observada 137.5 |

Las capturas e informes permanecen locales y están excluidos de Git. Ejemplos: `demo_hud_mixed_targets.png`, `demo_b4_neutral_voice.png`, `demo_b5_contextual_basic.png`, `demo_b1_paused_orbit.png`, gestos `demo_cast_*.png` y finales `demo_final_*.png`.

La suite usa fixtures aislados que pueden colocar/congelar actores o aplicar daño directo para probar una transición; el bot normal se ejecuta aparte y deja constancia de sus condiciones. Los tiempos simulados no predicen la duración de una partida humana ni miden rendimiento. La victoria del bot no sustituye tu evaluación de dificultad.

Para reproducir: `tools/DEMO_TEST.bat`, `tools/DEMO_CAPTURE.bat` o `tools/QA.ps1`. En el sandbox del agente se dirigió APPDATA a `tools/sandbox-appdata` para permitir los datos locales de Godot; no se cambió la configuración global de Windows.

## Fallos corregidos durante esta verificación

- La acción impagable ya no bloquea la build en la pausa provisional; se aplica D31 en colas simples y mixtas.
- El icono de voz no oculta/muestra su botón cada fotograma: hacerlo cancelaba la pulsación antes de soltar el ratón. Conserva su visibilidad mientras siga válido.
- El cursor usa coordenadas de eventos del viewport, coherentes tanto con ratón físico como con entradas de prueba; antes podía permanecer normal sobre la selección.
- El segundo diálogo espera al clic y mantiene acceso cerrado. La interacción de voz no se ofrece mientras el encuentro de los acólitos sigue activo; al entrar en diálogo se retira la frase neutral anterior.

Evidencia previa: `2a6cd6b` (integración) y `b54514e` (B1 anterior/B2) conservados en Git. Las cifras 157/179, 22 capturas y 106,67 s del bot pertenecen a aquella build, no a esta candidata.

## Cierre pendiente y límites

Falta tu QA con [QA_0_3_0.md](QA_0_3_0.md). Con aceptación se integra la PR, cierran los issues cubiertos y milestone, y etiqueta v0.3.0. Después se detiene el trabajo hasta definir 0.4. Costes, daños y duraciones siguen siendo ajustes propios provisionales; personajes procedurales, sin escudos, formas, arrojadizos, compañeros, karma, progresión ni nuevos modelos Blender.

Engram confirmó el proyecto por MCP con consulta limitada a `shadowsofkharuun`. El host no confirmó una identidad de sesión para escrituras, por lo que este turno conserva decisiones y resumen en los MD/Git; no intenta crear otra sesión ni guardar por CLI. El siguiente paso es exclusivamente recibir QA humana y atender los defectos que reporte.
