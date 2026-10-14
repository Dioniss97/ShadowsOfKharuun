# Diseño aprobado y entregado — Demo 0.3.0

Actualizado: 14 de octubre de 2026. Estado: **v0.3.0 estable, integrada en main; QA humana aprobada; D01–D36/B1–B8 implementados y comprobados (D27 sustituida por D33); milestone cerrado**.

Este documento conserva las decisiones y reglas entregadas en **v0.3.0** como base verificada de futuras iteraciones; no representa el diseño ni el backlog de 0.4.0. Las tareas históricas se conservan en [PENDIENTES.md](PENDIENTES.md) y las nuevas tareas se gestionan en GitHub Issues. Consultar [GESTION_DESARROLLO.md](GESTION_DESARROLLO.md) para planificar una nueva versión.

## Estado real y objetivo

La entrega anterior **0.2.0**, etiqueta `v0.2.0` y commit `f516f41`, tenía misión original de acción y duelo táctico separados. Su informe histórico permanece en esa etiqueta. **0.3.0** reúne la misión y el combate táctico, con D01–D36/B1–B8; D27 fue sustituida por D33. Q01/Q10 están resueltas e implementadas según la observación del usuario en KOTOR II. El usuario aceptó globalmente RC2 (`f8ada97`) el 14 de octubre: «Apruebo el QA de la 0.3.0». Las pruebas y sus límites están en [RESULTADO.md](RESULTADO.md); la entrega queda integrada y etiquetada, con las 21 issues y milestone cerrados. Esperar la definición de 0.4.

El objetivo entregado es **una única demo del asalto al templo con combate táctico integrado**, conservando exploración, diálogo, tres acólitos, guardián y finales. El jugador habla primero con el guardián para iniciar el encuentro con los acólitos y vuelve a hablar con él tras vencerlos para elegir entre combatir o conseguir el paso pacífico. El duelo se conserva internamente para pruebas. El proyecto es para un jugador y prioriza la historia.

## Decisiones confirmadas

