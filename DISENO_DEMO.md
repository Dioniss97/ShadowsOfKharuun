# Diseño vigente: segunda vuelta de la demo

Actualizado: 12 de octubre de 2026. Estado: **segunda vuelta implementada en una build de desarrollo; regla Q01 y aceptación humana pendientes**.

Este documento conserva los acuerdos humanos de esta conversación y permite retomar el proyecto sin reconstruirla. Las tareas están en [PENDIENTES.md](PENDIENTES.md). Las instrucciones para trabajar con estos documentos están en [AGENTS.md](AGENTS.md); la rutina, versiones y punto de reanudación están en [ORGANIZACION.md](ORGANIZACION.md).

## Estado real y objetivo

La última entrega estable **0.2.0**, etiqueta `v0.2.0` y commit `f516f41`, tenía misión original de acción y duelo táctico separados. Su informe histórico permanece en esa etiqueta. El árbol actual de `feature/temple-tactical-demo` implementa la misión unificada y los acuerdos D01–D24 como **build de desarrollo de 0.3.0**. Las pruebas nuevas y sus límites están en [RESULTADO.md](RESULTADO.md); no existe aún una etiqueta final `v0.3.0`.

El objetivo siguiente es **una única demo del asalto al templo con combate táctico integrado**, conservando exploración, diálogo, tres acólitos, guardián y finales. Tras los acólitos habrá una conversación ramificada que permita combatir al guardián o obtener paso pacífico. El duelo podrá conservarse internamente para pruebas. El proyecto es para un jugador y prioriza la historia.

## Decisiones confirmadas

| ID | Acuerdo vigente |
|---|---|
| D01 | Unificar el combate táctico con la misión del templo; dejar de presentar duelo y misión como dos experiencias principales distintas. |
| D02 | Tiempo real con pausa y rondas independientes por combatiente. Al iniciar un encuentro agresivo, seleccionar automáticamente al agresor más cercano que esté vivo, visible y alcanzable, sin incluir personajes neutrales. Pausa automática una vez al comenzar cada encuentro; Espacio permite pausar manualmente y preparar órdenes. |
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
| D20 | Las rutas de combate y acuerdo desembocan en entrar al templo y reclamar el mismo objetivo final. La muerte del guardián o su permiso habilitan el paso, pero por sí solos no terminan la demo. |
| D21 | Si se ejecuta una curación con salud completa, se consumen igualmente la ronda y el recurso. Aplicar tanto a botiquín como a poder curativo; no descartarla ni bloquear su uso solo porque la salud esté llena. |
| D22 | Tras F o Cancelar combate, los enemigos persiguen por toda la zona accesible de la demo. Cancelar no apaga la amenaza ni devuelve enemigos a una zona de origen. Mantener las condiciones narrativas del templo y la ausencia de agresión durante el diálogo. |
| D23 | Morir permite reiniciar desde el inicio de la misión con salud, energía y tres botiquines iniciales; reiniciar también enemigos, cola, encuentros y elecciones de esa partida. No añadir un punto de control por encuentro. |
| D24 | Durante el diálogo con el guardián se congelan tiempo y recursos, incluida la regeneración. Leer despacio o saltar texto conserva los mismos recursos de entrada; al concluir se reanuda el tiempo según combate o paso pacífico. |

La corrección D07 es explícita del usuario: `1→A, 2→B, 2→A` termina en `0→A`, donde 0 significa básico automático. Los números son una notación de acciones, no una petición de añadir más ataques a esta vuelta. Una curación posterior no convierte al protagonista en destinatario del autoataque.

## Alcance reducido y decisiones sustituidas

El usuario eligió inicialmente «toda la base» con ataques, escudo, granada y dos formas, pero después redujo expresamente esta vuelta. El alcance vigente contiene básico y ráfaga, empuje/descarga/curación y botiquines. Ataque crítico, ataque fuerte, escudo, formas, granadas de concusión o congelación, minas, inventario completo, combate a distancia nuevo, compañero y modelos Blender quedan para después.

También quedan sustituidas las propuestas de que WASD cancele el combate, de mantener recargas adicionales de poderes y de continuar el autoataque contra el último enemigo seleccionado. Esas reglas pertenecen a `v0.2.0`; ya están retiradas de la build actual.

La oferta del guardián y su lección serán narrativas en esta vuelta. Registrar la ruta elegida para diálogo/final no requiere karma numérico, afiliación persistente, poderes aprendidos ni progresión; esos sistemas siguen aplazados. Escuchar la lección no obliga a aceptarla.

## Conversación del guardián tras los acólitos

Flujo confirmado:

