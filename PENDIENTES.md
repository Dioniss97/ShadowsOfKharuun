# Trabajo pendiente de la demo

Actualizado: 12 de octubre de 2026. Especificación: [DISENO_DEMO.md](DISENO_DEMO.md). La segunda vuelta, prevista como **0.3.0**, sigue en diseño; estas tareas no se han implementado todavía. La entrega jugable actual es **0.2.0**; rutina y punto de reanudación en [ORGANIZACION.md](ORGANIZACION.md). Los IDs DEMO enlazan a sus issues del [milestone Demo 0.3.0](https://github.com/Dioniss97/ShadowsOfKharuun/milestone/1); el estado local resume el seguimiento en GitHub y se actualiza junto con cada issue.

Estados: **Pendiente de decisión**, **Planificado**, **En curso**, **Implementado**, **Verificado**, **Pospuesto**. Marcar Verificado solo con evidencia real. Actualizar este archivo y el diseño tras cada respuesta o entrega; no depender de recordar la conversación.

## Primera entrega

Duelo táctico y correcciones de arma/colisiones: **Verificados** en `f516f41`. Evidencia y límites en [RESULTADO.md](RESULTADO.md). Son la base existente, no el cierre de las tareas siguientes.

## Segunda vuelta

| ID | Tarea | Estado | Dependencias | Criterio para aceptarla |
|---|---|---|---|---|
| [DEMO-01](https://github.com/Dioniss97/ShadowsOfKharuun/issues/1) | Cerrar las reglas pendientes | Pendiente de decisión, por regla | Q01; Q02/Q03/Q07 cerradas en D21–D23, diálogo en D24 | Registrar cada respuesta o supuesto por separado. Solo Q01 espera la prueba del usuario y bloquea su comportamiento de energía; las demás tareas independientes pueden avanzar cuando se autorice implementar. |
| [DEMO-02](https://github.com/Dioniss97/ShadowsOfKharuun/issues/2) | Integrar combate táctico en el asalto al templo | Planificado | D01/D16/D17/D20/D23 | Los encuentros de la misión usan el motor táctico y sus transiciones admiten el diálogo/objetivo posterior y reinicio completo. Las ramas pacíficas y el cierre común se implementan en DEMO-12/13; el flujo completo se acepta en DEMO-11. |
| [DEMO-03](https://github.com/Dioniss97/ShadowsOfKharuun/issues/3) | Separar selección, órdenes y destino del autoataque | Planificado | D06–D08 | `1A, 2B, 2A` continúa con básico A; cambiar selección no reescribe órdenes; curarse no pierde el último destinatario ofensivo. |
| [DEMO-04](https://github.com/Dioniss97/ShadowsOfKharuun/issues/4) | Selectores de categorías y HUD | Planificado | DEMO-03, D19 | Flechas/rueda solo recorren acciones; clic encola con destinatario visible; arrojadizos y huecos futuros desactivados; Defensa no es una orden del jugador. |
| [DEMO-05](https://github.com/Dioniss97/ShadowsOfKharuun/issues/5) | Entrada de encuentros, cámara y retirada | Planificado | D02–D05/D16/D22 | Pausa una vez por encuentro; WASD no cancela; F libera; cámara retorna suave; los enemigos persiguen por toda la zona accesible; no reenganche involuntario ni agresión durante diálogo. |
| [DEMO-06](https://github.com/Dioniss97/ShadowsOfKharuun/issues/6) | Ráfaga y contacto del arma | Planificado | D10, DEMO-03 | Dos intentos independientes con contactos visibles dentro de una acción; el segundo no cambia de destinatario. |
| [DEMO-07](https://github.com/Dioniss97/ShadowsOfKharuun/issues/7) | Empuje, descarga y curación con energía | Planificado | D09/D11/D15/D21, Q01 | Empuje, descarga y curación propia sin recargas adicionales; consumo al ejecutar incluso con salud llena; gesto izquierdo; descarga desde la palma y resultados legibles. Q01 afecta solo al caso sin energía. |
| [DEMO-08](https://github.com/Dioniss97/ShadowsOfKharuun/issues/8) | Botiquines y contador | Planificado | D12/D17/D21/D23 | Empieza con tres, usa cola y consume una unidad por uso al ejecutarse; con salud llena también consume una unidad y una ronda. Cancelar antes de ejecutar conserva el recurso; agotamiento sin contador negativo; reiniciar misión devuelve tres. |
| [DEMO-09](https://github.com/Dioniss97/ShadowsOfKharuun/issues/9) | Ayuda y continuidad narrativa | Planificado | D16–D18/D24, DEMO-04; continuidad completa tras DEMO-12 | Ayuda breve omitible y avisos una vez. El cierre narrativo elimina órdenes inválidas y cumple D17/D24: tiempo y recursos congelados durante el diálogo, sin regalos entre encuentros. |
| [DEMO-10](https://github.com/Dioniss97/ShadowsOfKharuun/issues/10) | Equilibrar la misión completa | Planificado | DEMO-02/06/07/08 | Costes, regeneración y presión de tres enemigos permiten decisiones; botiquín y poder curativo tienen utilidad distinta; prueba humana con claridad y dificultad anotadas. |
| [DEMO-11](https://github.com/Dioniss97/ShadowsOfKharuun/issues/11) | Verificar y entregar | Planificado | DEMO-02–10/12/13 | Pruebas de los casos del diseño D01–D24, capturas reales, bot normal, las tres rutas del guardián y objetivo final/reinicio completo; actualizar README y RESULTADO con evidencia actual. |
| [DEMO-12](https://github.com/Dioniss97/ShadowsOfKharuun/issues/12) | Conversación ramificada y resolución pacífica del guardián | Planificado | D16/D17/D20/D24 | Rechazar → combate; escuchar → aceptar paso o atacar. Guardián no agresivo en diálogo/acuerdo; no karma ni poderes nuevos; tiempo y recursos congelados al dialogar y paso válido con guardián vivo. |
| [DEMO-13](https://github.com/Dioniss97/ShadowsOfKharuun/issues/13) | Acceso y objetivo final común del templo | Planificado | D20, DEMO-02/12 | Derrota del guardián o acuerdo habilitan el paso; ambas rutas permiten entrar y reclamar el mismo objetivo. No victoria inmediata al matarlo o dialogar, ni final anticipado durante un enfrentamiento sin resolver. |

Los costes y daños provisionales son trabajo de equilibrio, no preguntas obligatorias al usuario por cada número. La posible falta de una decisión importante de experiencia sí se consulta mediante opciones antes de la parte dependiente.

Orden orientativo al empezar la implementación: preparar DEMO-02/03, construir DEMO-04/05 y después ataques/recursos y conversación/objetivo. Puede avanzarse por componentes: documentar qué parte está implementada y qué regla queda pendiente. No esperar a cerrar todas las Q para trabajar en una tarea que no depende de ellas, ni exigir DEMO-12/13 para aceptar el motor de integración de DEMO-02.

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
