# Combate de la misión unificada

Referencia técnica de la **build de desarrollo de la segunda vuelta, prevista como 0.3.0**, en `feature/temple-tactical-demo`. No hay etiqueta final `v0.3.0`: Q01 sigue pendiente y falta la evaluación humana de equilibrio. El diseño humano vigente está en [DISENO_DEMO.md](DISENO_DEMO.md); implementación y evidencia se registran en [PENDIENTES.md](PENDIENTES.md) y [RESULTADO.md](RESULTADO.md).

La primera iteración permanece en Git, etiqueta [v0.2.0](https://github.com/Dioniss97/ShadowsOfKharuun/tree/v0.2.0). Sus reglas de WASD, recargas, Defensa y continuación contra la selección anterior fueron sustituidas. Este documento describe el código de la misión unificada.

## Rondas, órdenes y destinatarios

- Tiempo real con pausa y relojes independientes por combatiente. No hay alternancia global ni ronda extra artificial para el enemigo.
- Una acción en curso y hasta cuatro órdenes pendientes. Cada orden guarda acción y destinatario al encolarse; seleccionar otro enemigo o recorrer un selector no reescribe órdenes.
- El personaje se aproxima físicamente al destinatario cuando le falta alcance o visibilidad. La precisión, defensa, distancia y obstáculos pueden impedir un impacto. Si una ruta permanece bloqueada, se descarta la orden con explicación.
- El básico automático, cuando se agota la cola, usa el último destinatario de una acción ofensiva ejecutada. Cambiar la selección después no lo cambia. Una cura actúa sobre el protagonista y tampoco cambia ese destinatario.
- `1→A, 2→B, 2→A` sigue con `básico→A`. Aquí los números representan acciones del ejemplo, no teclas ni tipos de ataque adicionales.
- Una orden ofensiva contra un enemigo caído se descarta; no se transfiere a otro enemigo. Si el destinatario automático muere y ya no quedan órdenes válidas, se busca otro agresor vivo, visible y alcanzable.

La selección para preparar órdenes aparece arriba. La acción actual y la próxima orden se muestran en el panel inferior central con su destinatario, que puede ser diferente. Los cuatro botones de la cola permiten cancelación individual; el nombre completo también aparece en su descripción al pasar el ratón.

## Acciones y valores iniciales

Estos números son **ajustes provisionales de equilibrio de Kharuun**, no una reproducción exacta de KOTOR. La ronda inicial del jugador dura 2,6 s; los impactos se resuelven durante la animación y el tiempo restante representa recuperación.

| Acción | Recurso | Resultado inicial | Alcance |
|---|---|---|---|
| Básico | Una acción | Un intento, daño base 26 | 2,15 m |
| Ráfaga | Una acción | Dos intentos independientes, daño base 17 cada uno | 2,15 m |
| Empuje | Una acción y 24 de energía | Daño base 30, desplazamiento y aturdimiento si acierta | 5,5 m |
| Descarga | Una acción y 32 de energía | Daño base 58 | 11 m |
| Curación propia | Una acción y 28 de energía | Hasta 68 de salud sobre el protagonista | Sobre ti |
| Botiquín | Una acción y una unidad | Hasta 95 de salud sobre el protagonista | Sobre ti |

El básico tiene un contacto a los 0,42 s. La ráfaga tiene dos contactos a los 0,42 y 0,90 s, con tiradas separadas dentro de la misma ronda. Ambos pertenecen al mismo enemigo: su muerte, alejamiento, interrupción u obstáculo entre contactos no permiten transferir el segundo a otra persona.

El acierto usa `1d20 + ataque` frente a defensa pasiva; 1 falla y 20 es crítico. Un crítico surgido de esta tirada no añade un ataque crítico seleccionable. Defensa ya no es una acción y no se han añadido formas, equipo defensivo ni bloqueos entre armas.

Empuje, descarga y curación gastan energía sin recarga adicional. El protagonista empieza con 100 de energía y regenera inicialmente 3 por segundo cuando el mundo avanza. Los poderes usan un gesto común con el brazo izquierdo: empuje desde la palma, descarga desde la palma y curación verde alrededor del protagonista. El sable permanece en la mano derecha.

## Consumo, cancelación y energía pendiente

La energía o el botiquín se comprueban y consumen al iniciar la ejecución. Encolar o cancelar una orden pendiente no los gasta. F interrumpe una acción ya iniciada, pero no devuelve lo que consumió al comenzar. Botiquín y curación con salud completa consumen igualmente el recurso y una acción.

Empiezas con tres botiquines. El contador no puede quedar negativo y el botón agotado se desactiva. Como ajuste técnico provisional, una orden pendiente de botiquín que llega a ejecutarse sin unidades se descarta con aviso y deja avanzar la cola; no se inventa una penalización equivalente a Q01.

**Q01 aún no tiene una regla de juego acordada.** La build pausa el mundo cuando una orden llega a ejecutarse sin energía suficiente, conserva esa orden y muestra «Orden sin energía». El jugador debe cancelarla, limpiar la cola o pulsar F, y reanudar con Espacio. Así se prueba el resto mientras se espera la comprobación humana de KOTOR, sin elegir a escondidas entre saltar la orden, consumir una ronda o sustituirla por un básico. Esta pausa provisional no certifica Q01.

## Pausa, retirada y cámara

Al iniciar un encuentro agresivo se selecciona un agresor visible y alcanzable y se pausa una vez. Cambiar o perder enemigo dentro del mismo encuentro no provoca otra pausa inicial. La primera pausa de los acólitos ofrece ayuda breve omitible, seguida de avisos contextuales que aparecen una sola vez por misión.

Espacio congela movimiento, daño, rondas, estados y recursos, permitiendo seleccionar y preparar órdenes. Escape añade el menú de pausa; cerrarlo conserva cualquier pausa táctica anterior. El diálogo congela también la regeneración y se reanuda según combate o paso pacífico.

WASD no borra ni interrumpe órdenes del combate automático. F o Cancelar combate interrumpen la acción, vacían la cola y paran el básico automático, devolviendo movimiento libre sin reenganche involuntario. Los agresores conservan su actividad y persiguen por toda la zona accesible.

Arrastrar con el botón derecho permite orbitar la cámara. Al soltar conserva su orientación si el protagonista está quieto o el mundo pausado; se recentra suave y rápido al desplazarse. W avanza, S retrocede manteniendo el frente y A/D gira continuamente. Combinar W con A/D describe un arco o círculo, sin una diagonal fija. Durante acciones ofensivas el personaje encara su destinatario y orbitar no cambia esa orden.

Los tres selectores se proyectan sobre el enemigo seleccionado en una tarjeta compacta con nombre y vida, dejando la cara libre. Siguen al actor y a la cámara, se muestran también en pausa táctica y se ocultan fuera de combate, tras F o ante una selección no visible/válida. Flechas y rueda consumen sus eventos de interfaz y recorren sin encolar; clic en el icono conserva el destinatario seleccionado para esa nueva orden.

## Continuidad de la misión

Menú → exploración → diálogo inicial → acólitos → conversación del guardián. Rechazarlo o atacarlo tras escuchar inicia su encuentro; aceptar después de escuchar habilita paso pacífico con guardián vivo y no agresivo. Resolverlo abre la entrada al templo. Solo reclamar el núcleo permite completar la misión.

No hay reposición de salud, energía ni botiquines al pasar al guardián. El diálogo conserva los valores de entrada y congela tiempo y recursos. Reiniciar después de morir restablece la misión completa: recursos iniciales, tres botiquines, enemigos, encuentros, cola y elecciones.

Escudo, formas y arrojadizos son huecos futuros vacíos desactivados. El duelo queda accesible internamente con `PLAY.bat --duel`; la experiencia principal es una sola misión.

## Verificación

La suite de `tests/temple_runner.gd` cubre órdenes mezcladas A/B, selección independiente, ambos contactos de ráfaga, recursos, cura con salud llena, cancelación, pausa, persecución, colisiones, las ramas del guardián, objetivo final y reinicio. Incluye eventos reales sobre controles y un bot que usa reglas normales. Las capturas con GPU permiten revisar la legibilidad a 1280 × 720 y la relación entre arma, palma e impactos.

Las comprobaciones efectivamente ejecutadas y sus límites se publican en [RESULTADO.md](RESULTADO.md), sin equiparar pruebas de transición o un bot con la valoración humana de dificultad. El caso final de energía y esa valoración siguen pendientes.

Referencias visuales y de diseño: capturas de KOTOR II aportadas por el usuario y [manual de KOTOR II](https://cdn.akamai.steamstatic.com/steam/apps/208580/manuals/KOTORII_Manual.pdf). Las reglas y los números de Kharuun corresponden a los acuerdos de este prototipo.
