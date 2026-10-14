# Guía operativa de desarrollo — Shadows of Kharuun

**Adopción propuesta: 14-10-2026.** Protocolo ligero para un desarrollador y agentes Codex. No cambia las reglas de juego ni autoriza implementar funciones. El estado concreto de cada build se comprueba en su rama, PR y evidencias: no deducirlo de este documento.

## 1. Dónde vive cada cosa

| Pregunta | Fuente de verdad |
| --- | --- |
| ¿Qué se ha acordado exactamente? | Diseño Markdown versionado (IDs D/Q, versión de la decisión, alternativas y motivo). |
| ¿Qué debemos producir, qué depende de qué y qué falta? | GitHub Issues (criterios de aceptación, enlaces a D/Q, etiquetas y milestone). |
| ¿Qué está implementado realmente? | Commits y PRs, junto a evidencia de tests, capturas y pruebas humanas. |
| ¿Qué se ha entregado como estable? | Etiqueta Git vX.Y.Z + CHANGELOG.md + README.md y RESULTADO.md de esa etiqueta. |
| ¿Dónde está el contexto reciente de Codex? | Engram (caché auxiliar y limitada al proyecto); prevalecen Git y GitHub. |
| ¿Dónde veo un resumen visual? | Filtros de GitHub Issues y milestones; GitHub Projects solo si se habilita sin duplicar estados. |

**No duplicar:** una issue tiene su estado operativo en GitHub. En Markdown se conserva la especificación, índice por ID y enlaces, pero no una segunda tabla que haya que sincronizar tras cada movimiento. Una nota de un estado histórico puede permanecer si está fechada y marcada como histórica. La columna de estado de PENDIENTES.md y las instrucciones de actualización doble de ORGANIZACION.md son legado de la fase 0.3.0: no extender ese patrón a versiones nuevas. Su limpieza debe coordinarse con el merge del PR #14 para no sobrescribir la RC2.

## 2. Dos ciclos distintos

### Ciclo de una decisión (documentación, no código)

1. **Propuesta:** idea sin aprobación. Puede investigarse, descartarse o postergarse. No implica un ticket implementable.
2. **Pendiente de decisión:** alternativas definidas y falta una respuesta, una prueba del juego de referencia o investigación.
3. **Aprobada:** regla y alcance aceptados explícitamente; registrar ID, fecha/contexto, criterio observable y motivos. Sigue sin significar "implementada".
4. **Descartada/sustituida:** conservar el ID y enlazar la decisión que la sustituye; no borrar el rastro.

Un ID D/Q pertenece al diseño. Una decisión puede afectar a varias issues y una issue puede implementar varias decisiones. No abrir una issue por cada regla D. Las propuestas FUT son cartera de ideas, no compromisos de versión.

### Ciclo de una entrega (GitHub)

| Estado operativo | Representación actual | Significado |
| --- | --- | --- |
| Aprobado / pendiente de implementar | etiqueta 'planificado' + issue abierta | Alcance acordado y verificable; Codex puede trabajar solo cuando se autorice la implementación. |
| En curso | etiqueta 'en-curso' + issue abierta | Implementación activa o cierre de aceptación en curso. |
| En revisión / aceptación humana | etiqueta 'prueba-humana' cuando aplique; PR en borrador mientras no esté listo | Hay trabajo que requiere revisión; las pruebas automatizadas no sustituyen a una evaluación humana explícita. |
| Verificado en rama | etiqueta 'verificado-en-rama' + issue abierta | Evidencia satisfactoria en rama de desarrollo, pero aún no equivale a entrega estable. |
| Entregado | issue cerrada + PR integrado + etiqueta de versión | Forma parte de una versión estable aceptada. |

Mantener **una única etiqueta principal de avance**: 'planificado', 'en-curso' o 'verificado-en-rama'. 'prueba-humana' es una señal adicional de revisión/bloqueo humano, NO un estado principal excluyente. 'bug' y 'enhancement' indican tipo. No aplicar simultáneamente 'planificado' y 'verificado-en-rama'.

