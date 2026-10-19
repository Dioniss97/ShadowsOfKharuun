# Gestión del desarrollo — Shadows of Kharuun

**Procedimiento vigente desde el 14 de octubre de 2026; actualizado el 19 de octubre de 2026.** Proyecto de un desarrollador asistido por Codex. La última entrega estable al adoptar este flujo es **v0.4.0**. Esta guía organiza el trabajo; por sí sola no aprueba la 0.5.0 ni autoriza implementar.

## 1. Una fuente de verdad por responsabilidad

| Qué quiero saber | Fuente de verdad |
|---|---|
| Diseño vigente de mundos, sistemas, narrativa, assets, audio o interfaz | Ficha canónica de `docs/design/`, con estado de diseño, criterios, referencias y rutas. |
| Alcance de versión y estado del trabajo | GitHub Issues y sus milestones. Las Issues enlazan las fichas pertinentes y conservan el alcance de la tarea, sus criterios y su avance. |
| Qué tarea está pendiente, en marcha, bloqueada o probada | **GitHub Issues**. Su estado operativo, milestone y criterios de aceptación viven aquí, no en una segunda tabla Markdown. |
| Qué código se ha escrito y revisado | Commits y pull requests, con pruebas y evidencias. |
| Qué versión está entregada | Tag inmutable `vX.Y.Z`, `README.md` y `docs/project/CHANGELOG.md`; cada entrada identifica el tag/commit y referencia las PRs e issues pertinentes cuando estén disponibles. |
| Cómo debe actuar Codex | `AGENTS.md` (entrada breve) y esta guía. |
| Convenciones técnicas y configuración local | `docs/project/ORGANIZACION.md`. |
| Memoria de conversaciones de Codex | Engram, **auxiliar**; jamás prevalece sobre Git y GitHub. |

**Regla antisincronización:** no actualizar `docs/versions/0.3.0/PENDIENTES.md` después de cambiar cada Issue. Ese archivo y `docs/versions/0.3.0/`, `docs/versions/0.4.0/` son archivo histórico. Para versiones nuevas, mantener alcance y avance en Issues; mantener en `docs/design/` el diseño persistente vigente. Si cambia el diseño, actualizar su ficha; si avanza el trabajo, actualizar la Issue. Enlazar, no duplicar estados ni copiar la especificación completa.

## 2. Estado de decisión y estado de entrega son independientes

**Estado de diseño y decisión de alcance:**

| Estado | Qué significa |
|---|---|
| Propuesta | Idea todavía no aceptada. No se implementa. |
| Pendiente de decisión | Hay alternativas o investigación necesaria. No se asume la respuesta. |
| Aprobada | Se ha aceptado explícitamente una regla o un alcance concreto; **no** significa que exista en el juego. |
| Descartada / sustituida | Conservar razón y referencia a la decisión que la reemplaza. |

El mismo vocabulario se aplica a dos objetos distintos: la ficha de `docs/design/` expresa el estado del diseño y la Issue de propuesta expresa el estado de aprobación del alcance. Una Issue de trabajo enlaza la ficha y mantiene sus propios criterios y estado operativo. El contenido canónico y vigente del diseño reside en la ficha; la Issue evita duplicarlo. Las decisiones históricas D01–D36 pertenecen a 0.3.0 y conservan su identidad en el archivo histórico; no es necesario asignar un ID a cada asset o idea.

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

- **Una issue de propuesta de alcance** antes de aprobar una versión: usar `.github/ISSUE_TEMPLATE/propuesta-alcance-version.md`, registrar que su estado es `propuesta` y no asignarle milestone. Esta issue no autoriza implementación.
- **Después de aprobar el alcance**, crear un milestone para la versión y issues por resultado verificable; agruparlas en ese milestone. No crear carpetas o Markdown por versión por defecto.
- **Una Issue por resultado verificable**, con alcance, criterios y fuera de alcance. Usar `.github/ISSUE_TEMPLATE/funcionalidad-aprobada.md`; si el trabajo afecta a un diseño persistente, enlazar y actualizar su ficha canónica en `docs/design/`.
- **No duplicar la tarjeta release:** la issue de propuesta guarda la decisión de alcance y se cierra tras registrarla; el milestone agrupa el trabajo aprobado. Una issue padre adicional solo corresponde a una funcionalidad amplia y divisible en resultados independientes.
- **Sub-issues nativas** cuando realmente haya entregables separables; no dividir por archivos o clases. Una issue padre no está entregada por completar solo una de sus hijas.
- **Dependencias nativas** «blocked by / blocking» solo para impedimentos reales; las demás relaciones se resuelven enlazando la issue de alcance, las issues de trabajo o la documentación común pertinente.
- **PR** por cambio o conjunto coherente. No es obligatorio un PR por issue ni un PR gigante por versión; escoger lo más fácil de revisar y probar. Usar borrador mientras el alcance o la evidencia estén incompletos.
- **Ramas** descriptivas desde la base integrada pertinente. Evitar GitFlow y ramas de release por costumbre.

## 4. Pasar de conversación a desarrollo