1. Termina el encuentro con los acólitos y se presenta el guardián. Retirar órdenes contra enemigos caídos y detener el autoataque antes de la conversación.
2. El guardián combina reconocimiento del protagonista con desprecio por sus acólitos y una oferta de enseñanza. Tono culto y solemne; diálogo original, no copia de los textos de KOTOR.
3. **Rechazar:** el jugador no acepta ser corrompido; empieza el encuentro del guardián con la pausa inicial acordada.
4. **Indagar:** el guardián expone una lección breve sobre su doctrina. Después el jugador decide **aceptar y pasar** o **atacarlo**.
5. En la ruta pacífica, el guardián permanece vivo y no agresivo, permite el paso y queda excluido de la selección automática de agresores. No debe bloquear físicamente la ruta.

La conversación no permite agresión ni gasto de recursos. D24 confirma congelar el tiempo y los recursos durante esta transición narrativa: leer más despacio no restaura recursos gratuitamente. Conservar los valores de entrada según D17, sin reponer botiquines. Rechazar o atacar inicia el encuentro con su pausa inicial; aceptar devuelve la exploración con el guardián no agresivo.

### Borrador de tono, pendiente de revisión

Guardián: «Mis acólitos habían aprendido a obedecer; creyeron que eso bastaba para merecer el poder. Tú has demostrado algo más. No confundas, sin embargo, una victoria con dominio. Este templo aún podría ser tu tumba… o el principio de tu verdadero aprendizaje.»

- Rechazo: «No someteré mi voluntad a tu doctrina. Permíteme pasar.»
- Indagar: «¿Qué es lo que crees poder enseñarme?»
- Lección: «El miedo no desaparece cuando lo niegas. Se convierte en tu dueño. Reconócelo; aprende a dirigirlo. El poder que buscas no responde a quien pide permiso, sino a quien acepta el precio de ejercerlo.»
- Aceptación: «Acepto tu enseñanza. Reclamaré el poder que guarda el templo.»
- Ataque tras escuchar: «Ya me has enseñado lo que necesitaba. Ahora eres el último obstáculo.»

Estas líneas son propuestas de redacción. Las ramas y el cierre común están acordados; las frases concretas siguen siendo borrador. La ruta pacífica debe contar como resolución válida, sin exigir la muerte del guardián.

La build usa estas líneas originales como primer texto jugable; se pueden pulir con la prueba humana sin modificar las ramas acordadas.

### Objetivo final común confirmado

Derrotar al guardián o aceptar el acuerdo permite entrar al templo. En ambos casos, el objetivo cambia a reclamar lo que guarda el templo; solo completar ese objetivo desencadena el final. El acceso y la interacción deben estar condicionados a haber resuelto al guardián, para que no se gane simplemente corriendo hacia el objetivo durante un enfrentamiento todavía pendiente.

La ruta pacífica conserva al guardián vivo y no agresivo; la ruta de combate permite avanzar después de derrotarlo. Las pantallas finales y los contadores reconocen ambas resoluciones: tres acólitos muertos son compatibles con una misión completada pacíficamente. Registrar la elección narrativa permite describir la ruta, sin implementar karma ni recompensas de progresión.

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

Dudas cerradas: Q02 → D21 (curación con salud llena consume recurso y ronda), Q03 → D22 (persecución por toda la zona accesible), Q04 → D16, Q05 → D17, Q06 → D18, Q07 → D23 (reinicio de misión), Q08 → D19 y Q09 → D20. D24 confirma la propuesta de congelación durante el diálogo. Se conservan los identificadores para rastrear las respuestas anteriores; las propuestas anteriores de Q02/Q03 quedan sustituidas.

Para Q01 comparar `ataque → curación sin energía` con `ataque → curación sin energía → ataque`. Observar si consume tiempo de ronda o pasa a otra orden; distinguir no poder encolarla de que falle al ejecutarse. Una penalización solo al final de la cola podría evitarse añadiendo un básico detrás. En Kharuun los relojes son independientes: perder la ronda propia no concede una ronda adicional artificial al enemigo. El usuario comprobará el comportamiento del original; no preguntárselo de nuevo mientras está pendiente esa comprobación.

Las propuestas no equivalen a respuestas del usuario. Si una duda pendiente es necesaria para el comportamiento que se está implementando y no se puede resolver por los acuerdos, consultarla con opciones. El usuario prefiere resolverlas antes de programar y recibir ese mismo formato si surge una duda importante durante el trabajo.

## Implementación de desarrollo y límites

El usuario autorizó empezar a producir esta segunda vuelta el 12 de octubre. La misión, cola por destinatario, HUD, ataques, recursos, cámara, retirada y ramas del guardián están implementados en `feature/temple-tactical-demo`. El menú presenta una única misión principal; el duelo queda como herramienta interna mediante `--duel`.