| ID | Acuerdo vigente |
|---|---|
| D01 | Unificar el combate táctico con la misión del templo; dejar de presentar duelo y misión como dos experiencias principales distintas. |
| D02 | Tiempo real con pausa y rondas independientes por combatiente. Al iniciar un encuentro agresivo, seleccionar automáticamente al agresor más cercano que esté vivo, visible y alcanzable, sin incluir personajes neutrales. Pausa automática una vez al comenzar cada encuentro; Espacio permite pausar manualmente y preparar órdenes. |
| D03 | La cámara orbita arrastrando con el botón derecho. Al soltar conserva la vista si el personaje está parado o el mundo pausado. El retorno suave y rápido detrás del frente del personaje ocurre solo durante desplazamiento real; retroceder no gira ese frente. En combate el personaje encara el destinatario de su acción y orbitar no lo cambia. B1 conserva el arrastre derecho y esta regla de retorno; D33 confirma ahora A/D para girar al personaje, sustituyendo D27. |
| D04 | WASD no interrumpe ni borra órdenes durante el enfrentamiento automático. Primero se pulsa F o Cancelar combate para recuperar el movimiento libre. |
| D05 | Cancelar combate detiene órdenes y autoataque, y evita el reenganche inmediato del protagonista. Los enemigos siguen actuando. |
| D06 | Cada orden guarda su acción y destinatario al encolarse. Cambiar de selección o recorrer un selector no modifica las órdenes anteriores ni el ataque que está en curso. |
| D07 | Al vaciarse la cola, el básico automático se dirige al destinatario del último ataque ofensivo ejecutado, no a la última selección usada para preparar órdenes. |
| D08 | Si cae ese destinatario y no quedan órdenes válidas, continuar automáticamente contra otro agresor vivo, visible y alcanzable. Cambiar de enemigo en el mismo encuentro no provoca otra pausa inicial. |
| D09 | Los poderes consumen energía y tiempo de acción, sin recarga adicional por poder. Sus costes y la regeneración requieren equilibrio nuevo. |
| D10 | Dos ataques físicos en esta vuelta: básico y ráfaga. Ráfaga realiza dos intentos de impacto independientes dentro de una sola acción/ronda. |
| D11 | Tres poderes personales/ofensivos: empuje, descarga y curación propia. Curación siempre actúa solo sobre el protagonista en esta demo, conserva el último enemigo ofensivo y se elige en el selector personal inferior izquierdo (D32), no sobre el enemigo. |
| D12 | Tres botiquines iniciales con contador visible. Botiquín y poder curativo son órdenes en la misma cola, ocupan una acción y consumen su recurso al ejecutarse, no al encolarse. |
| D13 | Tres selectores compactos flotando por encima de la cabeza del enemigo seleccionado: ataques físicos, poderes ofensivos/de control y arrojadizos. Siguen su posición y la cámara; se muestran solo durante el enfrentamiento activo del protagonista, incluso pausado, con objetivo visible válido. Flechas o rueda cambian lo mostrado; pulsar el icono encola. El ataque básico también puede ordenarse directamente con el cursor y clic sobre el enemigo seleccionado (D30). Curación propia queda fuera de esta tarjeta (D32). No son tres ranuras de la cola ni una caja fija central. Revisión B2. |
| D14 | Menú personal inferior izquierdo con dos selectores separados: consumibles (por ahora, tres botiquines) y poderes personales (por ahora, curación propia). Los huecos futuros pueden quedar visibles y vacíos; escudo, formas y arrojadizos siguen desactivados en esta vuelta. |
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
| D25 | Giro continuo A/D y W+A/D en curvas/círculos, originalmente sustituido por D27; la QA posterior restaura este control en D33, que es la regla vigente. |
| D26 | El menú flotante usa la selección para preparar nuevas órdenes, sin reescribir la cola. Se oculta tras F y fuera del combate, durante diálogo/exploración/templo y con objetivo muerto, neutral, fuera de pantalla, oculto o detrás de cámara. Nombre/vida pertenecen al mismo seleccionado; D34 permite también vida de neutral, sin selectores ofensivos. No cubre su cara ni se recoloca arbitrariamente en el centro; si no cabe sobre el objetivo, se oculta. Clicar un agresor permite reenganchar. B2. |
| D27 | **Sustituida por D33 tras la nueva QA humana.** La interpretación anterior de A/D como órbita de cámara y W siguiendo la vista queda retirada. El control vigente gira al personaje con A/D y lo conduce con W/S. |
| D28 | **Básico automático condicionado al alcance cuerpo a cuerpo.** Al vaciarse la cola, el protagonista permanece en su sitio si el enemigo todavía está fuera del alcance cuerpo a cuerpo; no lo persigue ni empieza a atacar por iniciativa propia. Cuando el enemigo se acerca a ese alcance, comienza el básico automático contra el destinatario que corresponda según D07/D08. La pausa y selección automática de enemigo al comenzar el encuentro siguen siendo D02. Si en una futura situación el enemigo ataca a distancia mientras el protagonista no recibe una orden, puede dañarlo; el jugador debe actuar. |
| D29 | **Selección e interacción contextual con NPC.** El cursor del juego sustituye al puntero de Windows y comunica la acción disponible. Pasar el cursor por un personaje no seleccionado conserva el cursor normal; el primer clic lo selecciona y muestra con claridad la selección. En interacciones manuales aparece una acción/icono de voz y un segundo clic en esa acción inicia la interacción; E no es necesario. Cada acólito neutral responde con una frase breve de una lista rotativa de tres; los ejemplos aportados son orientativos, no texto final. La primera escena del guardián se activa automáticamente al acercarse, como en la demo actual, y da paso directamente al encuentro con los acólitos, que impiden el acceso. Tras vencerlos, se vuelve a seleccionar al guardián y a usar el icono de voz para la segunda conversación; solo al resolverla se abre el paso al templo. Esa conversación ofrece las ramas de D16. Antes de resolverla, no se puede llegar al orbe. |
| D30 | **Ataque básico contextual por clic, con destinatario fijo.** En combate, el cursor sobre un enemigo no seleccionado sigue siendo normal; el primer clic cambia la selección y la retícula circular segmentada para identificar al objetivo. Sobre el enemigo hostil ya seleccionado, el cursor adopta el símbolo de espada; hacer clic en ese objetivo encola un ataque básico dirigido a él. Ejemplo: encolar un crítico a A, seleccionar B y clicar B añade `Básico(B)` sin cambiar la acción actual ni órdenes anteriores, como `Crítico(A)`. Los neutrales usan la acción de voz de D29, nunca la espada. La nueva orden respeta la cola común; no golpea al instante ni altera la regla de básico automático de D07/D28. B5. |
| D31 | **Fallo al ejecutar por recurso insuficiente, observado en KOTOR II.** El recurso se comprueba al ejecutar, porque puede cambiar mientras la orden espera. Si un poder supera la energía actual al encolarlo, aparece gris y no se puede añadir. Si una orden de poder o botiquín se vuelve imposible antes de ejecutarse, se elimina esa orden y también las demás órdenes pendientes del mismo tipo (poderes de la Fuerza o botiquines). Si después de esa limpieza quedan otras órdenes válidas, la siguiente ocupa su lugar en la misma oportunidad del protagonista y no se pierde una ronda. Si no queda ninguna orden válida, la acción fallida consume el turno del protagonista sin efecto; en la siguiente acción se retoma el básico automático. Al terminar una orden válida y vaciarse la cola, se aplica D07. Los relojes de los combatientes siguen siendo independientes. |
| D32 | **Separar poderes personales del selector flotante de objetivo.** Abajo a la izquierda, un selector contiene consumibles (tres botiquines ahora) y otro poderes personales (curación propia ahora). Ambos encolan en la cola común y consumen el recurso al ejecutarse. Curación actúa solo sobre el protagonista en esta demo y nunca se añade al seleccionar un enemigo. La tarjeta sobre el enemigo conserva ataques físicos, poderes ofensivos/de control y arrojadizos. Sin compañeros en esta demo. Los potenciadores personales, como Velocidad de la Fuerza, quedan para después (FUT-09). B6. |
| D33 | **Conducir al personaje.** Mantener A gira al personaje a la izquierda y D a la derecha continuamente, hasta soltar. W avanza según su frente y W+A/D describe curvas/círculos; S retrocede sin invertir el frente. RMB conserva la órbita/persistencia de cámara y su retorno suave al desplazarse. En pausa no gira el actor; durante combate las órdenes encaran a su destinatario y F recupera el movimiento libre. Sustituye D27; B1. |
| D34 | **Vida solo de la selección.** Eliminar las barras 3D colectivas de enemigos. Nombre/vida solo aparecen sobre el personaje seleccionado, hostil o neutral, cuando esté vivo y visible. La selección puede prepararse automáticamente al iniciar el encuentro. Los tres selectores ofensivos siguen siendo exclusivos del combate; no aparecen sobre neutrales. B7. |
| D35 | **Orbe por ratón.** El orbe accesible ofrece cursor de mano. Clic solicita aproximación física y reclamación dentro del alcance; W/S puede cancelar el acercamiento. E no reclama el objetivo. La puerta y la resolución del guardián siguen siendo obligatorias; sin interacción a través de paredes ni final anticipado. B8. |
| D36 | **Proporciones del HUD de KOTOR II.** Abajo izquierda: poderes personales primero, luego consumibles y huecos futuros. En el centro: cuatro iconos pequeños pendientes, acción actual a la derecha y Cancelar debajo; destinatarios en tooltips, sin textos grandes por ranura. Retrato/recursos compactos a la derecha. Conservar capacidades, clics y atajos existentes. B7. |