1. **Explorar.** Debatir opciones en la conversación especializada. Marcar qué es hipótesis, propuesta, duda o acuerdo; no tocar código por el mero hecho de explorar.
2. **Proponer el alcance.** Crear una issue con `.github/ISSUE_TEMPLATE/propuesta-alcance-version.md`. Registrar objetivo, candidatos a incluir, exclusiones, criterios observables y dudas. Mantener el estado como `propuesta`; esta issue no autoriza código ni tareas de implementación.
3. **Aprobar el alcance.** Acordar expresamente qué entra **y qué no**. Las propuestas FUT de `docs/versions/0.3.0/PENDIENTES.md` no se aprueban por estar listadas. Una vez aprobado el alcance, actualizar el cuerpo de la issue con la decisión, crear el milestone y cerrar la issue de propuesta como registro.
4. **Desglosar.** Crear Issues de diseño, implementación y QA por resultados verificables, usando `.github/ISSUE_TEMPLATE/funcionalidad-aprobada.md`; enlazarlas a la Issue de alcance y al milestone. Las Issues de diseño enlazan la ficha canónica de `docs/design/`; conservan alcance y criterios de trabajo sin duplicar la especificación. Crear subtareas o bloqueos solo donde aporten claridad.
5. **Autorizar.** Codex implementa únicamente Issues/objetivos autorizados por el usuario. Antes lee `AGENTS.md`, esta guía, las Issues pertinentes, las fichas de diseño y los documentos comunes relacionados; revisa su rama y cambios locales.
6. **Construir.** Commits y PRs con pruebas automáticas y visuales cuando proceda; registrar evidencia, limitaciones y efectos en otras mecánicas. Actualizar las Issues cuando avance el trabajo y las fichas de `docs/design/` cuando cambie el diseño vigente.
7. **Revisar.** Corregir fallos, verificar regresiones y obtener QA humana explícita cuando forme parte de la aceptación. Si cambia una regla, actualizar su decisión y pruebas, no tratar una validación antigua como vigente.
8. **Entregar.** Tras verificar y aceptar la entrega, fusionar cambios, actualizar los documentos comunes afectados y añadir al `CHANGELOG.md` el resumen efectivamente publicado con enlaces a tag, PRs e issues. Etiquetar el commit de entrega y cerrar issues/milestone. No crear documentación Markdown por versión salvo una necesidad excepcional de evidencia extensa; nunca crear o mover tags por diseños o builds incompletas.

La base jugable publicada se identifica en README, ORGANIZACION y su tag inmutable. Un diseño nuevo no cambia esa base ni autoriza desarrollar componentes FUT por iniciativa propia.

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

El alcance de versión se consulta en la Issue de propuesta; el diseño vigente, en su ficha de `docs/design/`; las etiquetas de Issues describen el avance operativo. `docs/project/` conserva referencias técnicas comunes y `CHANGELOG.md` resume solo lo publicado.

## 6. Herramientas opcionales

**GitHub Projects:** no es parte obligatoria del flujo. Si los filtros no bastan, plantear **un único** Project con vistas por milestone y estado, utilizando las issues existentes. Antes de crearlo comprobar que Codex puede leer/actualizarlo mediante sus credenciales; no mantener campos de estado en Projects y etiquetas en paralelo sin automatización demostrada.

**Engram:** memoria local de Codex, útil para reanudar sesiones. Si el MCP falla, seguir con los archivos e issues. En `docs/project/ORGANIZACION.md` consta la incidencia histórica de escritura, no una prueba de que siga fallando hoy. No copiar especificaciones completas a Engram ni recuperar recuerdos ajenos al proyecto.

**Herramientas de agentes:** no se exige una integración o marco específico para trabajar en este repositorio. Las instrucciones de `AGENTS.md` y esta guía definen el flujo; Engram permanece como memoria auxiliar, no como fuente de requisitos ni de estado operativo.
## 7. Documentos históricos de las entregas 0.3.0 y 0.4.0

- `docs/versions/0.3.0/DISENO_DEMO.md`: decisiones y especificación entregada de 0.3.0.
- `docs/versions/0.3.0/PENDIENTES.md`: registro cerrado de sus 21 issues y catálogo de ideas FUT sin versión aprobada.
- `docs/versions/0.3.0/QA_0_3_0.md`, `docs/versions/0.4.0/QA_0_4_0.md` y `docs/versions/0.4.0/RESULTADO.md`: evidencias y aceptación.
- `docs/versions/0.3.0/COMBATE.md`: comportamiento técnico de la versión estable 0.3.0, que podrá evolucionar solo con nuevas decisiones verificadas.

No volver a editar esos documentos para reflejar el avance de versiones posteriores. A partir de 0.5.0, Issues y el changelog sostienen el registro de alcance, trabajo y entregas; crear una carpeta histórica nueva solo si una entrega produce evidencia extensa que no conviene mantener en issues/PRs. Los detalles del entorno y de la organización antigua se pueden recuperar con `git show v0.3.0:ORGANIZACION.md`.
