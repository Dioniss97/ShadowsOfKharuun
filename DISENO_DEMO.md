# Diseño vigente: segunda vuelta de la demo

Actualizado: 12 de octubre de 2026. Estado: **diseño y documentación; implementación todavía no iniciada**.

Este documento conserva los acuerdos humanos de esta conversación y permite retomar el proyecto sin reconstruirla. Las tareas están en [PENDIENTES.md](PENDIENTES.md). Las instrucciones para trabajar con estos documentos están en [AGENTS.md](AGENTS.md).

## Estado real y objetivo

La primera entrega verificada tiene dos entradas jugables: misión original de acción y duelo táctico. La evidencia está en [RESULTADO.md](RESULTADO.md), commit local `f516f41`: 56 comprobaciones tácticas sin ventana y 60 con GPU; regresión original de 34/43 comprobaciones. Esas pruebas no certifican aún la segunda vuelta.

El objetivo siguiente es **una única demo del asalto al templo con combate táctico integrado**, conservando exploración, diálogo, tres acólitos, guardián y finales. Tras los acólitos habrá una conversación ramificada que permita combatir al guardián o obtener paso pacífico. El duelo podrá conservarse internamente para pruebas. El proyecto es para un jugador y prioriza la historia.

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
| D16 | Tras los acólitos, el guardián reconoce el potencial del protagonista, desprecia el nivel de sus aprendices y ofrece su doctrina. Un rechazo inicial conduce al combate. Escuchar permite después aceptar el paso pacífico o atacar aun habiendo escuchado. |
| D17 | Conservar salud, energía y botiquines restantes al pasar al guardián. Retirar el regalo actual de hasta 75 de salud y energía completa. |
| D18 | Enseñar con ayuda breve y omitible durante la primera pausa y avisos contextuales de una sola aparición. |
| D19 | Retirar Defensa como orden o movimiento del jugador. Conservar la estadística pasiva de defensa ya implementada para calcular aciertos; no añadir ahora formas, bloqueos ni un sistema nuevo de equipo defensivo. |

La corrección D07 es explícita del usuario: `1→A, 2→B, 2→A` termina en `0→A`, donde 0 significa básico automático. Los números son una notación de acciones, no una petición de añadir más ataques a esta vuelta. Una curación posterior no convierte al protagonista en destinatario del autoataque.

## Alcance reducido y decisiones sustituidas

El usuario eligió inicialmente «toda la base» con ataques, escudo, granada y dos formas, pero después redujo expresamente esta vuelta. El alcance vigente contiene básico y ráfaga, empuje/descarga/curación y botiquines. Ataque crítico, ataque fuerte, escudo, formas, granadas de concusión o congelación, minas, inventario completo, combate a distancia nuevo, compañero y modelos Blender quedan para después.

También quedan sustituidas las propuestas de que WASD cancele el combate, de mantener recargas adicionales de poderes y de continuar el autoataque contra el último enemigo seleccionado. Esas tres reglas todavía existen en el código de la primera entrega y tendrán que cambiar al implementar.

La oferta del guardián y su lección serán narrativas en esta vuelta. Registrar la ruta elegida para diálogo/final no requiere karma numérico, afiliación persistente, poderes aprendidos ni progresión; esos sistemas siguen aplazados. Escuchar la lección no obliga a aceptarla.

## Conversación del guardián tras los acólitos

Flujo confirmado:

1. Termina el encuentro con los acólitos y se presenta el guardián. Retirar órdenes contra enemigos caídos y detener el autoataque antes de la conversación.
2. El guardián combina reconocimiento del protagonista con desprecio por sus acólitos y una oferta de enseñanza. Tono culto y solemne; diálogo original, no copia de los textos de KOTOR.
3. **Rechazar:** el jugador no acepta ser corrompido; empieza el encuentro del guardián con la pausa inicial acordada.
4. **Indagar:** el guardián expone una lección breve sobre su doctrina. Después el jugador decide **aceptar y pasar** o **atacarlo**.
5. En la ruta pacífica, el guardián permanece vivo y no agresivo, permite el paso y queda excluido de la selección automática de agresores. No debe bloquear físicamente la ruta.

La conversación no permite agresión ni gasto de recursos. Como propuesta para aplicar D17, congelar la regeneración de energía y la recuperación de salud durante esta transición narrativa: leer más despacio no debería equivaler a restaurar recursos gratuitamente. El usuario ha confirmado conservar los recursos y retirar el regalo entre encuentros; esta regla concreta de tiempo de lectura es una propuesta técnica. No reponer botiquines.

### Borrador de tono, pendiente de revisión

Guardián: «Mis acólitos habían aprendido a obedecer; creyeron que eso bastaba para merecer el poder. Tú has demostrado algo más. No confundas, sin embargo, una victoria con dominio. Este templo aún podría ser tu tumba… o el principio de tu verdadero aprendizaje.»

