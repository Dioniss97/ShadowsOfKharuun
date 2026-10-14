# Gestión del desarrollo — Shadows of Kharuun

**Procedimiento vigente desde el 14 de octubre de 2026.** Proyecto de un desarrollador asistido por Codex. La última entrega estable al adoptar este flujo es **v0.3.0**. Esta guía organiza el trabajo; por sí sola no aprueba la 0.4.0 ni autoriza implementar.

## 1. Una fuente de verdad por responsabilidad

| Qué quiero saber | Fuente de verdad |
|---|---|
| Requisito, decisión aprobada, propuesta o cuestión abierta | Documento Markdown de diseño correspondiente, en Git. Las decisiones importantes tienen ID, estado y criterio observable. |
| Qué tarea está pendiente, en marcha, bloqueada o probada | **GitHub Issues**. Su estado operativo, milestone y criterios de aceptación viven aquí, no en una segunda tabla Markdown. |
| Qué código se ha escrito y revisado | Commits y pull requests, con pruebas y evidencias. |
| Qué versión está entregada | Tag inmutable `vX.Y.Z`, más `README.md`, `RESULTADO.md` y `CHANGELOG.md` de ese commit. |
| Cómo debe actuar Codex | `AGENTS.md` (entrada breve) y esta guía. |
| Convenciones técnicas y configuración local | `ORGANIZACION.md`. |
| Memoria de conversaciones de Codex | Engram, **auxiliar**; jamás prevalece sobre Git y GitHub. |

**Regla antisincronización:** no actualizar `PENDIENTES.md` después de cambiar cada issue. Ese archivo conserva el registro de la 0.3.0 y una lista de ideas FUT; no es el backlog operativo de versiones nuevas. Si una decisión cambia, modificar el diseño; si una tarea avanza, modificar su issue; si el comportamiento cambia, aportar código y evidencia al PR. Enlazar, no copiar.

## 2. Estado de decisión y estado de entrega son independientes

**Decisiones (en Markdown):**

| Estado | Qué significa |
|---|---|
| Propuesta | Idea todavía no aceptada. No se implementa. |
| Pendiente de decisión | Hay alternativas o investigación necesaria. No se asume la respuesta. |
| Aprobada | Se ha aceptado explícitamente una regla o un alcance concreto; **no** significa que exista en el juego. |
| Descartada / sustituida | Conservar razón y referencia a la decisión que la reemplaza. |

La decisión debe especificar un comportamiento comprobable y, si aplica, las issues que lo materializan. No crear una issue por cada ID `Dxx`; varias reglas pueden alimentar una sola tarea, y una regla puede afectar a varias tareas. Los IDs existentes D01–D36 pertenecen a la 0.3.0; conservar su identidad e indicar cuándo una nueva decisión los sustituye.

**Entregas (en GitHub):**

| Situación | Representación |
|---|---|
| Aprobada para desarrollo, no iniciada | Issue abierta con `planificado` y criterios de aceptación. |
| Implementación iniciada | Issue abierta con `en-curso`. |
| Pendiente de revisión | PR abierto (borrador o listo para revisión según madurez); `prueba-humana` si requiere aceptación del usuario. |
| Verificada en rama | Issue abierta con `verificado-en-rama` y enlaces a pruebas; **aún no es una entrega estable**. |
| Entregada | PR integrado y tag de release, issue cerrada según política de aceptación del milestone. |

De `planificado`, `en-curso` y `verificado-en-rama` usar **una sola etiqueta de avance por issue**. `prueba-humana` es una marca adicional que puede coexistir; `bug` y `enhancement` son tipos. No añadir etiquetas de aprobación redundantes: una issue `planificado` solo se crea para un alcance previamente aprobado. **Estar planificada no es permiso automático para que Codex programe.**

Una tarea parcialmente completada no se marca `verificado-en-rama` mientras falten criterios; explicar avances y bloqueos en su descripción o comentarios.

## 3. Versiones, issues y jerarquía

- **Un milestone por entrega**: por ejemplo `0.4.0`, únicamente cuando se haya acordado el alcance. No asignar fechas inventadas ni crear milestones para cada idea futura.
- **Una issue por resultado verificable**, con título, alcance, decisiones de referencia, criterios y fuera de alcance. Usar `.github/ISSUE_TEMPLATE/funcionalidad-aprobada.md`.
- **Una issue padre por funcionalidad amplia** solo si requiere varias sub-issues con resultados independientes. El milestone **ya agrupa la versión**: no crear una issue padre «versión 0.4.0» que solo duplique al milestone.
- **Sub-issues nativas** cuando realmente haya entregables separables; no dividir por archivos o clases. Una issue padre no está entregada por completar solo una de sus hijas.
- **Dependencias nativas** «blocked by / blocking» solo para impedimentos reales; las demás relaciones se resuelven enlazando diseño o issues.
- **PR** por cambio o conjunto coherente. No es obligatorio un PR por issue ni un PR gigante por versión; escoger lo más fácil de revisar y probar. Usar borrador mientras el alcance o la evidencia estén incompletos.
- **Ramas** descriptivas desde la base integrada pertinente. Evitar GitFlow y ramas de release por costumbre.