La corrección D07 es explícita del usuario: `1→A, 2→B, 2→A` termina en `0→A`, donde 0 significa básico automático. Los números son una notación de acciones, no una petición de añadir más ataques a esta vuelta. Una curación posterior no convierte al protagonista en destinatario del autoataque.

## Alcance reducido y decisiones sustituidas

El usuario eligió inicialmente «toda la base» con ataques, escudo, granada y dos formas, pero después redujo expresamente esta vuelta. El alcance vigente contiene básico y ráfaga, empuje/descarga/curación, selector de poderes personales, botiquines y sus fallos de recurso acordados. Ataque crítico, ataque fuerte, escudo, formas, granadas de concusión o congelación, minas, inventario completo, combate a distancia nuevo, compañero, poderes personales que alteren atributos y modelos Blender quedan para después.

También quedan sustituidas las propuestas de que WASD cancele el combate, de mantener recargas adicionales de poderes y de continuar el autoataque contra el último enemigo seleccionado. Esas reglas pertenecen a `v0.2.0`; ya están retiradas de la build actual.

La oferta del guardián y su lección serán narrativas en esta vuelta. Registrar la ruta elegida para diálogo/final no requiere karma numérico, afiliación persistente, poderes aprendidos ni progresión; esos sistemas siguen aplazados. Escuchar la lección no obliga a aceptarla.