No cerrar tareas de una release antes de la aceptación que exige su definición. Si una regla pierde validez, actualizar el diseño, la issue y las pruebas necesarias; una verificación anterior de otra regla no cuenta.

## 3. Cómo dividir el trabajo

- **Milestone:** una entrega, por ejemplo Demo 0.3.0. Crear milestone 0.4.0 cuando su alcance esté aprobado; no asignar fechas ficticias.
- **Issue:** resultado comprobable: una funcionalidad, corrección o prueba. Enlace a decisiones D/Q pertinentes; criterios de aceptación y fuera de alcance explícitos.
- **Sub-issue:** solo si una funcionalidad necesita entregables independientes que tiene sentido verificar o asignar por separado. No dividir por archivos, clases o funciones.
- **Dependencia:** indicar "bloquea / bloqueada por" solo cuando una tarea NO se pueda terminar sin la otra. Tener relación de diseño no equivale a bloqueo.
- **PR:** lote coherente de implementación para una entrega. Draft mientras falte trabajo, pruebas o validación; PR puede abarcar varias issues.
- **Rama:** descriptiva, desde main para nueva funcionalidad después de autorización. No crear ramas de versión ni GitFlow por defecto.

La versión 0.3.0 está en el PR #14, rama feature/temple-tactical-demo, y debe permanecer aislada hasta su QA humana y merge. Las nuevas ideas 0.4+ no se deben incorporar a ese PR.

## 4. Flujo del diseño a una versión

1. **Explorar:** debatir en ChatGPT; distinguir ideas, evidencias y decisiones. No modificar código ni abrir tickets implementables por ideas aisladas.
2. **Aprobar diseño:** guardar el acuerdo en el documento de sistema correspondiente con ID estable; enlazar decisiones sustituidas y aspectos abiertos.
3. **Seleccionar versión:** acordar explícitamente un alcance mínimo jugable y qué queda excluido. No convertir todo FUT en un roadmap obligatorio.
4. **Crear tareas:** solo ahora abrir issues usando la plantilla "Funcionalidad aprobada"; añadir etiqueta 'planificado' y milestone aprobado. Relacionar sub-issues / bloqueos cuando proceda.
5. **Autorizar ejecución:** indicar a Codex versión, issue, decisiones aplicables y límites. La existencia de una issue planificada no es permiso para empezar.
6. **Implementar:** PR draft, commits rastreables y pruebas reproducibles. Codex actualiza la issue de lo realmente hecho; no marca "verificado" por haber escrito código.
7. **Revisar:** pruebas automatizadas, test gráfico real y QA humana cuando corresponda; registrar evidencia y fallos. Si un comportamiento aprobado cambia, volver a la fase de decisión.
8. **Entregar:** aceptación humana explícita cuando se exija, merge, actualizar README/RESULTADO/CHANGELOG, tag vX.Y.Z sobre el commit verificado y cierre de issues/milestone. No crear tags anticipados.

## 5. Consultas rápidas en GitHub

Abrir https://github.com/Dioniss97/ShadowsOfKharuun/issues y pegar en el campo de búsqueda:

~~~text
is:issue is:open label:planificado
~~~
Tareas **aprobadas para trabajar pero no iniciadas**. No es la lista completa de decisiones D aprobadas; esas viven en el diseño.

~~~text
is:issue is:open label:en-curso
~~~
Trabajo iniciado o aceptación en curso.

~~~text
is:issue is:open label:prueba-humana
~~~
Pruebas humanas pendientes.

~~~text
is:issue is:open label:verificado-en-rama
~~~
Verificado técnicamente, pero no liberado.

~~~text
is:issue is:open milestone:"Demo 0.3.0"
~~~
Tareas de la entrega actual.

