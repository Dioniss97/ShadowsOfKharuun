# Gentle AI — adopción en Shadows of Kharuun

**Estado:** integración documental preparada; activación local en Windows **pendiente de comprobar**. Alcance aprobado: adoptar Gentle AI/ODD para la asistencia al desarrollo; no autoriza funcionalidades nuevas del juego. Incidencia de seguimiento: [#30](https://github.com/Dioniss97/ShadowsOfKharuun/issues/30).

## 1. Qué hace cada sistema (sin duplicar fuentes de verdad)

- **Gentle AI**: instala/actualiza instrucciones y skills para Codex y, cuando se seleccione explícitamente, otros agentes. No instala Codex ni Blender/Godot.
- **ODD**: procedimiento de autorización → exploración → implementación → comprobaciones, para trabajo pequeño o sustancial. No se invoca como comando de cada tarea; opera a través de las instrucciones del agente instalado.
- **GitHub Issues**: **única fuente de estado operativo**, milestone, dependencias y criterios de aceptación aprobados.
- **Diseño Markdown**: fuente de verdad de decisiones de gameplay, narrativa, técnica y arte; `DISENO_0_4_0.md` es una entrega histórica, no el alcance de la futura versión.
- **`odd/tasks/<feature>.md`**: artefacto de **ejecución temporal** cuando ODD lo necesita para trabajo sustancial: specs, unidades de trabajo, enlaces y evidencia. NO lleva una lista paralela de estados de Issues, no sustituye el documento de diseño y referencia la issue autorizada. En tareas pequeñas no crearlo por sistema.
- **Engram**: memoria auxiliar local por proyecto, nunca autoridad de requisitos. Mantener `project=shadowsofkharuun`, `scope=project`. Conservar `.engram/config.json` y el tratamiento local/privado del resto de su carpeta. No ejecutar `engram sync` hacia Git sin aprobar por separado qué memorias se publicarían.
- **RDD**: revisiones independientes opcionales; no sustituyen pruebas Godot/Blender, PR ni aceptación visual humana.

## 2. Versión y requisitos comprobados

Documentación contrastada contra **Gentle AI v4.2.0** (15-10-2026):
- [Release](https://github.com/Gentleman-Programming/gentle-ai/releases/tag/v4.2.0)
- [Instalación](https://github.com/Gentleman-Programming/gentle-ai/blob/v4.2.0/docs/quickstart.md)
- [Uso/CLI/ODD](https://github.com/Gentleman-Programming/gentle-ai/blob/v4.2.0/docs/usage.md)
- [Uso previsto](https://github.com/Gentleman-Programming/gentle-ai/blob/v4.2.0/docs/intended-usage.md)
- [Agentes](https://github.com/Gentleman-Programming/gentle-ai/blob/v4.2.0/docs/agents.md)

Windows usa **Go 1.25.10 o posterior** para instalar Gentle AI (no descargar ejecutables sin firma de una fuente informal). Codex debe estar instalado por separado. No afirmar que ambos están presentes en el PC a partir de un repositorio GitHub.

Desde PowerShell, en el equipo Windows:

```powershell
go version
codex --version
git status --short
git branch --show-current
```

Si falta Go, instalar una versión oficial compatible y abrir una nueva terminal. Si falta Codex, seguir su procedimiento oficial de instalación y autenticación. No tocar secretos, PAT, SSH, datos de otros proyectos o configuraciones globales sin inspección.

## 3. Instalar la CLI y previsualizar el alcance

La ruta reproducible fijada a la versión revisada es:

```powershell
go install github.com/gentleman-programming/gentle-ai/v4/cmd/gentle-ai@v4.2.0
gentle-ai version
```

Si la terminal no reconoce `gentle-ai`, revisar `$(go env GOPATH)\bin` y añadir esa carpeta al PATH del usuario, o invocar el ejecutable por su ruta; no modificar el PATH del sistema a ciegas.

En la **raíz del repositorio**:

```powershell
gentle-ai install --agent codex --scope workspace --component engram,skills,context7 --dry-run
gentle-ai doctor
```

Revisar el plan completo antes de aplicar (incluidos cambios de MCP, binarios auxiliares y archivos globales). La selección **custom** de componentes evita persona, tema y GGA no solicitados. Context7 aporta documentación actualizada; si no se desea otro MCP, quitar `context7`. Engram ya existe: verificar la instalación y sus rutas antes de permitir migraciones o sobrescrituras. `--scope workspace` **no significa cero escrituras globales**: algunas integraciones son globales por definición. No iniciar instalación real hasta inspeccionar el dry-run.

## 4. Bloqueo conocido de Codex workspace

A 16-10-2026 permanece abierta [Gentle AI #1841](https://github.com/Gentleman-Programming/gentle-ai/issues/1841). El adaptador de Codex ubica su `SystemPromptFile` en `~/.codex/AGENTS.md`, lo que en alcance workspace puede terminar como **`.codex/AGENTS.md` del repositorio**, ubicación que Codex no carga como instrucciones raíz de proyecto.

**No instalar en global como parche automático**: alteraría el comportamiento de Codex en otros repositorios. El repositorio ya tiene un `AGENTS.md` raíz oficial; jamás sobreescribirlo con una plantilla generada.

Procedimiento seguro:
1. Inspeccionar `gentle-ai install ... --dry-run` en v4.2.0.
2. Si se confirma que la guía ODD solo aterriza en `.codex/AGENTS.md`, documentar el problema y resolver la activación a través de una referencia **explícita y versionada en el AGENTS.md raíz**, únicamente después de inspeccionar el contenido generado y validar que Codex lo consulta. No copiar ciegamente un prompt que podría cambiar con una actualización.
3. Si la versión instalada corrige el defecto, usar la ruta oficial y retirar cualquier puente innecesario.
4. Probar en una **nueva sesión Codex** que interpreta instrucciones de ODD, cita fuente del diseño y **no** escribe código ante una petición de investigación. La mera presencia de ficheros no es verificación funcional.

La adopción de política ODD en el `AGENTS.md` raíz ya se expresa en este PR y no depende del bug de ubicación para ser entendida por Codex.

## 5. Activar y verificar (tras aceptar el dry-run)

```powershell
gentle-ai install --agent codex --scope workspace --component engram,skills,context7
gentle-ai doctor
gentle-ai sync --agent codex --scope workspace --dry-run
gentle-ai review mode status
```

**RDD**: antes de iniciar la primera implementación, decidir su modo. Para una prueba de bajo coste, desactivarlo *solo en este clon* tras examinar su estado:

```powershell
gentle-ai review mode disable --scope clone --cwd .
gentle-ai review mode status
```

Es opcional: si se desea revisar con RDD desde el comienzo, conservarlo encendido y aceptar coste/revisiones. Su estado no queda aprobado desde este documento; se verifica en el equipo local.

**Prueba de humo**: abrir Codex desde este repositorio y solicitar solo «Analiza el estado de v0.4.0 y resume documentación, tests y pendientes. No modifiques archivos». El agente debe identificar v0.4.0 estable, `AGENTS.md` y GitHub Issues como fuentes; no crear `odd/tasks`, issue ni commit. Registrar resultado y archivos realmente instalados en #30.

Después, elegir **una tarea pequeña y autorizada** en una rama distinta de `main`, comprobar tests relevantes, PR y comportamiento de memoria. No iniciar automáticamente v0.5.0 ni modificar escenas como parte del setup.

## 6. Uso cotidiano y criterios de calidad

Describir la tarea a Codex en lenguaje natural: issue autorizada, resultado observable, restricciones y referencia al diseño. ODD explora y escoge ruta mínima. Solo crea `odd/tasks` cuando la tarea sustancial no pueda retomarse con la petición y el diff; no mantener dos backlogs.

Para cambios de gameplay: pruebas del sistema relevante y regresiones. Para arte Blender → Godot: fuente reproducible, GLB, material/exportación, prueba **dentro de Godot**, rendimiento y capturas comparables; el último visto bueno estético corresponde al usuario. Un render de Blender no certifica el resultado final.

Para tarea sustancial, `odd/tasks` puede versionarse en su rama de trabajo como especificación/evidencia del cambio; enlazarla a la issue y al PR, y evitar copiar estados. Si se convierte en deuda documental tras la entrega, archivarla o compactarla por decisión explícita. El criterio de ODD de aproximadamente 400 líneas por unidad es orientativo, no excusa para partir artificiosamente un GLB ni omitir pruebas.

## 7. Actualizar / recuperar

```powershell
gentle-ai version
gentle-ai doctor
gentle-ai sync --agent codex --scope workspace --dry-run
```

Para actualizar la CLI cuando se apruebe otra versión, usar `gentle-ai upgrade` (requiere Go en Windows) y revisar el `sync --dry-run` antes de ejecutar `gentle-ai sync --agent codex --scope workspace`. La versión nueva puede cambiar las rutas: revisar de nuevo #1841, `AGENTS.md`, `.codex`, `.engram` y los cambios de `git status`.

**Separación de responsabilidades:** este PR solo prepara GitHub y documentación. El código de Gentle AI/Go, el estado de su CLI, el MCP Engram y la configuración efectiva de Codex en el ordenador de desarrollo **no se pueden instalar ni validar desde esta conexión GitHub**.