## 4. Pasar de conversación a desarrollo

1. **Explorar.** Debatir opciones en la conversación especializada. Marcar qué es hipótesis, propuesta, duda o acuerdo; no tocar código por el mero hecho de explorar.
2. **Especificar.** Abrir un documento de versión, por ejemplo `DISENO_0_4_0.md`, cuando la planificación lo requiera; registrar decisiones, criterios de éxito, dudas y elementos descartados. Puede empezar en estado `borrador` y no presupone alcance aprobado.
3. **Aprobar alcance.** Acordar qué entra **y qué no** en la próxima entrega. Las propuestas FUT de `PENDIENTES.md` no se aprueban por estar listadas. Solo entonces crear milestone y backlog ejecutable.
4. **Desglosar.** Crear issues con la plantilla y vincularlas al milestone. Referir IDs y secciones de diseño; crear hijas y bloqueos solo donde aporten claridad. Incluir una tarea de QA/entrega si hay aceptación conjunta que comprobar.
5. **Autorizar.** Codex implementa únicamente issues/objetivos autorizados por el usuario. Antes lee `AGENTS.md`, esta guía, diseño activo e issue; revisa su rama y cambios locales.
6. **Construir.** Commits y PRs con pruebas automáticas y visuales cuando proceda; registrar evidencia, limitaciones y efectos en otras mecánicas. Actualizar las issues, no duplicar una tabla de estados en Markdown.
7. **Revisar.** Corregir fallos, verificar regresiones y obtener QA humana explícita cuando forme parte de la aceptación. Si cambia una regla, actualizar su decisión y pruebas, no tratar una validación antigua como vigente.
8. **Entregar.** Tras aceptar el alcance, fusionar cambios, actualizar documentación de uso y resultados, etiquetar el commit de entrega y cerrar issues/milestone. Nunca crear ni mover tags por diseños o builds incompletas.

Mientras se diseña 0.4.0, la base jugable publicada sigue siendo v0.3.0. No desarrollar componentes FUT por iniciativa propia.

## 5. Consultas útiles (GitHub Issues)

Abrir [Issues](https://github.com/Dioniss97/ShadowsOfKharuun/issues) y buscar:

```text
is:issue is:open label:planificado
```
Tareas con diseño aprobado que todavía no se han iniciado.

```text
is:issue is:open label:en-curso
```
Trabajo/aceptación en marcha.

```text
is:issue is:open label:prueba-humana
```
Trabajo que necesita evaluación humana.

```text
is:issue is:open label:verificado-en-rama
```
Trabajo comprobado técnicamente pero aún no entregado.

```text
is:issue is:open milestone:"0.4.0"
```
Ejemplo **solo si se crea un milestone con ese nombre exacto**. Si el título es «Demo 0.4.0», adaptar el filtro.

Las búsquedas de issues muestran entregables, **no el listado exacto de decisiones D aprobadas pero no implementadas**. Para eso se consulta el documento de diseño y sus enlaces a issues. No prometer que una etiqueta de issue resuelve automáticamente esa consulta a nivel de reglas individuales.

## 6. Herramientas opcionales

**GitHub Projects:** no es parte obligatoria del flujo. Si los filtros no bastan, plantear **un único** Project con vistas por milestone y estado, utilizando las issues existentes. Antes de crearlo comprobar que Codex puede leer/actualizarlo mediante sus credenciales; no mantener campos de estado en Projects y etiquetas en paralelo sin automatización demostrada.

**Engram:** memoria local de Codex, útil para reanudar sesiones. Si el MCP falla, seguir con los archivos e issues. En `ORGANIZACION.md` consta la incidencia histórica de escritura, no una prueba de que siga fallando hoy. No copiar especificaciones completas a Engram ni recuperar recuerdos ajenos al proyecto.

**Gentle AI / ODD:** aún no adoptado. Estudiarlo con un caso reducido y aceptar solo si reduce trabajo real; no instalarlo como requisito para 0.4.0.

## 7. Documentos históricos de la 0.3.0

- `DISENO_DEMO.md`: decisiones y especificación entregada de 0.3.0.
- `PENDIENTES.md`: registro cerrado de sus 21 issues y catálogo de ideas FUT sin versión aprobada.
- `QA_0_3_0.md` y `RESULTADO.md`: evidencias y aceptación.
- `COMBATE.md`: comportamiento técnico de la versión estable 0.3.0, que podrá evolucionar solo con nuevas decisiones verificadas.

No volver a editar esas tablas históricas para reflejar el avance de 0.4.0. Los detalles del entorno y de la organización antigua se pueden recuperar con `git show v0.3.0:ORGANIZACION.md`.
