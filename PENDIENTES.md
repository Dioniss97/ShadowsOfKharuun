# Trabajo pendiente de la demo

Actualizado: 14 de octubre de 2026. Especificación: [DISENO_DEMO.md](DISENO_DEMO.md). **v0.3.0 estable con QA humana aprobada** mediante «Apruebo el QA de la 0.3.0». RC2 (`f8ada97`) cumple D01–D36/B1–B8 (D27 sustituida por D33), con pruebas completadas sin fallos; Q01/Q10 resueltas e implementadas. PR #14 integrada en `main`; DEMO-01–13 y B1–B8 cerradas: **21 issues cerradas, 0 abiertas** en el milestone, también cerrado. La etiqueta `v0.3.0` conserva la entrega. Se espera la definición de 0.4. Evidencia en [RESULTADO.md](RESULTADO.md); recorrido humano en [QA_0_3_0.md](QA_0_3_0.md); rutina en [ORGANIZACION.md](ORGANIZACION.md). Los IDs enlazan al [milestone Demo 0.3.0](https://github.com/Dioniss97/ShadowsOfKharuun/milestone/1).

Estados: **Pendiente de decisión**, **Planificado**, **En curso**, **Implementado**, **Verificado**, **Aceptado**, **Cerrado**, **Pospuesto**. Verificado requiere evidencia real; Aceptado registra la aprobación humana y Cerrado la integración de la entrega. Actualizar este archivo y el diseño tras cada respuesta o entrega; no depender de recordar la conversación.

## Primera entrega

Duelo táctico y correcciones de arma/colisiones: **Verificados** en `f516f41`. Evidencia y límites en [RESULTADO.md](RESULTADO.md). Son la base existente, no el cierre de las tareas siguientes.

## Segunda vuelta

