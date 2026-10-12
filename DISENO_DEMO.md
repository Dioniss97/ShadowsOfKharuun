# Diseño vigente: segunda vuelta de la demo

Actualizado: 12 de octubre de 2026. Estado: **diseño y documentación; implementación todavía no iniciada**.

Este documento conserva los acuerdos humanos de esta conversación y permite retomar el proyecto sin reconstruirla. Las tareas están en [PENDIENTES.md](PENDIENTES.md). Las instrucciones para trabajar con estos documentos están en [AGENTS.md](AGENTS.md).

## Estado real y objetivo

La primera entrega verificada tiene dos entradas jugables: misión original de acción y duelo táctico. La evidencia está en [RESULTADO.md](RESULTADO.md), commit local `f516f41`: 56 comprobaciones tácticas sin ventana y 60 con GPU; regresión original de 34/43 comprobaciones. Esas pruebas no certifican aún la segunda vuelta.

El objetivo siguiente es **una única demo del asalto al templo con combate táctico integrado**, conservando exploración, diálogo, tres acólitos, guardián, victoria y derrota. El duelo podrá conservarse internamente para pruebas. El proyecto es para un jugador y prioriza la historia.

## Decisiones confirmadas

| ID | Acuerdo vigente |
|---|---|
| D01 | Unificar el combate táctico con la misión del templo; dejar de presentar duelo y misión como dos experiencias principales distintas. |
| D02 | Tiempo real con pausa y rondas independientes por combatiente. Pausa automática una vez al comenzar cada encuentro; Espacio permite pausar manualmente y preparar órdenes. |
| D03 | La cámara gira manteniendo el botón derecho. Al soltarlo vuelve suavemente detrás del personaje. En combate el personaje encara el destinatario de su acción; la cámara no cambia ese destinatario. |
| D04 | WASD no interrumpe ni borra órdenes durante el enfrentamiento automático. Primero se pulsa F o Cancelar combate para recuperar el movimiento libre. |
| D05 | Cancelar combate detiene órdenes y autoataque, y evita el reenganche inmediato del protagonista. Los enemigos siguen actuando. |
| D06 | Cada orden guarda su acción y destinatario al encolarse. Cambiar de selección o recorrer un selector no modifica las órdenes anteriores ni el ataque que está en curso. |
| D07 | Al vaciarse la cola, el básico automático se dirige al destinatario del último ataque ofensivo ejecutado, no a la última selección usada para preparar órdenes. |
| D08 | Si cae ese destinatario y no quedan órdenes válidas, continuar automáticamente contra otro agresor vivo, visible y alcanzable. Cambiar de enemigo en el mismo encuentro no provoca otra pausa inicial. |
| D09 | Los poderes consumen energía y tiempo de acción, sin recarga adicional por poder. Sus costes y la regeneración requieren equilibrio nuevo. |
| D10 | Dos ataques físicos en esta vuelta: básico y ráfaga. Ráfaga realiza dos intentos de impacto independientes dentro de una sola acción/ronda. |
| D11 | Tres poderes: empuje, descarga y curación propia. Curación siempre actúa sobre el protagonista y conserva el último enemigo ofensivo. |
| D12 | Tres botiquines iniciales con contador visible. Botiquín y poder curativo son órdenes en la misma cola, ocupan una acción y consumen su recurso al ejecutarse, no al encolarse. |
| D13 | Tres selectores junto al objetivo: ataques físicos, poderes y arrojadizos. Flechas o rueda sobre el selector cambian lo mostrado; pulsar el icono encola la acción. No son tres ranuras de la cola. |
| D14 | Menú personal inferior izquierdo para botiquines y huecos futuros visibles. Escudo, formas y arrojadizos permanecen vacíos y desactivados en esta vuelta. |
| D15 | Gesto sencillo común con el brazo izquierdo para poderes; el sable permanece en la mano derecha. Empuje proyecta una onda, descarga sale de la palma y curación produce un efecto verde alrededor del protagonista. |

La corrección D07 es explícita del usuario: `1→A, 2→B, 2→A` termina en `0→A`, donde 0 significa básico automático. Los números son una notación de acciones, no una petición de añadir más ataques a esta vuelta. Una curación posterior no convierte al protagonista en destinatario del autoataque.

## Alcance reducido y decisiones sustituidas

El usuario eligió inicialmente «toda la base» con ataques, escudo, granada y dos formas, pero después redujo expresamente esta vuelta. El alcance vigente contiene básico y ráfaga, empuje/descarga/curación y botiquines. Ataque crítico, ataque fuerte, escudo, formas, granadas de concusión o congelación, minas, inventario completo, combate a distancia nuevo, compañero y modelos Blender quedan para después.

También quedan sustituidas las propuestas de que WASD cancele el combate, de mantener recargas adicionales de poderes y de continuar el autoataque contra el último enemigo seleccionado. Esas tres reglas todavía existen en el código de la primera entrega y tendrán que cambiar al implementar.

## Organización de la interfaz