Q01 permanece aislada: si una orden llega sin energía, **esta build de desarrollo conserva la orden y pausa el mundo**, sin cobrar energía ni inventar una ronda perdida o un salto de cola. Para seguir probando se cancela esa orden o se pulsa F y luego se reanuda. Esta protección temporal no es la respuesta definitiva del combate ni fidelidad verificada a KOTOR. Debe sustituirse y probarse tras la observación del usuario antes de etiquetar la entrega final.

Ajustes técnicos provisionales: una orden de botiquín que encuentre el inventario agotado se descarta con aviso, sin contador negativo; cancelar una orden pendiente no gasta recursos, y F después de iniciarse una acción no devuelve el recurso que ya se consumió. Una ráfaga cuyo enemigo muera o salga de alcance conserva la ronda y no redirige el segundo golpe. La aproximación usa física y evita obstáculos cercanos; no hay un sistema nuevo de navegación de mapas.

Valores iniciales para la prueba humana: salud 340, energía 100, regeneración 3/s, tres botiquines de 95; básico 26, ráfaga 17 × 2; empuje 30 por 24 de energía, descarga 58 por 32 y curación 68 por 28; ronda del jugador 2,6 s. Acólitos con 160 de salud y ronda de 3,8 s; guardián con 520 y ronda de 3 s. Son valores de equilibrio propios, modificables con evidencia. La defensa sigue siendo una estadística pasiva de acierto.

El núcleo reclamable del templo es el mismo en ambas rutas. Se añadió una cámara pequeña detrás del portal existente y un marcador visible del altar para concretar D20; no es una ampliación del universo ni otra misión. La aceptación humana de ritmo y claridad y Q01 siguen pendientes, aunque pasen los tests automáticos.

## Casos que deberá cubrir la verificación

1. Misión completa: menú → exploración → diálogo inicial → acólitos → conversación del guardián → resolución de combate o pacífica → final; derrota, repetición y vuelta al menú.
2. Pausa inicial una vez por encuentro, órdenes durante ella y ausencia de agresión durante diálogo/presentación.
3. Dos enemigos vivos A/B: órdenes mezcladas `1A, 2B, 2A`, selección independiente y básico posterior contra A. Repetir intercalando curación.
4. Ráfaga: dos tiradas y contactos, una acción/ronda; muerte, interrupción, distancia u obstáculo entre intentos no provocan daño a otro objetivo.
5. Selección, flechas, rueda y botones con eventos reales de entrada; recorrer opciones no encola ni mueve la cámara.
6. Tres botiquines, encolado, cancelación, consumo único, agotamiento y curación parcial. Con salud llena, botiquín y poder curativo consumen recurso y una ronda igualmente (D21). Ningún contador negativo. Reiniciar la misión completa devuelve recursos iniciales y restablece enemigos, cola y ruta narrativa (D23).
7. Energía comprobada al ejecutar, curación sobre el protagonista y ausencia de recarga adicional. Nunca bloquear una cola silenciosamente.
8. F devuelve movimiento; WASD conserva órdenes antes de F; cámara retorna al soltar botón derecho sin girar al combatiente fuera de su destinatario. Los agresores persiguen por toda la zona accesible (D22), sin reactivar automáticamente al protagonista ni permitir completar el objetivo final antes de resolver al guardián.
9. Huecos futuros desactivados, acción y objetivo visibles y ayuda comprensible a 1280 × 720. Verificación gráfica de palma, espada y ambos contactos de ráfaga.
10. Partida normal del bot con reglas de producción y prueba humana de claridad y equilibrio; no confundir un test de transiciones con una partida normal.
11. Diálogo posterior: rechazo y ataque tras escuchar inician combate pausado; aceptar permite paso con guardián vivo y no agresivo. Las tres rutas habilitan el objetivo final del templo y solo reclamarlo termina la misión; ninguna exige cuatro muertes. El objetivo no puede completarse antes de resolver al guardián.
12. Comprobar D17/D24: sin regalos de salud, energía o botiquines entre encuentros; leer todo el diálogo o saltarlo conserva los mismos recursos y no avanza física, daño ni regeneración. No queda Defensa como acción seleccionable; las estadísticas pasivas siguen resolviendo aciertos.

## Referencias de diseño

Las capturas de KOTOR II aportadas por el usuario son referencias de distribución. [Manual de KOTOR II](https://cdn.akamai.steamstatic.com/steam/apps/208580/manuals/KOTORII_Manual.pdf): interfaz, cola, pausa y formas. [Manual de KOTOR](https://cdn.steamstatic.com/steam/apps/32370/manuals/KOTORI_Manual.pdf#page=14): familias de ataques especiales. Los efectos y números de Kharuun son decisiones propias del prototipo.