Las funcionalidades aprobadas pero **todavía no entregadas** están entre los issues abiertos etiquetados con 'planificado', 'en-curso' o 'verificado-en-rama'. Si se necesita distinguir aprobado/entregado con exactitud por *cada* decisión D, habría que construir un índice en el diseño, no inventar estados adicionales de los issues. Filtrar "sin iniciar" no equivale a "todavía no publicado".

## 6. Tutorial: cinco operaciones típicas

**A. Diseñar 0.4.0 mientras se termina 0.3.0.** Abrir una conversación de diseño; anotar propuesta, alternativas y preguntas en el documento de sistema correspondiente o en un documento nuevo de diseño futuro. No editar escenas/scripts ni las issues 0.3.0. Después de aprobar un recorte concreto para 0.4.0, abrir su milestone e issues; dejar las propuestas no elegidas sin asignar a versión. No necesitas rama 0.4.0 hasta implementar.

**B. Convertir una decisión en tarea.** Copiar el ID D relevante a "Decisiones de referencia" de la plantilla de issue. Definir un resultado verificable por el usuario y al menos una prueba concreta. Añadir milestone, 'planificado' y, solo si hace falta, sub-issues o relaciones de bloqueo. Verifica que la nueva tarea aparece buscando 'label:planificado'.

**C. Enviar una tarea a Codex.** Pedirle leer AGENTS.md, el diseño vigente, esta guía y la issue. Especificar si la petición es "diseñar solamente" o "implementar"; prohibir que altere versiones fuera de alcance y exigir evidencia de tests. Usar una rama/PR separados del trabajo no integrado de otra versión.

**D. Revisar implementación.** Abrir el PR, comprobar diff, resultados de tests y pruebas manuales; si falta un criterio, mantener issue y PR abiertos. Si está implementada y verificada en rama, etiquetar 'verificado-en-rama'. Cuando se complete toda la release y se apruebe, cerrar las issues y milestone correspondientes después del merge/tag según la política de publicación.

**E. Recuperar el contexto.** Consultar la etiqueta estable, rama/PR actual, issues abiertas y documentos de diseño antes de mirar recuerdos de Engram. Si Engram está disponible en Codex, filtrar exclusivamente project='shadowsofkharuun', scope='project'. Si no está disponible o falla la escritura, continuar sin depender de él.

## 7. GitHub Projects, Engram y ODD

**GitHub Projects:** opcional. Si los filtros de issues dejan de bastar, crear **un solo** Project "Shadows of Kharuun" con una vista Tabla (por milestone) y otra Tablero (por estado). Usar las mismas issues, sin duplicarlas como notas; no duplicar sus etiquetas en campos personalizados que haya que sincronizar. No configurar automatizaciones ni un Project por versión hasta demostrar que ahorra tiempo. Su configuración queda pendiente de acceso/permisos, no se declara instalada.

**Engram:** mantener como memoria útil para reanudar conversaciones Codex, siempre subordinada a Git. No guardar una copia literal de cada decisión D ni usarla para contestar por encima de la especificación del repositorio. Verificar integración de escritura y atribución de sesión antes de depender de nuevos recuerdos.

**Gentle AI / ODD:** no adoptado. Evaluarlo solo con una prueba limitada: un requisito, decisión explícita, una issue y una PR. Si añade más artefactos o sincronizaciones sin mejorar trazabilidad y verificación, descartarlo. No instalarlo por defecto.

## 8. Regla de transición por la 0.3.0

Este documento se introduce en la rama estable sin tocar feature/temple-tactical-demo. El PR #14 puede llevar documentación más reciente de la RC2 que main: **consultar primero la rama del PR para el estado de 0.3.0** y no reescribirla a partir de main. Tras el merge de 0.3.0, consolidar ORGANIZACION.md, AGENTS.md y PENDIENTES.md con esta regla de fuente única, eliminando tablas duplicadas sin perder IDs, decisiones ni evidencia histórica.

No ejecutar cambios de gameplay, crear etiqueta final, fusionar PR #14 ni declarar aprobada una nueva versión como consecuencia de esta reorganización.