## Interacciones con el guardián y los acólitos

Flujo confirmado:

1. Al acercarse al guardián, la primera conversación empieza automáticamente, como en la demo actual. No se añade una confirmación; la escena conduce a que los acólitos reciban la orden de detener al protagonista y empieza ese encuentro.
2. Los acólitos neutrales se pueden seleccionar y hablar mediante el icono de voz. En vez de una conversación ramificada, cada uno dice una frase genérica breve; al repetir la interacción, se elige de una lista de tres frases. Los ejemplos «ten cuidado», «mi maestro no tendrá piedad» y «escoge bien tus palabras» son referencias de tono, no texto aprobado.
3. Tras derrotar a los acólitos, el jugador vuelve a seleccionar al guardián y usa el icono de voz para iniciar la segunda conversación. Hasta resolverla, la puerta/el acceso al orbe permanecen cerrados y el jugador no puede reclamar el objetivo.
4. En la conversación posterior, el guardián reconoce el potencial del protagonista, desprecia el nivel de sus aprendices y ofrece su doctrina. Tono culto y solemne; diálogo original, no copia de los textos de KOTOR.
5. **Rechazar:** el jugador no acepta ser corrompido; empieza el encuentro del guardián con la pausa inicial acordada.
6. **Indagar:** el guardián expone una lección breve sobre su doctrina. Después el jugador decide **aceptar el paso pacífico** o **atacarlo**.
7. En la ruta pacífica, el guardián permanece vivo y no agresivo, permite el paso y queda excluido de la selección automática de agresores. No debe bloquear físicamente la ruta. La puerta se abre y el objetivo se habilita solo tras este acuerdo o al derrotarlo.

La conversación posterior no permite agresión ni gasto de recursos. D24 confirma congelar el tiempo y los recursos durante esta transición narrativa: leer más despacio no restaura recursos gratuitamente. Conservar los valores de entrada según D17, sin reponer botiquines. Rechazar o atacar inicia el encuentro con su pausa inicial; aceptar devuelve la exploración con el guardián no agresivo.

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

- Sobre el enemigo seleccionado durante enfrentamiento: nombre, vida y tres selectores en una tarjeta compacta proyectada desde el mundo. Sigue al enemigo y a la cámara, deja la cara libre y se oculta al cancelar o salir de combate. El arrojadizo está desactivado con explicación; no aparenta una acción utilizable.
- Abajo, centro: acción actual con destinatario, recuperación, cola y Cancelar combate. Conservar como base una acción actual y cuatro órdenes pendientes, capacidad de la primera entrega.
- Abajo, izquierda: selector de consumibles con botiquín y contador, separado del selector de poderes personales con curación propia. Se prevén huecos futuros para utilidades; un hueco vacío se distingue de un botiquín implementado pero agotado. La tarjeta sobre el enemigo no contiene curación.
- Abajo, derecha: retrato, salud, energía y efectos del protagonista.
- Avisos breves de pausa, objetivo narrativo, orden descartada y recursos. Texto o iconos legibles complementan el color.

La selección usada para nuevas órdenes y el destinatario de la acción actual pueden ser distintos; la interfaz debe explicar ambos sin cambiar silenciosamente órdenes. El poder de curación aparece en el selector personal inferior izquierdo e indica «Sobre ti»; no debe aparecer en el selector ofensivo que flota sobre un enemigo.

## Base técnica que se conserva

Colisiones sólidas, aproximación física, comprobación de alcance y visibilidad, preparación/contacto/recuperación del arma y pausa que congela física, daño, estados y recursos. La duración de 2,6 s del jugador es un valor inicial heredado, no una reproducción exacta de KOTOR. Los valores concretos de daño, acierto, curación, energía y ritmo enemigo se ajustarán mediante pruebas.

Durante la ráfaga cada intento tiene su propio resultado y momento visible de contacto. Ambos pertenecen al mismo destinatario. Si pierde validez o sale de alcance entre intentos, no se transfiere el segundo impacto a otro enemigo. No debe haber golpes invisibles o duplicados.

## Estado de las dudas