| ID | Tarea | Estado | Dependencias | Criterio para aceptarla |
|---|---|---|---|---|
| [DEMO-01](https://github.com/Dioniss97/ShadowsOfKharuun/issues/1) | Cerrar las reglas pendientes | Cerrado en v0.3.0 | D31; implementación en DEMO-07/08/11 | D31 implementada: limpieza del recurso fallido y siguiente orden válida sin pérdida de ronda; si no queda ninguna, recuperación y básico posterior. |
| [DEMO-02](https://github.com/Dioniss97/ShadowsOfKharuun/issues/2) | Integrar combate táctico en el asalto al templo | Cerrado en v0.3.0 | D01/D16/D17/D20/D23/D29, B4 | Integración, primera conversación, acólitos, segunda conversación por clic, acceso, objetivo común y reinicio comprobados. |
| [DEMO-03](https://github.com/Dioniss97/ShadowsOfKharuun/issues/3) | Separar selección, órdenes y destino del autoataque | Cerrado en v0.3.0 | D06–D08, D30, B5 | `1A, 2B, 2A` continúa con básico A; cambiar selección no reescribe órdenes; curarse no pierde el último destinatario ofensivo. B5 añade la ruta de cursor/clic para encolar un básico al objetivo seleccionado. |
| [DEMO-04](https://github.com/Dioniss97/ShadowsOfKharuun/issues/4) | Selectores de categorías y HUD | Cerrado en v0.3.0 | DEMO-03, D13/D19/D26/D30/D32, B2/B5/B6 | Flechas/rueda solo recorren acciones; clic encola con destinatario visible; tarjeta compacta sobre la selección solo en combate; selector flotante para físico, poderes ofensivos y arrojadizos. B6 incluye abajo a la izquierda un selector de consumibles y otro de poderes personales con curación propia; Defensa no es una orden. |
| [DEMO-05](https://github.com/Dioniss97/ShadowsOfKharuun/issues/5) | Entrada de encuentros, cámara y retirada | Cerrado en v0.3.0 | D02–D05/D16/D22/D33/D28 | Pausa/selección inicial, giro continuo del actor A/D, W según su frente, S sin invertir frente, espera del básico fuera de alcance y retirada/persecución comprobadas. |
| [DEMO-06](https://github.com/Dioniss97/ShadowsOfKharuun/issues/6) | Ráfaga y contacto del arma | Cerrado en v0.3.0 | D10, DEMO-03 | Dos intentos independientes con contactos visibles dentro de una acción; el segundo no cambia de destinatario. |
| [DEMO-07](https://github.com/Dioniss97/ShadowsOfKharuun/issues/7) | Empuje, descarga y curación con energía | Cerrado en v0.3.0 | D09/D11/D15/D21/D31/D32, B6 | Empuje/descarga son poderes ofensivos sobre objetivo; curación propia vive en el selector personal inferior izquierdo. Sin recargas; uso con salud llena consume energía y acción. Poderes inasequibles no se encolan; al fallar en ejecución se retiran junto a los demás poderes, y la siguiente orden válida ocupa su lugar. Si no queda ninguna válida, se pierde la acción y vuelve el básico automático en la siguiente. |
| [DEMO-08](https://github.com/Dioniss97/ShadowsOfKharuun/issues/8) | Botiquines y contador | Cerrado en v0.3.0 | D12/D17/D21/D23/D31 | Empieza con tres, usa cola y consume una unidad al ejecutar; con salud llena también consume recurso y acción. Cancelar antes conserva el recurso; al ejecutar sin unidades se eliminan los botiquines pendientes, y una orden válida posterior evita perder turno; si no queda ninguna, vuelve el básico automático en la siguiente. Reiniciar misión devuelve tres. |
| [DEMO-09](https://github.com/Dioniss97/ShadowsOfKharuun/issues/9) | Ayuda y continuidad narrativa | Cerrado en v0.3.0 | D16–D18/D24, DEMO-04; continuidad completa tras DEMO-12 | Ayuda breve omitible y avisos una vez. El cierre narrativo elimina órdenes inválidas y cumple D17/D24: tiempo y recursos congelados durante el diálogo, sin regalos entre encuentros. |
| [DEMO-10](https://github.com/Dioniss97/ShadowsOfKharuun/issues/10) | Equilibrar la misión completa | Cerrado en v0.3.0 | DEMO-02/06/07/08 | Costes, regeneración y presión de tres enemigos permiten decisiones; botiquín y poder curativo tienen utilidad distinta; prueba humana con claridad y dificultad anotadas. |
| [DEMO-11](https://github.com/Dioniss97/ShadowsOfKharuun/issues/11) | Verificar y entregar | Cerrado en v0.3.0 | DEMO-02–10/12/13, B1–B8 | Probar D01–D36 (D27 sustituida por D33) y B1–B8; recursos, selectores, cola compacta, vida solo de selección, conducción A/D, básico por clic, voz, núcleo con mano/ratón, rutas y reinicio. La aceptación humana cierra la verificación; actualizar README/RESULTADO antes del tag. |
| [DEMO-12](https://github.com/Dioniss97/ShadowsOfKharuun/issues/12) | Conversación ramificada y resolución pacífica del guardián | Cerrado en v0.3.0 | D16/D17/D20/D24/D29, B4 | Rechazar → combate; indagar → aceptar paso o atacar. Incluye conversación inicial que comienza acólitos e interacción de voz por clic. Guardián no agresivo tras acuerdo; sin karma ni poderes nuevos; tiempo/recursos congelados. |
| [DEMO-13](https://github.com/Dioniss97/ShadowsOfKharuun/issues/13) | Acceso y objetivo final común del templo | Cerrado en v0.3.0 | D20/D29, DEMO-02/12, B4 | Mantener puerta/orbe inaccesibles hasta resolver la segunda conversación. Acuerdo o derrota habilitan el paso; ambas rutas permiten reclamar el mismo objetivo. Dialogar o matar al guardián no termina la misión por sí solo. |

Los costes y daños provisionales son trabajo de equilibrio, no preguntas obligatorias al usuario por cada número. La posible falta de una decisión importante de experiencia sí se consulta mediante opciones antes de la parte dependiente.

Orden aplicado: integración/destinatarios, HUD, ataques/recursos y conversación/objetivo, seguido por B1–B8. No quedan dudas de diseño ni tareas abiertas de 0.3.0. No iniciar las FUT hasta que el usuario defina 0.4.

## Correcciones de la prueba humana de 0.3

Estas incidencias pertenecen al mismo milestone y PR #14 de 0.3.0. Las correcciones del usuario sustituyen las reglas anteriores donde se contradicen; todas recibieron la aprobación humana global.

| ID | Issue | Estado | Criterio de corrección |
|---|---|---|---|
| B1 | [#15](https://github.com/Dioniss97/ShadowsOfKharuun/issues/15) | Cerrado en v0.3.0 | D33: mantener A/D gira al actor, W/S lo conduce y W+A/D curva/círculo. S no invierte el frente; RMB conserva órbita libre y retorno al moverse. En combate se requiere F para mover/girar al actor. Sustituye D27. |
| B2 | [#16](https://github.com/Dioniss97/ShadowsOfKharuun/issues/16) | Cerrado en v0.3.0 | Selectores compactos proyectados sobre la selección, sin cubrir cara; seguimiento de actor/cámara, inputs y cola por destino intactos. Ocultar fuera de combate, tras F y ante objetivos no visibles/válidos. D13/D26. |
| B3 | [#17](https://github.com/Dioniss97/ShadowsOfKharuun/issues/17) | Cerrado en v0.3.0 | Cola vacía y enemigo fuera del alcance cuerpo a cuerpo: protagonista espera sin acercarse ni atacar; al entrar el enemigo en alcance, comienza el básico automático normal. No añade armas a distancia. D28. |
| B4 | [#18](https://github.com/Dioniss97/ShadowsOfKharuun/issues/18) | Cerrado en v0.3.0 | Cursor contextual; en interacciones manuales, primer clic selecciona y el icono de voz inicia la conversación por segundo clic, sin E. Acólitos: tres frases rotativas breves. Guardián: primera escena automática al acercarse y combate con acólitos; tras vencerlos, selección/clic para la segunda conversación; puerta/orbe bloqueados hasta acuerdo o derrota. D29; DEMO-12/13. |
| B5 | [#19](https://github.com/Dioniss97/ShadowsOfKharuun/issues/19) | Cerrado en v0.3.0 | Hover normal sobre enemigo no seleccionado; clic selecciona y muestra retícula segmentada; hover sobre el hostil seleccionado cambia a espada y otro clic encola Básico contra ese enemigo. No se cambian órdenes previas ni sus destinos. Neutrales conservan voz de B4. D30; DEMO-03/04/11 y B2. |
| B6 | [#20](https://github.com/Dioniss97/ShadowsOfKharuun/issues/20) | Cerrado en v0.3.0 | Abajo a la izquierda, poderes personales primero (curación propia) y consumibles después (botiquín). El selector flotante del enemigo conserva ataques físicos, poderes ofensivos/de control y arrojadizos; no contiene curación. Misma cola y consumo al ejecutar; la curación siempre es propia y no hay compañeros. D32/D36; DEMO-04/07/11. |
| B7 | [#21](https://github.com/Dioniss97/ShadowsOfKharuun/issues/21) | Cerrado en v0.3.0 | D34/D36: vida solo del seleccionado hostil/neutral; poderes personales primero, consumibles después; cola con iconos compactos y tooltips, retrato pequeño; conservar capacidad/destinos. |
| B8 | [#22](https://github.com/Dioniss97/ShadowsOfKharuun/issues/22) | Cerrado en v0.3.0 | D35: mano sobre orbe accesible, clic y aproximación física, pausa/cancelación, bloqueo por ruta/obstáculos, sin E final. |

La evidencia anterior `b54514e` conserva la comprobación de B2 y de la cámara anterior. RC1 comprobó D27, que ahora se sustituye por D33. RC2 vuelve a comprobar el giro del actor y comprueba D28–D32, cursor/retícula, voz, recursos y rutas completas. Resultados vigentes en RESULTADO; QA humana aprobada el 14 de octubre de 2026.

## Iteraciones posteriores

| ID | Función | Estado |
|---|---|---|
| FUT-01 | Escudo y otras utilidades personales | Pospuesto |
| FUT-02 | Granada de concusión o congelación; después minas | Pospuesto |
| FUT-03 | Ataque crítico y ataque fuerte | Pospuesto |
| FUT-04 | Formas y animaciones de bloqueo/contacto entre armas | Pospuesto |
| FUT-05 | Personajes detallados, modelos y animaciones elaborados | Pospuesto |
| FUT-06 | Compañeros, inventario/progresión y más decisiones narrativas | Pospuesto |
| FUT-07 | Biblia del universo y nuevas zonas/misiones tras pulir la demo | Pospuesto |
| FUT-08 | Karma, alineamiento, afiliación persistente y consecuencias de progresión | Pospuesto |
| FUT-09 | Poderes personales que modifican atributos o movimiento, como Velocidad de la Fuerza | Pospuesto |

Multijugador corresponde a otro proyecto según el usuario. Engram/Jira no son dependencias de esta demo; estos documentos pueden servir como base para una integración posterior.

## Registro de cambios de diseño

- 2026-10-12: primera ronda confirma misión unificada, pausa inicial, retorno de cámara, F previo a WASD, continuación entre agresores y poderes sin recarga adicional.
- 2026-10-12: el usuario reduce «toda la base»: escudo, formas, granadas y dos ataques especiales se aplazan; se reservan sus huecos visibles.
- 2026-10-12: segunda ronda confirma básico + ráfaga, empuje/descarga/curación propia y botiquines/curación en cola con consumo al ejecutar.
- 2026-10-12: corrección expresa del usuario: `1A, 2B, 2A → 0A`; el último destinatario ofensivo ejecutado gobierna la continuación automática.
- 2026-10-12: se consolidan estos acuerdos en Markdown y se separan las dudas de la implementación para retomar el proyecto sin depender del chat.
- 2026-10-12: tercera ronda confirma recursos conservados y ayuda breve omitible; retira Defensa como acción y conserva el cálculo pasivo existente. Añade conversación ramificada tras los acólitos, con combate o paso pacífico, sin karma/progresión.
- 2026-10-12: la falta de energía queda pendiente de prueba humana en KOTOR; el usuario plantea posible pérdida de ronda solo si la orden fallida era la última. No se confirma ni implementa esa hipótesis.
- 2026-10-12: el usuario confirma el cierre común: ambas rutas permiten entrar al templo y reclamar el mismo objetivo; se añade DEMO-13 y se cierra Q09.
- 2026-10-12: se añade changelog y rutina de inicio/cierre, con etiquetas retrospectivas 0.1.0/0.2.0 y próxima 0.3.0 todavía planificada. Se acota el bloqueo de Q01 y se separa integración de motor de ramas/final para evitar dependencias circulares. Engram 1.7.1 está instalado, pero no conectado como herramienta de esta sesión.
- 2026-10-12: entorno preparado a petición del usuario: repo privado `Dioniss97/ShadowsOfKharuun`, ramas y etiquetas subidas, milestone Demo 0.3.0 e issues #1–13. Engram 3.3.2 y plugin Codex configurados con respaldos, memoria anterior conservada y cinco resúmenes administrativos recuperables por MCP. El cliente debe recargarse antes de atribuir escrituras a una nueva sesión de agente. El código del juego sigue siendo 0.2.0 y el diseño D01–D20 permanece conservado.
- 2026-10-12: repaso previo a producción y nuevas respuestas D21–D24: curar con salud llena consume recurso y ronda, perseguir por toda la zona accesible, reiniciar misión completa con recursos iniciales y congelar tiempo/recursos durante el diálogo. Q02/Q03/Q07 quedan cerradas; Q01 sigue pendiente. Lectura de Engram verificada desde las herramientas de esta sesión con filtro exclusivo de proyecto; el hook bloquea escrituras por vínculo de sesión no confirmado. No se inicia producción.
- 2026-10-12: el usuario autoriza producir. Build de desarrollo en `feature/temple-tactical-demo`: misión táctica unificada, HUD/selectores/cola por objetivo, ráfaga y gestos, curación y tres botiquines, controles/pausa, diálogo del guardián y núcleo final en ambas rutas. Q01 conserva una protección temporal de pausa y orden intacta; no se da por resuelta. Pruebas automatizadas y bot normal registrados en RESULTADO; falta aceptación humana y no se etiqueta v0.3.0 definitiva.
- 2026-10-12: primera prueba humana de 0.3 comunica B1/B2 (#15/#16). El usuario confirma conservar órbita en reposo/pausa, retorno solo al moverse, S sin reorientación y giro continuo A/D; selectores compactos flotantes sobre la selección solo en combate. D03/D13 se corrigen y se añaden D25/D26; el PR #14 sigue en borrador y sin merge.
- 2026-10-13: KOTOR II aclara que A/D orbitan la cámara (D27), que el protagonista espera quieto fuera del alcance cuando la cola está vacía (D28), y que la primera escena del guardián se activa al acercarse mientras la segunda se inicia por clic tras los acólitos; el paso queda bloqueado hasta resolverla (D29). Se actualizan B1 #15 y DEMO-05/12/13; se crean B3 #17 y B4 #18; DEMO-11 añade la reaceptación. Solo documentación e issues; no se tocó la implementación.
- 2026-10-13: las capturas de combate aclaran el puntero normal al pasar por un objetivo no seleccionado, la retícula al seleccionarlo y el cursor de espada para encolar un básico al objetivo activo, conservando destinos previos (D30/B5 #19). Se enlaza con voz para neutrales (B4); DEMO-11 amplía casos a D30 y B1–B5. Solo documentación e issues; no se tocó la implementación.
- 2026-10-13: el usuario confirma Q01 por prueba en KOTOR II: acción sin energía consume el turno, elimina poderes restantes y deja un básico para la acción posterior; botiquín sin unidades sigue la misma regla y cancela sus órdenes restantes. Q10 deja abierta la cola mixta. D31/D32 definen disponibilidad en gris y los selectores personales de consumibles/curación. B6 #20 se añade a 0.3.0; Velocidad de la Fuerza y otros potenciadores quedan pospuestos (FUT-09). Sin cambios de código.
- 2026-10-13: el usuario aclara Q10: si tras retirar las órdenes sin recurso quedan otras órdenes válidas, la siguiente se ejecuta en esa oportunidad y no se pierde turno. Solo se pierde la acción si no queda ninguna; entonces vuelve el básico automático en la siguiente. D31/Q01/Q10 quedan cerradas como reglas; implementación y QA humana pendientes.

- 2026-10-13: el usuario autoriza terminar la implementación y probar en local antes de validar. B1–B6 y D31 quedan implementadas y comprobadas; candidata 0.3.0, PR #14 aún en borrador. La entrega final espera QA humana, después se detiene hasta definir 0.4.

- QA de RC1: las nuevas indicaciones del usuario se incorporan a RC2; se actualizan B1 y las dependencias DEMO-04/05/11/13, se crean B7/B8. Los 187/211 casos previos corresponden a RC1; evidencia nueva en RESULTADO.

- 2026-10-14: el usuario confirma «Apruebo el QA de la 0.3.0». Se acepta RC2 globalmente y se autoriza cerrar PR #14, DEMO-01–13/B1–B8, milestone y etiqueta final; después esperar la definición de 0.4. El cierre cambia solo versión, textos y documentación.

- 2026-10-14: PR #14 fusionada en main (1304678); las 21 issues se cerraron automáticamente al integrar y se verificó el milestone con 0 abiertas. Milestone cerrado y entrega identificada por v0.3.0. Proyecto detenido hasta definir 0.4.