- Junto al enemigo seleccionado: nombre, vida y los tres selectores. El arrojadizo está desactivado con explicación; no aparenta una acción utilizable.
- Abajo, centro: acción actual con destinatario, recuperación, cola y Cancelar combate. Conservar como base una acción actual y cuatro órdenes pendientes, capacidad de la primera entrega.
- Abajo, izquierda: botiquín y contador; huecos identificados para futuras utilidades, escudo y formas. Un hueco futuro se distingue de un objeto implementado pero agotado.
- Abajo, derecha: retrato, salud, energía y efectos del protagonista.
- Avisos breves de pausa, objetivo narrativo, orden descartada y recursos. Texto o iconos legibles complementan el color.

La selección usada para nuevas órdenes y el destinatario de la acción actual pueden ser distintos; la interfaz debe explicar ambos sin cambiar silenciosamente órdenes. Curación mostrada en el selector de poderes debe indicar «Sobre ti» incluso con un enemigo seleccionado.

## Base técnica que se conserva

Colisiones sólidas, aproximación física, comprobación de alcance y visibilidad, preparación/contacto/recuperación del arma y pausa que congela física, daño, estados y recursos. La duración de 2,6 s del jugador es un valor inicial heredado, no una reproducción exacta de KOTOR. Los valores concretos de daño, acierto, curación, energía y ritmo enemigo se ajustarán mediante pruebas.

Durante la ráfaga cada intento tiene su propio resultado y momento visible de contacto. Ambos pertenecen al mismo destinatario. Si pierde validez o sale de alcance entre intentos, no se transfiere el segundo impacto a otro enemigo. No debe haber golpes invisibles o duplicados.

## Dudas a cerrar antes de implementar

| ID | Tema abierto | Propuesta de partida, todavía no confirmada |
|---|---|---|
| Q01 | Orden que llega a ejecutarse sin energía suficiente | Descartarla con aviso y continuar; permitir planificar y comprobar disponibilidad al ejecutarse. |
| Q02 | Curación que llega a su turno con salud completa | Descartar sin recurso ni ronda y seguir. Aplicar la misma regla a botiquín y poder. |
| Q03 | Persecución y salida del encuentro tras F | Conservar la amenaza mientras los agresores estén activos; delimitar la persecución para impedir saltarse presentaciones narrativas. |
| Q04 | Paso del último acólito al guardián | Dos encuentros con breve presentación y nueva pausa inicial. La versión actual activa al jefe inmediatamente. |
| Q05 | Recursos al comenzar el guardián | Conservar salud, energía y botiquines restantes. La versión actual regala hasta 75 de salud y restaura toda la energía. |
| Q06 | Cómo enseñar selector, cola y retirada | Ayuda breve y omitible durante la primera pausa, con avisos contextuales de una sola aparición. |
| Q07 | Derrota y reinicio | Conservar el reinicio de misión completa de la demo actual; un punto de control sería una ampliación a decidir. |
| Q08 | Acción Defensa de la primera entrega | Reservarla para otra vuelta; alternativamente conservarla como orden personal. No confundirla con una forma de combate persistente. |

Las propuestas no equivalen a respuestas del usuario. Si una duda pendiente es necesaria para el comportamiento que se está implementando y no se puede resolver por los acuerdos, consultarla con opciones. El usuario prefiere resolverlas antes de programar y recibir ese mismo formato si surge una duda importante durante el trabajo.

## Casos que deberá cubrir la verificación

1. Misión completa: menú → exploración → diálogo → acólitos → guardián → victoria; derrota, repetición y vuelta al menú.
2. Pausa inicial una vez por encuentro, órdenes durante ella y ausencia de agresión durante diálogo/presentación.
3. Dos enemigos vivos A/B: órdenes mezcladas `1A, 2B, 2A`, selección independiente y básico posterior contra A. Repetir intercalando curación.
4. Ráfaga: dos tiradas y contactos, una acción/ronda; muerte, interrupción, distancia u obstáculo entre intentos no provocan daño a otro objetivo.
5. Selección, flechas, rueda y botones con eventos reales de entrada; recorrer opciones no encola ni mueve la cámara.
6. Tres botiquines, encolado, cancelación, consumo único, agotamiento, curación parcial, salud llena y reinicio según las reglas definitivas. Ningún contador negativo.
7. Energía comprobada al ejecutar, curación sobre el protagonista y ausencia de recarga adicional. Nunca bloquear una cola silenciosamente.
8. F devuelve movimiento; WASD conserva órdenes antes de F; cámara retorna al soltar botón derecho sin girar al combatiente fuera de su destinatario.
9. Huecos futuros desactivados, acción y objetivo visibles y ayuda comprensible a 1280 × 720. Verificación gráfica de palma, espada y ambos contactos de ráfaga.
10. Partida normal del bot con reglas de producción y prueba humana de claridad y equilibrio; no confundir un test de transiciones con una partida normal.

## Referencias de diseño

Las capturas de KOTOR II aportadas por el usuario son referencias de distribución. [Manual de KOTOR II](https://cdn.akamai.steamstatic.com/steam/apps/208580/manuals/KOTORII_Manual.pdf): interfaz, cola, pausa y formas. [Manual de KOTOR](https://cdn.steamstatic.com/steam/apps/32370/manuals/KOTORI_Manual.pdf#page=14): familias de ataques especiales. Los efectos y números de Kharuun son decisiones propias del prototipo.