No quedan decisiones de diseño abiertas para esta vuelta. Dudas cerradas: Q01 → D31 (observación del usuario en KOTOR II); Q10 → D31 (la siguiente orden válida ocupa el hueco de la orden sin recurso; solo se pierde turno si no queda ninguna); Q02 → D21 (curación con salud llena consume recurso y ronda), Q03 → D22 (persecución por toda la zona accesible), Q04 → D16, Q05 → D17, Q06 → D18, Q07 → D23 (reinicio de misión), Q08 → D19 y Q09 → D20. D24 confirma la propuesta de congelación durante el diálogo. Se conservan los identificadores para rastrear las respuestas anteriores; las propuestas antiguas de Q02/Q03 quedan sustituidas.

En el ejemplo `Descarga, Descarga, Ráfaga`, si la segunda descarga ya no se puede pagar, se retira junto con los poderes restantes y la ráfaga ocupa esa oportunidad sin perder turno. Cuando termina y la cola queda vacía, vuelve el básico automático de D07. Si la orden sin recurso era la última válida, se pierde esa acción y el básico automático vuelve en la siguiente acción del protagonista. El mismo criterio aplica a botiquines agotados y órdenes válidas de otras categorías.

Las propuestas no equivalen a respuestas del usuario. Si una duda pendiente es necesaria para el comportamiento que se está implementando y no se puede resolver por los acuerdos, consultarla con opciones. El usuario prefiere resolverlas antes de programar y recibir ese mismo formato si surge una duda importante durante el trabajo.

## Implementación entregada y límites

El usuario autorizó empezar a producir esta segunda vuelta el 12 de octubre. La misión, cola por destinatario, HUD, ataques, recursos, cámara, retirada y ramas del guardián están implementados en `feature/temple-tactical-demo`. El menú presenta una única misión principal; el duelo queda como herramienta interna mediante `--duel`.

En la primera prueba de esta build, el usuario solicita B1/B2: conservar órbita al estar quieto/pausado, mantener el retroceso sin reorientación y sustituir el panel central por selectores compactos sobre el enemigo solo en combate. B2/D13/D26 siguen verificados en rama. La interpretación D27 de A/D como órbita de cámara se implementó en RC1, pero la nueva QA humana la sustituye: D33 gira al personaje con A/D. No hay que leer la evidencia anterior de B1 como prueba de esta regla nueva.

