# Combate de la misión unificada

Referencia técnica de la **0.3.0, con QA humana aprobada el 14 de octubre de 2026**. Implementa D01–D36/B1–B8; D27 está sustituida por D33. La promoción de RC2 a versión final conserva estas reglas. El diseño aprobado de 0.3.0 está en [DISENO_DEMO.md](DISENO_DEMO.md); el seguimiento de sus issues se conserva históricamente en [PENDIENTES.md](PENDIENTES.md), y la evidencia en [RESULTADO.md](../0.4.0/RESULTADO.md). Las versiones nuevas usan GitHub Issues como backlog operativo según [GESTION_DESARROLLO.md](../../project/GESTION_DESARROLLO.md).

La primera iteración permanece en Git, etiqueta [v0.2.0](https://github.com/Dioniss97/ShadowsOfKharuun/tree/v0.2.0). Sus reglas de WASD, recargas, Defensa y continuación contra la selección anterior fueron sustituidas. Este documento describe el código de la misión unificada.

## Rondas, órdenes y destinatarios

- Tiempo real con pausa y relojes independientes por combatiente. No hay alternancia global ni ronda extra artificial para el enemigo.
- Una acción en curso y hasta cuatro órdenes pendientes. Cada orden guarda acción y destinatario al encolarse; seleccionar otro enemigo o recorrer un selector no reescribe órdenes.
- Las órdenes explícitas permiten aproximarse físicamente al destinatario cuando le falta alcance o visibilidad. El básico automático espera quieto hasta que el destinatario entre en alcance cuerpo a cuerpo. La precisión, defensa, distancia y obstáculos pueden impedir un impacto. Si una ruta permanece bloqueada, se descarta la orden con explicación.
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

## Consumo y fallo de recursos (D31)

La energía o el botiquín se consumen al iniciar la ejecución. Encolar o cancelar una orden pendiente no gasta recursos. F interrumpe la acción sin devolver el gasto realizado. Curar con salud completa consume recurso y ronda.

Un poder que supera la energía actual se muestra gris y no se puede encolar. Si al ejecutarse una orden ya no puede pagarse, se elimina junto con las pendientes del mismo recurso: poderes o botiquines. La siguiente orden válida ocupa esa oportunidad sin perder ronda. Si no queda ninguna válida, se pierde una ronda sin efecto; el básico automático vuelve en la siguiente oportunidad, condicionado a D28. Cada combatiente conserva su propio reloj.

Ejemplo: con energía para una descarga, `descarga → descarga → ráfaga` ejecuta la primera descarga y después la ráfaga; elimina la segunda descarga sin añadir una ronda vacía. Con solo `descarga → descarga`, la segunda causa una ronda perdida antes del básico posterior.

Abajo a la izquierda hay dos selectores separados: poderes personales primero (curación propia) y consumibles después (tres botiquines). La tarjeta flotante solo contiene básico/ráfaga, empuje/descarga y arrojadizos vacíos. Al agotar botiquines desaparece su icono y el hueco indica Agotado, distinto de las funciones futuras.

## Pausa, retirada y cámara

Al iniciar un encuentro agresivo se selecciona un agresor visible y alcanzable y se pausa una vez. Cambiar o perder enemigo dentro del mismo encuentro no provoca otra pausa inicial. La primera pausa de los acólitos ofrece ayuda breve omitible, seguida de avisos contextuales que aparecen una sola vez por misión.

Espacio congela movimiento, daño, rondas, estados y recursos, permitiendo seleccionar y preparar órdenes. Escape añade el menú de pausa; cerrarlo conserva cualquier pausa táctica anterior. El diálogo congela también la regeneración y se reanuda según combate o paso pacífico.

WASD no borra ni interrumpe órdenes del combate automático. F o Cancelar combate interrumpen la acción, vacían la cola y paran el básico automático, devolviendo movimiento libre sin reenganche involuntario. Los agresores conservan su actividad y persiguen por toda la zona accesible.

Arrastrar con el botón derecho permite orbitar la cámara. Al soltar conserva su orientación si el protagonista está quieto o el mundo pausado; se recentra suave y rápido al desplazarse. A/D gira continuamente al actor en movimiento libre. W avanza según su frente y W+A/D curva/círculo; S retrocede sin invertirlo. En pausa se congela el giro del actor y en combate se conserva su destinatario; F libera el movimiento. Durante acciones ofensivas el personaje encara su destinatario y orbitar no cambia esa orden.

Los tres selectores se proyectan sobre el enemigo seleccionado en una tarjeta compacta con nombre y vida, dejando la cara libre. Siguen al actor y a la cámara, se muestran también en pausa táctica y se ocultan fuera de combate, tras F o ante una selección no visible/válida. Flechas y rueda consumen sus eventos de interfaz y recorren sin encolar; clic en el icono conserva el destinatario seleccionado para esa nueva orden.

## Continuidad de la misión

Menú → exploración → diálogo inicial automático al acercarse al guardián → acólitos → espera libre con puerta cerrada → segunda conversación al seleccionar y hablar con el guardián. Los neutrales usan primer clic para seleccionar, segundo sobre actor/icono de voz para hablar; los acólitos rotan tres frases en orden. Si están lejos, el personaje se acerca para hablar y W/S permite cancelar esa aproximación. Rechazarlo o atacarlo tras escuchar inicia su encuentro; aceptar después de escuchar habilita paso pacífico con guardián vivo y no agresivo. Resolverlo abre la entrada al templo. Solo reclamar el núcleo con clic y cursor de mano, tras aproximación física si hace falta, permite completar la misión. E deja de reclamarlo.

No hay reposición de salud, energía ni botiquines al pasar al guardián. El diálogo conserva los valores de entrada y congela tiempo y recursos. Reiniciar después de morir restablece la misión completa: recursos iniciales, tres botiquines, enemigos, encuentros, cola y elecciones.

Escudo, formas y arrojadizos son huecos futuros vacíos desactivados. El duelo queda accesible internamente con `PLAY.bat --duel`; la experiencia principal es una sola misión.

## Verificación

La suite de `tests/temple_runner.gd` cubre órdenes mezcladas A/B, selección independiente, ambos contactos de ráfaga, recursos, cura con salud llena, cancelación, pausa, persecución, colisiones, las ramas del guardián, objetivo final y reinicio. Incluye eventos reales sobre controles y un bot que usa reglas normales. Las capturas con GPU permiten revisar la legibilidad a 1280 × 720 y la relación entre arma, palma e impactos.

Las comprobaciones efectivamente ejecutadas y sus límites se publican en [RESULTADO.md](../0.4.0/RESULTADO.md), sin equiparar pruebas de transición o un bot con la valoración humana de dificultad. La regla de energía está comprobada; falta la valoración humana de claridad y equilibrio.

Referencias visuales y de diseño: capturas de KOTOR II aportadas por el usuario y [manual de KOTOR II](https://cdn.akamai.steamstatic.com/steam/apps/208580/manuals/KOTORII_Manual.pdf). Las reglas y los números de Kharuun corresponden a los acuerdos de este prototipo.


D34/D36: sin barras 3D generales; la selección viva y visible, incluso neutral, tiene nombre/vida. Los selectores ofensivos conservan su visibilidad exclusiva de combate. La cola compacta conserva cuatro pendientes, cancelación por icono y destinos en tooltips; acción actual a la derecha y Cancelar debajo.
