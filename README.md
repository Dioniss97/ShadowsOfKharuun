# Shadows of Kharuun

En esta rama se puede probar la candidata **0.5.0-dev**: personaje Blender, ropa base, uniforme completo y pantalla de inventario con **I**. Ejecutar PLAY.bat, iniciar partida y usar Equipar/Retirar. La [galería de producción](art/references/character/README.md) contiene capturas y evidencia; la aceptación artística/jugable se registra en [#35–#38](https://github.com/Dioniss97/ShadowsOfKharuun/milestone/3). La versión estable publicada sigue siendo v0.4.0.

Haz doble clic en **PLAY.bat** y elige **Nueva partida · asalto al templo**. La demo incorpora el **Vigía del Umbral** en ambas posiciones del patio, con un pipeline reproducible Blender–Godot. Evidencia en [QA_0_4_0.md](docs/versions/0.4.0/QA_0_4_0.md) y [comparación dentro del nivel](art/references/vigia_umbral/integration/README.md). Tras derrotar a los tres acólitos, puedes combatir al guardián o escuchar su doctrina y obtener paso pacífico; en ambas rutas debes entrar y reclamar el núcleo del templo para completar la demo.

Versión estable: **[v0.4.0](https://github.com/Dioniss97/ShadowsOfKharuun/tree/v0.4.0)**, [PR #29](https://github.com/Dioniss97/ShadowsOfKharuun/pull/29), con presentación integrada aprobada por el usuario el 16 de octubre de 2026. Conserva las reglas de misión/combate de 0.3.0 y añade el primer asset artístico y su pipeline. La entrega anterior y su [QA](docs/versions/0.3.0/QA_0_3_0.md) conservan la etiqueta inmutable [v0.3.0](https://github.com/Dioniss97/ShadowsOfKharuun/tree/v0.3.0).

Repositorio público intencionalmente: [Dioniss97/ShadowsOfKharuun](https://github.com/Dioniss97/ShadowsOfKharuun). Decisiones de esta entrega en [DISENO_0_4_0.md](docs/versions/0.4.0/DISENO_0_4_0.md) y seguimiento en [GitHub Issues y milestone 0.4.0](https://github.com/Dioniss97/ShadowsOfKharuun/milestone/2). Las decisiones de 0.3.0 están en [DISENO_DEMO.md](docs/versions/0.3.0/DISENO_DEMO.md), su seguimiento histórico en [PENDIENTES.md](docs/versions/0.3.0/PENDIENTES.md). Procedimiento vigente en [GESTION_DESARROLLO.md](docs/project/GESTION_DESARROLLO.md) y evidencia de la entrega estable en [RESULTADO.md](docs/versions/0.4.0/RESULTADO.md).

## Controles de la misión unificada

| Control | Acción |
|---|---|
| W / S | Avanzar / retroceder manteniendo el frente, durante exploración o tras cancelar combate |
| A / D | Girar continuamente al personaje durante movimiento libre; W+A/D describe curvas o círculos |
| Shift | Correr durante movimiento libre |
| Botón derecho mantenido + ratón | Orbitar la cámara; al soltar conserva la vista estando quieto o pausado. Se recentra suave y rápido solo al desplazarte |
| Clic izquierdo sobre personaje / Tab | Primer clic selecciona; sobre el hostil seleccionado, segundo clic encola básico. Tab recorre agresores |
| Segundo clic sobre neutral seleccionado / icono de voz | Acercarse y hablar: frase de acólito o conversación del guardián |
| Flechas o rueda sobre un selector | Recorrer ataques o poderes sin encolar nada |
| Clic sobre el icono del selector | Añadir su acción contra la selección actual; curación siempre actúa sobre ti |
| 1 / 2 | Encolar empuje / descarga |
| 3 / 4 | Encolar básico / ráfaga |
| 5 / 6 | Encolar curación propia / botiquín |
| Clic sobre una orden pendiente | Cancelar esa orden |
| Limpiar cola | Retirar todas las órdenes pendientes; continúa la acción actual |
| F / Cancelar combate | Detener órdenes y ataque automático; recuperar WASD |
| Espacio | Pausa táctica; seleccionar y preparar órdenes mientras el mundo está congelado |
| E / Intro durante diálogo | Continuar una respuesta; también puedes pulsar el botón |
| Clic sobre el orbe con cursor de mano | Acercarse y reclamar el núcleo; W/S cancela el acercamiento |
| 1, 2, 3 o ratón durante diálogo | Elegir entre las respuestas disponibles |
| Escape | Menú de pausa / continuar |

Durante el combate automático, **WASD conserva las órdenes y el personaje encara a su destinatario**. Pulsa F primero para desplazarte libremente. Los enemigos siguen atacando y persiguen por toda la zona accesible. En exploración, W/S también cancela la aproximación iniciada para hablar con un NPC.

Los tres selectores son una tarjeta compacta sobre el enemigo seleccionado y siguen su posición y la cámara. Se muestran durante el enfrentamiento, incluso en pausa táctica, y se ocultan al cancelar con F o fuera del combate. Si el enemigo no está visible, la tarjeta se oculta en lugar de quedarse en el centro.

## Selección, cola y recursos

Cada combatiente tiene su propia ronda. El primer encuentro con los acólitos y el encuentro con el guardián empiezan pausados una sola vez, con selección automática de un agresor visible y alcanzable. La ayuda inicial se puede omitir; Espacio permite reanudar o pausar de nuevo.

Hay una acción en curso y **cuatro órdenes pendientes**, representadas por iconos compactos; al pasar el ratón aparece acción y destinatario, y clicar una pendiente la cancela. Los tres selectores de arriba son categorías —arma, energía y arrojadizos—; no son las ranuras de la cola. La acción actual queda a la derecha de las pendientes y cada orden conserva el enemigo al que se dirigió cuando la añadiste. La vida aparece solo sobre el seleccionado, también neutral; no hay barras 3D sobre todos los enemigos. Cambiar la selección sirve para preparar la siguiente orden.

Al terminar la cola, el básico automático sigue contra el último enemigo al que ejecutaste una acción ofensiva. Por ejemplo, `básico A → descarga B → ráfaga A` continúa con `básico A`, aunque después selecciones B. Curarte conserva ese destinatario. Si muere y no quedan órdenes válidas, se elige otro agresor vivo, visible y alcanzable, sin otra pausa inicial. **Con cola vacía, el protagonista espera quieto hasta que ese enemigo entra en alcance cuerpo a cuerpo**; una orden explícita sí permite aproximarse.

La ráfaga tiene dos intentos de impacto independientes en una sola ronda. Los poderes disponibles son empuje, descarga y curación propia; cuestan energía y una acción, **sin recarga adicional**. El botiquín y la curación energética usan la misma cola. Empiezas con **tres botiquines**, con contador en el menú inferior izquierdo.

El recurso se consume al comenzar a ejecutar la orden, no al añadirla. Cancelar una orden pendiente lo conserva; cancelar una acción que ya empezó no devuelve el recurso. Curarte con salud completa también consume acción y recurso. Curación propia y botiquín están en selectores separados abajo a la izquierda, en ese orden; al agotarse botiquines desaparece su icono y aparece «Agotado».

Un poder sin energía suficiente se muestra gris y no se puede encolar. Si al ejecutarse una orden ya no tiene recursos, se elimina junto con las demás pendientes del mismo recurso. Si quedan otras órdenes válidas, la siguiente usa esa oportunidad sin perder ronda. Si no queda ninguna, se pierde una ronda y el básico automático vuelve en la siguiente. Los relojes de los combatientes siguen siendo independientes.

Escudo, formas y arrojadizos aparecen como huecos vacíos desactivados. Ataque crítico, ataque fuerte, granadas, formas, bloqueos entre sables, inventario completo y progresión quedan para otra vuelta. Defensa se conserva como estadística pasiva de acierto; no es una orden seleccionable.

## Diálogo y final

En exploración, selecciona y habla con acólitos neutrales: rotan tres frases en orden. Acercarte al guardián inicia automáticamente la primera conversación, cuyo desenlace es el encuentro con los acólitos. Después de derrotarlos, vuelves a seleccionar al guardián y a usar la voz para abrir la segunda conversación; mientras tanto la puerta sigue cerrada. Rechazar inicia combate; escuchar permite aceptar paso pacífico o atacarlo. La ruta pacífica conserva al guardián vivo y no agresivo. La lección tiene efecto narrativo: no hay karma, afiliación persistente ni nuevos poderes aprendidos.

La conversación congela tiempo, movimiento, daño y regeneración. Conservas salud, energía y botiquines entre encuentros, sin regalo automático. Resolver al guardián abre el acceso al templo; la victoria solo llega al reclamar el núcleo con clic y cursor de mano. Tras morir, reinicias toda la misión con recursos iniciales, tres botiquines y elecciones restablecidas.

## Aceptación y cierre

El usuario aprobó expresamente la presentación integrada de 0.4.0. La entrega pasa **213 comprobaciones headless y 238 con GPU, cero fallos**; [QA_0_4_0.md](docs/versions/0.4.0/QA_0_4_0.md) registra por separado pruebas y aceptación visual global. Los dos scripts Blender se publican bajo GPL-2.0-or-later conforme a Q04-06; el [aviso de alcance](tools/blender/LICENSE-scripts.md) identifica esos archivos. Los [aprendizajes artísticos y técnicos](docs/versions/0.4.0/APRENDIZAJES_0_4_0.md) quedan documentados.

## Dependencias y verificación

Godot **4.7.2 Stable estándar**, portátil, está incluido localmente en `tools/godot/`. Forward+ / Vulkan, con RX 6600 como GPU de prueba. Blender 5.2.2 LTS se usa solo para editar o regenerar el modelo del Vigía; no es necesario para ejecutar el juego. Los ejecutables y archivos de caché están excluidos de Git: al copiar el proyecto a otro equipo, hay que preparar el motor.

La voz usa el TTS de Windows si Godot encuentra una voz española; siempre hay subtítulos. El audio y el resto de geometría se generan en Godot; las estatuas cargan el GLB incluido, sin necesitar Blender. Después de preparar el motor, el juego funciona sin conexión.

`PLAY.bat` prepara los recursos con una importación local antes de abrir el juego. Esto permite arrancar tras clonar/copiar el repositorio sin una carpeta `.godot` previa y actualiza los modelos importados. Si falla, muestra la ruta del log.

- `tools/DEMO_TEST.bat`: suite de la misión unificada en modo headless.
- `tools/DEMO_CAPTURE.bat`: suite con GPU y capturas reales en `screenshots/`.
- `tools/TEST.bat`, `CAPTURE.bat`, `TACTICAL_TEST.bat`, `TACTICAL_CAPTURE.bat` y `PLAYTEST.bat`: alias de esa misma suite, que también incluye un bot con reglas normales. Ya no prueban dos experiencias principales separadas.
- `tools/QA.ps1`: verificación desde terminales que permitan scripts locales; los `.bat` no requieren cambiar la política de PowerShell.
- Informes locales en `tests/*_report.json`; logs en `tools/logs/`. [RESULTADO.md](docs/versions/0.4.0/RESULTADO.md) distingue las pruebas automáticas de la aprobación humana.

El duelo queda como prueba interna: `PLAY.bat --duel`. El lanzador también admite `PLAY.bat --fullscreen` y `PLAY.bat --rendering-method gl_compatibility` para equipos sin Vulkan; este último reduce algunos efectos y no es el renderizado principal de verificación.

Reglas actuales en [COMBATE.md](docs/versions/0.3.0/COMBATE.md), historial en [CHANGELOG.md](docs/project/CHANGELOG.md) y rutina Git/Engram en [ORGANIZACION.md](docs/project/ORGANIZACION.md).


La verificación adicional de HUD ancho puede ejecutarse con Godot: `--path . --resolution 1920x1080 --fixed-fps 60 -- --hud-capture`. Guarda `tests/demo_hud_capture_report.json` y capturas reales; es una suite parcial de UI/interacción, separada del recorrido completo.
