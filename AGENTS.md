# Shadows of Kharuun — instrucciones para agentes

RPG narrativo 3D para un jugador, desarrollado en Godot con Blender previsto para arte. Comunicar en español. Evitar sobreingeniería y distinguir decisiones aprobadas, propuestas, implementación real y verificación.

## Documentos y fuente de verdad

1. **Leer `docs/project/GESTION_DESARROLLO.md` antes de organizar tareas**: es la guía vigente y prevalece sobre instrucciones antiguas de gestión.
2. **Leer `docs/project/ORGANIZACION.md`** para convenciones del entorno, versión estable y rutina de trabajo.
3. **Consultar la issue de propuesta de alcance y las issues de trabajo aprobadas**. Las carpetas de `docs/versions/0.3.0/` y `docs/versions/0.4.0/` son archivo histórico, no especifican versiones nuevas. `docs/project/` contiene las guías y referencias comunes vigentes.
4. `README.md` explica cómo ejecutar la versión estable y `docs/project/CHANGELOG.md` resume lo publicado e identifica los tags/commits y referencias relacionadas disponibles. Las carpetas históricas conservan documentación y evidencia de 0.3.0 y 0.4.0.
5. **GitHub Issues es la única fuente de estado operativo de tareas.** No copiar ni mantener en paralelo sus estados en `docs/versions/0.3.0/PENDIENTES.md`: ese documento es registro histórico de 0.3.0 y propuestas FUT sin aprobación automática.
6. Registrar propuestas de alcance y trabajo de versiones en GitHub Issues. No crear carpetas ni Markdown por versión por defecto; reservar un archivo histórico solo para evidencia extensa que no convenga mantener en Issues/PRs. Actualizar `docs/project/` cuando cambie información común vigente y `docs/project/CHANGELOG.md` al publicar una entrega.

## Decisiones, planificación e implementación

- Distinguir el estado de decisión (`propuesta`, `pendiente de decisión`, `aprobada`, `descartada/sustituida`) registrado en la issue de alcance o trabajo, del estado operativo (`planificado`, `en-curso`, `verificado-en-rama`, `cerrada/entregada`) registrado con labels en GitHub Issues. Una decisión aprobada no implica que exista código.
- Durante exploración o diseño, no cambiar escenas/scripts ni interpretar la aprobación de una idea como petición de implementarla. Puede documentarse lo solicitado. Ejecutar desarrollo **solo cuando el usuario autorice el alcance**.
- Se permite una única issue de **propuesta de alcance** antes de aprobar una versión, usando `.github/ISSUE_TEMPLATE/propuesta-alcance-version.md`; debe indicar que no autoriza implementación. No crear milestone ni issues de diseño/implementación hasta aprobar explícitamente ese alcance. Tras aprobarlo, un milestone agrupa la versión y las issues de trabajo; la issue de propuesta queda como registro, no como tarjeta release.
- Mantener trazables en las issues las decisiones de alcance aprobadas, los criterios observables, las decisiones sustituidas y los enlaces pertinentes; conservar los IDs históricos sin inventar uno por cada idea. No reabrir acuerdos vigentes por falta de contexto ni convertir hipótesis en hechos.
- Antes de editar, comprobar rama, HEAD y cambios locales/no integrados. Trabajar en el alcance autorizado, evitando mezclar trabajo ajeno. Crear commits coherentes y PRs revisables; no sobreescribir la rama o cambios locales del usuario.
- Validar flujos afectados y regresiones, incluyendo pruebas reales de Godot/GPU cuando proceda. No marcar `verificado-en-rama` sin evidencia. La QA humana exigida debe quedar registrada antes de entregar. Nunca etiquetar trabajo futuro como versión estable.
- Al cerrar una sesión, registrar qué se hizo, qué falta, qué evidencia existe y el próximo paso **en el lugar correspondiente**, evitando duplicar el estado de la issue en Markdown.

## Engram

Memoria MCP **auxiliar**, subordinada a Git y GitHub. Proyecto exclusivo `shadowsofkharuun`: usar `project = shadowsofkharuun` y `scope = project`; no usar `all_projects` ni recuperar recuerdos ajenos. Recuperar por ID solo registros obtenidos con búsqueda filtrada. Si no carga o no puede escribir por fallo de identificación de sesión, continuar con Git/Issues y registrar la limitación; no usar CLI/SQL/HTTP para eludir hooks. No borrar ni reasignar memorias de otros proyectos.

**Base estable comprobada:** `v0.4.0` en `main`, PR #29, Vigía y pipeline Blender–Godot con presentación integrada aprobada. Las carpetas `docs/versions/0.3.0/` y `docs/versions/0.4.0/` conservan su archivo y evidencia histórica; no son plantilla obligatoria para futuras entregas. Planificar versiones siguientes está permitido; implementarlas requiere autorización. No introducir multijugador ni ampliar sistemas/universo fuera del alcance aprobado.
