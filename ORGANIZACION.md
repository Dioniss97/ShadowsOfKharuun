# Organización técnica de Shadows of Kharuun

**Actualizado: 15 de octubre de 2026.** La política operativa vigente está en [GESTION_DESARROLLO.md](GESTION_DESARROLLO.md). Este archivo contiene convenciones del entorno y referencias de recuperación, no otro backlog de estados.

## Base y entregas

| Versión | Estado |
|---|---|
| `v0.1.0` | Primera misión verificada; commit `138d459`. |
| `v0.2.0` | Duelo táctico verificado; commit `f516f41`. |
| `v0.3.0` | **Estable**: misión táctica unificada, QA humana aprobada el 14-10-2026; PR [#14](https://github.com/Dioniss97/ShadowsOfKharuun/pull/14) integrada en `main`. |

El [milestone Demo 0.3.0](https://github.com/Dioniss97/ShadowsOfKharuun/milestone/1) está cerrado (21 issues cerradas, ninguna abierta). La documentación y evidencia de esta entrega están en [DISENO_DEMO.md](DISENO_DEMO.md), [COMBATE.md](COMBATE.md), [RESULTADO.md](RESULTADO.md), [QA_0_3_0.md](QA_0_3_0.md) y [CHANGELOG.md](CHANGELOG.md).

El formato de versiones del prototipo es `0.MINOR.PATCH`: incrementar MINOR para grupos importantes de funciones y PATCH para correcciones menores. Etiquetar únicamente entregas verificadas y aceptadas; no mover etiquetas antiguas. Documentación sola no altera la versión jugable.

La rama por defecto es `main`. Para trabajo autorizado, crear ramas descriptivas sin GitFlow obligatorio. Las ramas históricas `feature/tactical-duel`, `feature/temple-tactical-demo` y `master` pueden seguir existiendo: no borrar ni modificar por limpieza administrativa sin motivo.

## Fuentes de trabajo

- **Diseño:** cada versión nueva tiene su especificación en Markdown, con decisiones aprobadas, propuestas, dudas y sustituciones expresas. D01–D36 describen lo entregado en 0.3.0.
- **Backlog y estados:** GitHub Issues, etiquetas, milestone y relaciones nativas cuando aporten claridad. No actualizar una segunda tabla de progreso en `PENDIENTES.md`.
- **Código/evidencia:** Git/PRs, tests automatizados y pruebas de juego/QA; los resultados se documentan en el PR y en los informes de entrega cuando corresponda.
- **Ideas FUT:** sección histórica de `PENDIENTES.md`, propuestas sin versión ni autorización de implementación.
- **Agentes:** empezar leyendo [AGENTS.md](AGENTS.md) y [GESTION_DESARROLLO.md](GESTION_DESARROLLO.md). Las instrucciones nuevas del usuario tienen prioridad.

## Rutina mínima para Codex

1. Confirmar rama, `git status`, HEAD, tag estable y issues/PRs que afecten al objetivo. No alterar cambios locales ajenos.
2. Leer las decisiones relevantes del diseño activo y los criterios de aceptación de la issue. Una duda concreta bloquea solo la parte dependiente.
3. En exploración, limitarse a investigar/documentar; no iniciar implementaciones por defecto. En ejecución autorizada, actualizar código, pruebas y PR, y dejar evidencia verificable.
4. Actualizar **issue** cuando cambia el estado de producción; actualizar **documento de diseño** cuando se toma o cambia una decisión; no sincronizar textos repetidos.
5. Para entrega: aceptar el alcance, revisar regresiones, validar humanamente cuando se requiera, integrar PR, actualizar README/RESULTADO/CHANGELOG, etiquetar el commit final y cerrar issues/milestone. Registrar qué queda pendiente.

## Entorno y recursos

- Repositorio público por decisión del usuario: https://github.com/Dioniss97/ShadowsOfKharuun, Git remoto HTTPS; no cambiar credenciales ni configuración de SSH.
- Godot portátil en `tools/godot/`, excluido de Git; conservarlo o prepararlo por separado en otra máquina. Herramientas de pruebas en `tools/` explicadas en [README.md](README.md).
- Credenciales, binarios, bases de memoria, respaldos y directorios de usuario **no** se suben al repositorio.
- Blender es herramienta artística prevista; no inferir que los modelos o pipelines futuros ya estén implementados.

## Engram (auxiliar, no dependencia)

El proyecto se identifica por `.engram/config.json`, con `project_name = ShadowsOfKharuun`; en el MCP se normaliza como `shadowsofkharuun`. En las consultas de memoria usar `project = shadowsofkharuun`, `scope = project` y evitar búsquedas globales. Los recuerdos pueden quedar obsoletos; contrastar contra Git/Issues antes de actuar.

**Último diagnóstico documentado de Codex:** Engram 3.3.2 podía leerse vía MCP, pero las escrituras eran rechazadas por una identificación de sesión del host no confirmada, incluso tras preparar `jq`. No sabemos si persiste en sesiones posteriores: comprobarlo en Codex, sin asumir ni el éxito ni el fallo. Si no se resuelve, no bloquear el desarrollo ni saltarse la validación del hook mediante CLI/HTTP/SQL.

Los detalles históricos de instalación, hashes, respaldos, incidencias, decisiones antiguas y puntos de reanudación permanecen recuperables en el archivo de la entrega:
```powershell
git show v0.3.0:ORGANIZACION.md
```

No instalar Changesets, Gentle AI/ODD, un nuevo gestor de releases ni GitHub Projects por defecto. Reevaluar solamente si existe una necesidad concreta.
