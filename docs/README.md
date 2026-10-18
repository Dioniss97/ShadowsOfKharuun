# Documentación

La documentación del proyecto vive aquí, agrupada por su propósito y por entrega. GitHub Issues conserva el estado operativo; estos documentos registran decisiones, guías y evidencia.

## Proyecto

- [Gestión del desarrollo](project/GESTION_DESARROLLO.md): fuentes de verdad, autorización, issues y rutina de trabajo.
- [Organización técnica](project/ORGANIZACION.md): convenciones del entorno y base estable.
- [Adopción de Gentle AI/ODD](project/GENTLE_AI.md): instalación, compatibilidad y recuperación del flujo de agentes.
- [Recursos y procedencia](project/ASSETS.md): inventario, créditos y licencias.
- [Historial de entregas](project/CHANGELOG.md): resumen de versiones publicadas.

## Versiones

Cada carpeta contiene solo los documentos que correspondan al alcance real de esa entrega. Una versión puede incluir diseño, gameplay, arte, verificación o una combinación de ellos.

- [v0.3.0](versions/0.3.0/): diseño aceptado, referencia técnica de combate, registro histórico y QA.
- [v0.4.0](versions/0.4.0/): diseño, aprendizajes, QA y resultado de la entrega.

Las propuestas futuras no se convierten aquí en backlog operativo; ese estado vive en GitHub Issues.

## Diseños reutilizables entre versiones

Cuando un diseño canónico se use en varias entregas —por ejemplo, un planeta, edificio o nave— se documentará una sola vez bajo docs/domains/ y las carpetas de versión enlazarán esa fuente. Se creará esa sección cuando haya un documento reutilizable que alojar.

## Documentos que permanecen junto a su contexto

- README.md permanece en la raíz como entrada del proyecto.
- AGENTS.md permanece en la raíz para que Codex y otros agentes carguen sus instrucciones al entrar al repositorio.
- Las plantillas de issues/PR permanecen en .github/.
- Los README y avisos de licencia de Blender, arte y referencias Sith permanecen junto a sus herramientas o recursos para conservar procedencia y contexto local.