- Rechazo: «No someteré mi voluntad a tu doctrina. Permíteme pasar.»
- Indagar: «¿Qué es lo que crees poder enseñarme?»
- Lección: «El miedo no desaparece cuando lo niegas. Se convierte en tu dueño. Reconócelo; aprende a dirigirlo. El poder que buscas no responde a quien pide permiso, sino a quien acepta el precio de ejercerlo.»
- Aceptación: «Acepto tu enseñanza. Reclamaré el poder que guarda el templo.»
- Ataque tras escuchar: «Ya me has enseñado lo que necesitaba. Ahora eres el último obstáculo.»

Estas líneas son propuestas de redacción. Las ramas están acordadas; las frases y el punto exacto donde termina la misión requieren su revisión correspondiente. La ruta pacífica debe contar como resolución válida, sin exigir la muerte del guardián.

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
| Q01 | Orden que llega a ejecutarse sin energía suficiente | **Pendiente de la comprobación del usuario en KOTOR.** Su hipótesis: si es la última orden, consumir una ronda propia sin efecto antes del básico; si quedan órdenes, quizá pasar a la siguiente. No tratar ninguna variante como confirmada. |
| Q02 | Curación que llega a su turno con salud completa | Descartar sin recurso ni ronda y seguir. Aplicar la misma regla a botiquín y poder. |
| Q03 | Persecución y salida del encuentro tras F | Conservar la amenaza mientras los agresores estén activos; delimitar la persecución para impedir saltarse presentaciones narrativas. |
| Q07 | Derrota y reinicio | Conservar el reinicio de misión completa de la demo actual; un punto de control sería una ampliación a decidir. |
| Q09 | Punto de cierre de la ruta pacífica y de combate | Propuesta: ambas permiten entrar al templo y reclamar el mismo objetivo final. Alternativa: finalizar tras derrotar al guardián o conseguir su permiso de paso. |

Dudas cerradas: Q04 → D16, Q05 → D17, Q06 → D18 y Q08 → D19. Se conservan los identificadores para rastrear las respuestas anteriores.

Para Q01 comparar `ataque → curación sin energía` con `ataque → curación sin energía → ataque`. Observar si consume tiempo de ronda o pasa a otra orden; distinguir no poder encolarla de que falle al ejecutarse. Una penalización solo al final de la cola podría evitarse añadiendo un básico detrás. En Kharuun los relojes son independientes: perder la ronda propia no concede una ronda adicional artificial al enemigo. El usuario comprobará el comportamiento del original; no preguntárselo de nuevo mientras está pendiente esa comprobación.

Las propuestas no equivalen a respuestas del usuario. Si una duda pendiente es necesaria para el comportamiento que se está implementando y no se puede resolver por los acuerdos, consultarla con opciones. El usuario prefiere resolverlas antes de programar y recibir ese mismo formato si surge una duda importante durante el trabajo.

## Casos que deberá cubrir la verificación

1. Misión completa: menú → exploración → diálogo inicial → acólitos → conversación del guardián → resolución de combate o pacífica → final; derrota, repetición y vuelta al menú.
2. Pausa inicial una vez por encuentro, órdenes durante ella y ausencia de agresión durante diálogo/presentación.
3. Dos enemigos vivos A/B: órdenes mezcladas `1A, 2B, 2A`, selección independiente y básico posterior contra A. Repetir intercalando curación.
4. Ráfaga: dos tiradas y contactos, una acción/ronda; muerte, interrupción, distancia u obstáculo entre intentos no provocan daño a otro objetivo.
5. Selección, flechas, rueda y botones con eventos reales de entrada; recorrer opciones no encola ni mueve la cámara.
6. Tres botiquines, encolado, cancelación, consumo único, agotamiento, curación parcial, salud llena y reinicio según las reglas definitivas. Ningún contador negativo.
7. Energía comprobada al ejecutar, curación sobre el protagonista y ausencia de recarga adicional. Nunca bloquear una cola silenciosamente.
8. F devuelve movimiento; WASD conserva órdenes antes de F; cámara retorna al soltar botón derecho sin girar al combatiente fuera de su destinatario.
9. Huecos futuros desactivados, acción y objetivo visibles y ayuda comprensible a 1280 × 720. Verificación gráfica de palma, espada y ambos contactos de ráfaga.
10. Partida normal del bot con reglas de producción y prueba humana de claridad y equilibrio; no confundir un test de transiciones con una partida normal.
11. Diálogo posterior: rechazo y ataque tras escuchar inician combate pausado; aceptar permite paso con guardián vivo y no agresivo. Las tres rutas llegan al resultado previsto sin exigir cuatro muertes.
12. Comprobar D17 y la regla definitiva de recursos durante el diálogo: sin regalos de salud, energía o botiquines entre encuentros. Para la propuesta de congelación, leer todo el diálogo o saltarlo conserva los mismos recursos. No queda Defensa como acción seleccionable; las estadísticas pasivas siguen resolviendo aciertos.

## Referencias de diseño

Las capturas de KOTOR II aportadas por el usuario son referencias de distribución. [Manual de KOTOR II](https://cdn.akamai.steamstatic.com/steam/apps/208580/manuals/KOTORII_Manual.pdf): interfaz, cola, pausa y formas. [Manual de KOTOR](https://cdn.steamstatic.com/steam/apps/32370/manuals/KOTORI_Manual.pdf#page=14): familias de ataques especiales. Los efectos y números de Kharuun son decisiones propias del prototipo.
