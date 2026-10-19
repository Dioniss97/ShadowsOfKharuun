# Documentación

La documentación del repositorio separa referencias comunes vigentes, propuestas/trabajo en GitHub Issues e historial publicado en el changelog. No se crea una carpeta Markdown por cada versión.

## Documentación vigente

- [Gestión del desarrollo](project/GESTION_DESARROLLO.md): alcance, Issues, autorización y rutina de trabajo.
- [Organización técnica](project/ORGANIZACION.md): convenciones del entorno y base estable.
- [Recursos y procedencia](project/ASSETS.md): inventario, créditos y licencias.
- [Historial de entregas](project/CHANGELOG.md): resumen cronológico de las entregas efectivamente publicadas.

## Plantillas de Issues

- [Propuesta de alcance de versión](../.github/ISSUE_TEMPLATE/propuesta-alcance-version.md): propuesta no ejecutable antes de aprobar el alcance.
- [Trabajo aprobado](../.github/ISSUE_TEMPLATE/funcionalidad-aprobada.md): issue para diseño, implementación o QA aprobados.

## Archivo histórico

- [v0.3.0](versions/0.3.0/): diseño aceptado, referencia técnica de combate, registro histórico y QA.
- [v0.4.0](versions/0.4.0/): diseño, aprendizajes, QA y resultado de la entrega.

Estas carpetas conservan su evidencia histórica. Las versiones nuevas se planifican y detallan en Issues; solo se añadirá una carpeta de archivo si una entrega requiere conservar evidencia extensa fuera de sus Issues/PRs.

## Documentación común y reutilizable

Mantener una sola referencia en `docs/project/` para cada convención o comportamiento vigente compartido. Cuando cambie una mecánica, actualizar su explicación común; las Issues conservan el alcance, las decisiones de trabajo y su discusión, y el changelog enlaza el resultado publicado.

## Documentos que permanecen junto a su contexto

- `README.md` permanece en la raíz como entrada del proyecto.
- `AGENTS.md` permanece en la raíz para que Codex y otros agentes carguen sus instrucciones al entrar al repositorio.
- Las plantillas de Issues/PR permanecen en `.github/`.
- Los README y avisos de licencia de Blender, arte y referencias Sith permanecen junto a sus herramientas o recursos para conservar procedencia y contexto local.