Tras probar KOTOR II se acordaron B1 (#15), B3 (#17), B4 (#18) y B5 (#19). El usuario autorizó después completar la implementación y probar en local antes de validar. Están implementadas, junto con B6 (#20), en el mismo milestone y PR #14; la aceptación humana final llegó el 14 de octubre de 2026.

La protección provisional de Q01 que pausaba ante energía insuficiente se retiró. D31/Q01/Q10 están implementadas: limpiar órdenes del recurso fallido, ejecutar la siguiente válida en esa oportunidad, o perder una ronda si no queda ninguna. No hay una pausa adicional por falta de recursos. Los poderes inasequibles aparecen desactivados y no se encolan.

Ajustes técnicos: el botiquín agotado sigue D31 y nunca deja contador negativo. Cancelar una orden pendiente no gasta recursos; F después de iniciarse una acción no devuelve el gasto realizado. Una ráfaga cuyo enemigo muera o salga de alcance conserva la ronda y no redirige el segundo golpe. La aproximación usa física; no se añade navegación de mapas.

Valores iniciales para la prueba humana: salud 340, energía 100, regeneración 3/s, tres botiquines de 95; básico 26, ráfaga 17 × 2; empuje 30 por 24 de energía, descarga 58 por 32 y curación 68 por 28; ronda del jugador 2,6 s. Acólitos con 160 de salud y ronda de 3,8 s; guardián con 520 y ronda de 3 s. Son valores de equilibrio propios, modificables con evidencia. La defensa sigue siendo una estadística pasiva de acierto.

El núcleo reclamable del templo es el mismo en ambas rutas. Se añadió una cámara pequeña detrás del portal existente y un marcador visible del altar para concretar D20. D31/D32 están implementadas y comprobadas; D33–D36 se incorporaron en RC2 y recibieron la aprobación humana global. El cierre integra y etiqueta 0.3.0 sin nuevos cambios de comportamiento. El proyecto queda detenido hasta definir 0.4.

## Casos de regresión verificados para 0.3.0

1. Misión completa: menú → exploración → primera conversación con el guardián → acólitos → segunda conversación y resolución de combate o pacífica → templo/orbe → final; derrota, repetición y vuelta al menú.
2. Pausa inicial una vez por encuentro, órdenes durante ella y ausencia de agresión durante diálogo/presentación.
3. Dos enemigos vivos A/B: órdenes mezcladas `1A, 2B, 2A`, selección independiente y básico posterior contra A. Repetir intercalando curación.
4. Ráfaga: dos tiradas y contactos, una acción/ronda; muerte, interrupción, distancia u obstáculo entre intentos no provocan daño a otro objetivo.
5. Selección, flechas, rueda y botones con eventos reales de entrada; recorrer opciones no encola ni mueve la cámara.
6. Tres botiquines, encolado, cancelación, consumo único, agotamiento y curación parcial. Con salud llena, botiquín y poder curativo consumen recurso y una ronda igualmente (D21). Ningún contador negativo. Reiniciar la misión completa devuelve recursos iniciales y restablece enemigos, cola y ruta narrativa (D23).
7. Energía comprobada al ejecutar, curación sobre el protagonista y ausencia de recarga adicional. Nunca bloquear una cola silenciosamente.
8. F devuelve movimiento; WASD conserva órdenes antes de F. RMB permite orbitar; quieto/pausado se conserva la vista. A/D gira al personaje, W sigue su frente y W+A/D describe curvas; S retrocede sin invertirlo. El retorno suave ocurre al moverse. La cámara no cambia destinatarios. Con cola vacía, no iniciar aproximación ni ataque básico hasta que el enemigo entre en alcance cuerpo a cuerpo (D33/D28). Los agresores persiguen por toda la zona accesible (D22), sin reactivar automáticamente al protagonista ni permitir completar el objetivo antes de resolver al guardián.
9. Huecos futuros desactivados, acción y objetivo visibles y ayuda comprensible a 1280 × 720. La tarjeta compacta flota sobre la selección y deja la cara libre al moverse actor/cámara; se oculta según D26. Flechas/rueda/clic siguen funcionando y conservan destinos de cola. Verificar el cursor normal al pasar por un no seleccionado, la retícula de selección, el cursor espada y la secuencia `Crítico(A) → Básico(B)` (D30/B5). Verificación gráfica de palma, espada y ambos contactos de ráfaga.
10. Partida normal del bot con reglas de producción y prueba humana de claridad y equilibrio; no confundir un test de transiciones con una partida normal.
11. Cursor contextual: primer clic selecciona NPC y el icono de voz inicia interacciones manuales; E no es necesario. En combate, probar selección/retícula y cursor espada para encolar básicos con destinos distintos sin alterar la cola previa (D30/B5). La primera escena del guardián empieza al acercarse y conduce al encuentro con los acólitos; probar frases rotativas al hablar con ellos. Tras vencerlos, seleccionar y hablar otra vez con el guardián. Confirmar que acceso/orbe siguen bloqueados hasta resolver la segunda conversación. Rechazo/ataque inician combate pausado; acuerdo habilita paso con guardián vivo y no agresivo. Las tres rutas habilitan el objetivo final y solo reclamarlo termina la misión.
12. Comprobar D17/D24: sin regalos de salud, energía o botiquines entre encuentros; leer todo el diálogo o saltarlo conserva los mismos recursos y no avanza física, daño ni regeneración. No queda Defensa como acción seleccionable; las estadísticas pasivas siguen resolviendo aciertos.

## Referencias de diseño

Las capturas de KOTOR II aportadas por el usuario son referencias de distribución. [Manual de KOTOR II](https://cdn.akamai.steamstatic.com/steam/apps/208580/manuals/KOTORII_Manual.pdf): interfaz, cola, pausa y formas. [Manual de KOTOR](https://cdn.steamstatic.com/steam/apps/32370/manuals/KOTORI_Manual.pdf#page=14): familias de ataques especiales. Los efectos y números de Kharuun son decisiones propias del prototipo.


- QA posterior: el usuario confirma D33 (giro del actor), D34 (vida solo de selección), D35 (orbe por ratón/mano) y D36 (HUD compacto, poderes personales primero). La captura de KOTOR II recibida después de una imagen de Codex es la referencia visual válida. Mismo 0.3.0, PR #14, issues B7 #21 y B8 #22; no ampliar el alcance de 0.4.
