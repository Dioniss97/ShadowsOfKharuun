# Shadows of Kharuun

Haz doble clic en **PLAY.bat** y elige **Nueva partida · asalto al templo**. Esta rama reúne exploración, combate táctico y decisiones narrativas en una sola misión. Tras derrotar a los tres acólitos, puedes combatir al guardián o escuchar su doctrina y obtener paso pacífico; en ambas rutas debes entrar y reclamar el núcleo del templo para completar la demo.

El código de `feature/temple-tactical-demo` es una **build de desarrollo de la segunda vuelta, prevista como 0.3.0**. Sigue pendiente decidir Q01, el comportamiento de una orden sin energía, y recoger una prueba humana de claridad y equilibrio. No se ha publicado una etiqueta final `v0.3.0`. La última entrega estable conserva su etiqueta inmutable [v0.2.0](https://github.com/Dioniss97/ShadowsOfKharuun/tree/v0.2.0); describía el duelo táctico y la misión original por separado.

Repositorio privado: [Dioniss97/ShadowsOfKharuun](https://github.com/Dioniss97/ShadowsOfKharuun). Seguimiento: [issues](https://github.com/Dioniss97/ShadowsOfKharuun/issues) y [milestone Demo 0.3.0](https://github.com/Dioniss97/ShadowsOfKharuun/milestone/1). Los acuerdos están en [DISENO_DEMO.md](DISENO_DEMO.md), los estados en [PENDIENTES.md](PENDIENTES.md) y la evidencia de cada entrega en [RESULTADO.md](RESULTADO.md).

## Controles de la misión unificada

| Control | Acción |
|---|---|
| WASD / Shift | Mover / correr durante exploración o tras cancelar combate |
| Botón derecho mantenido + ratón | Girar la cámara; al soltarlo vuelve suavemente detrás del personaje |
| Clic izquierdo sobre enemigo / Tab | Seleccionar un agresor para nuevas órdenes e iniciar el enfrentamiento |
| Flechas o rueda sobre un selector | Recorrer ataques o poderes sin encolar nada |
| Clic sobre el icono del selector | Añadir su acción contra la selección actual; curación siempre actúa sobre ti |
| 1 / 2 | Encolar empuje / descarga |
| 3 / 4 | Encolar básico / ráfaga |
| 5 / 6 | Encolar curación propia / botiquín |
| Clic sobre una orden pendiente | Cancelar esa orden |
| Limpiar cola | Retirar todas las órdenes pendientes; continúa la acción actual |
| F / Cancelar combate | Detener órdenes y ataque automático; recuperar WASD |
| Espacio | Pausa táctica; seleccionar y preparar órdenes mientras el mundo está congelado |
| E | Hablar cerca del umbral, continuar una respuesta o reclamar el núcleo al acercarte a él |
| 1, 2, 3 o ratón durante diálogo | Elegir entre las respuestas disponibles |
| Escape | Menú de pausa / continuar |

Durante el combate automático, **WASD conserva las órdenes**. Pulsa F primero para moverte libremente. Los enemigos siguen atacando y persiguen por toda la zona accesible: cancelar combate no los detiene ni los devuelve a su posición inicial.

## Selección, cola y recursos

Cada combatiente tiene su propia ronda. El primer encuentro con los acólitos y el encuentro con el guardián empiezan pausados una sola vez, con selección automática de un agresor visible y alcanzable. La ayuda inicial se puede omitir; Espacio permite reanudar o pausar de nuevo.

Hay una acción en curso y **cuatro órdenes pendientes**. Los tres selectores de arriba son categorías —arma, energía y arrojadizos—; no son las ranuras de la cola. El panel central muestra acción y destinatario, y cada orden conserva el enemigo al que se dirigió cuando la añadiste. Cambiar la selección sirve para preparar la siguiente orden.

Al terminar la cola, el básico automático sigue contra el último enemigo al que ejecutaste una acción ofensiva. Por ejemplo, `básico A → descarga B → ráfaga A` continúa con `básico A`, aunque después selecciones B. Curarte conserva ese destinatario. Si muere y no quedan órdenes válidas, el personaje continúa contra otro agresor vivo, visible y alcanzable, sin otra pausa inicial.

La ráfaga tiene dos intentos de impacto independientes en una sola ronda. Los poderes disponibles son empuje, descarga y curación propia; cuestan energía y una acción, **sin recarga adicional**. El botiquín y la curación energética usan la misma cola. Empiezas con **tres botiquines**, con contador en el menú inferior izquierdo.

El recurso se consume al comenzar a ejecutar la orden, no al añadirla. Cancelar una orden pendiente lo conserva; cancelar una acción que ya empezó no devuelve el recurso. Curarte con la salud completa también consume la acción y el recurso. Un botiquín agotado se distingue de los huecos futuros; si un botiquín pendiente llega a ejecutarse cuando ya no queda ninguno, esta build descarta la orden con aviso y sigue la cola.

Escudo, formas y arrojadizos aparecen como huecos vacíos desactivados. Ataque crítico, ataque fuerte, granadas, formas, bloqueos entre sables, inventario completo y progresión quedan para otra vuelta. Defensa se conserva como estadística pasiva de acierto; no es una orden seleccionable.

## Diálogo y final

Tras caer los acólitos, el guardián ofrece enseñanza. Rechazarla inicia combate; escuchar permite después aceptar paso pacífico o atacarlo. La ruta pacífica conserva al guardián vivo y no agresivo. La lección tiene efecto narrativo en esta demo: no hay karma, afiliación persistente ni nuevos poderes aprendidos.

La conversación congela tiempo, movimiento, daño y regeneración. Conservas salud, energía y botiquines entre encuentros, sin regalo automático. Resolver al guardián abre el acceso al templo; la victoria solo llega al reclamar el núcleo con E. Tras morir, reinicias toda la misión con recursos iniciales, tres botiquines y elecciones restablecidas.

## Caso pendiente de energía

Q01 espera la comprobación del usuario en KOTOR. Para poder probar el resto sin imponer una regla aún no acordada, **esta build de desarrollo pausa el mundo cuando la próxima orden no tiene energía suficiente**, conserva la orden y muestra un aviso. Retira esa orden, limpia la cola o pulsa F; después pulsa Espacio para continuar. No consume un turno fallido, salta la orden ni la sustituye por un básico automáticamente.

Esta pausa es una protección provisional del desarrollo, no la regla final del juego. La decisión pendiente y la prueba humana de equilibrio impiden presentar 0.3.0 como entrega cerrada.

## Dependencias y verificación

Godot **4.7.2 Stable estándar**, portátil, está incluido localmente en `tools/godot/`. Forward+ / Vulkan, con RX 6600 como GPU de prueba. No requiere .NET ni Blender. Los ejecutables y archivos de caché están excluidos de Git: al copiar el proyecto a otro equipo, hay que preparar el motor.

La voz usa el TTS de Windows si Godot encuentra una voz española; siempre hay subtítulos. Audio y geometría se generan en Godot. Después de preparar el motor, el juego funciona sin conexión.

- `tools/DEMO_TEST.bat`: suite de la misión unificada en modo headless.
- `tools/DEMO_CAPTURE.bat`: suite con GPU y capturas reales en `screenshots/`.
- `tools/TEST.bat`, `CAPTURE.bat`, `TACTICAL_TEST.bat`, `TACTICAL_CAPTURE.bat` y `PLAYTEST.bat`: alias de esa misma suite, que también incluye un bot con reglas normales. Ya no prueban dos experiencias principales separadas.
- `tools/QA.ps1`: verificación desde terminales que permitan scripts locales; los `.bat` no requieren cambiar la política de PowerShell.
- Informes locales en `tests/*_report.json`; logs en `tools/logs/`. [RESULTADO.md](RESULTADO.md) distingue los flujos comprobados de la revisión humana pendiente.

El duelo queda como prueba interna: `PLAY.bat --duel`. El lanzador también admite `PLAY.bat --fullscreen` y `PLAY.bat --rendering-method gl_compatibility` para equipos sin Vulkan; este último reduce algunos efectos y no es el renderizado principal de verificación.

Reglas actuales en [COMBATE.md](COMBATE.md), historial en [CHANGELOG.md](CHANGELOG.md) y rutina Git/Engram en [ORGANIZACION.md](ORGANIZACION.md).
