# Trabajo pendiente de la demo

Actualizado: 12 de octubre de 2026. Especificación: [DISENO_DEMO.md](DISENO_DEMO.md). La segunda vuelta sigue en diseño; estas tareas no se han implementado todavía.

Estados: **Pendiente de decisión**, **Planificado**, **En curso**, **Implementado**, **Verificado**, **Pospuesto**. Marcar Verificado solo con evidencia real. Actualizar este archivo y el diseño tras cada respuesta o entrega; no depender de recordar la conversación.

## Primera entrega

Duelo táctico y correcciones de arma/colisiones: **Verificados** en `f516f41`. Evidencia y límites en [RESULTADO.md](RESULTADO.md). Son la base existente, no el cierre de las tareas siguientes.

## Segunda vuelta

| ID | Tarea | Estado | Dependencias | Criterio para aceptarla |
|---|---|---|---|---|
| DEMO-01 | Cerrar las reglas pendientes | Pendiente de decisión | Q01–Q08 del diseño | Registrar respuestas o supuestos explícitos; ninguna propuesta aparece como decisión humana confirmada. |
| DEMO-02 | Integrar combate táctico en el asalto al templo | Planificado | DEMO-01: Q04/Q05/Q07 | Una entrada principal jugable; exploración, diálogo, tres acólitos, jefe y finales funcionan con el mismo sistema. |
| DEMO-03 | Separar selección, órdenes y destino del autoataque | Planificado | D06–D08 | `1A, 2B, 2A` continúa con básico A; cambiar selección no reescribe órdenes; curarse no pierde el último destinatario ofensivo. |
| DEMO-04 | Selectores de categorías y HUD | Planificado | DEMO-03, Q08 | Flechas/rueda solo recorren acciones; clic encola con destinatario visible; arrojadizos y huecos futuros permanecen desactivados. |
| DEMO-05 | Entrada de encuentros, cámara y retirada | Planificado | D02–D05, Q03/Q04 | Pausa una vez por encuentro; WASD no cancela; F libera; cámara retorna suave; no reenganche involuntario ni agresión durante diálogo. |
| DEMO-06 | Ráfaga y contacto del arma | Planificado | D10, DEMO-03 | Dos intentos independientes con contactos visibles dentro de una acción; el segundo no cambia de destinatario. |
| DEMO-07 | Empuje, descarga y curación con energía | Planificado | D09/D11/D15, Q01/Q02 | Sin recargas adicionales; consumo al ejecutar; curación propia; gesto izquierdo; descarga desde la palma y resultados legibles. |
| DEMO-08 | Botiquines y contador | Planificado | D12, Q02/Q05/Q07 | Empieza con tres, usa cola y consume una unidad por uso; cancelaciones, falta de unidades, curación parcial y reinicio son coherentes. |
| DEMO-09 | Ayuda y continuidad narrativa | Planificado | Q04/Q06, DEMO-04 | El jugador entiende seleccionar, recorrer, encolar, pausar y retirarse; acólitos/jefe no saltan textos ni mantienen órdenes inválidas. |
| DEMO-10 | Equilibrar la misión completa | Planificado | DEMO-02/06/07/08 | Costes, regeneración y presión de tres enemigos permiten decisiones; botiquín y poder curativo tienen utilidad distinta; prueba humana con claridad y dificultad anotadas. |
| DEMO-11 | Verificar y entregar | Planificado | DEMO-02–10 | Pruebas de los casos del diseño, capturas reales, bot normal y finales/reinicio; actualizar README y RESULTADO con evidencia actual. |

Los costes y daños provisionales son trabajo de equilibrio, no preguntas obligatorias al usuario por cada número. La posible falta de una decisión importante de experiencia sí se consulta mediante opciones antes de la parte dependiente.

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

Multijugador corresponde a otro proyecto según el usuario. Engram/Jira no son dependencias de esta demo; estos documentos pueden servir como base para una integración posterior.

## Registro de cambios de diseño

- 2026-10-12: primera ronda confirma misión unificada, pausa inicial, retorno de cámara, F previo a WASD, continuación entre agresores y poderes sin recarga adicional.
- 2026-10-12: el usuario reduce «toda la base»: escudo, formas, granadas y dos ataques especiales se aplazan; se reservan sus huecos visibles.
- 2026-10-12: segunda ronda confirma básico + ráfaga, empuje/descarga/curación propia y botiquines/curación en cola con consumo al ejecutar.
- 2026-10-12: corrección expresa del usuario: `1A, 2B, 2A → 0A`; el último destinatario ofensivo ejecutado gobierna la continuación automática.
- 2026-10-12: se consolidan estos acuerdos en Markdown y se separan las dudas de la implementación para retomar el proyecto sin depender del chat.
