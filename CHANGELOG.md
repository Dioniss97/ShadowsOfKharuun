# Historial de entregas

Las versiones identifican entregas jugables verificadas, mediante etiquetas Git locales. La numeración de las dos entregas existentes se asigna el 12 de octubre de 2026; las etiquetas apuntan a los commits originales y no reescriben su historial.

Versión jugable actual: **0.2.0**. Próxima versión prevista: **0.3.0**, todavía en diseño y sin etiqueta de entrega. Política y rutina en [ORGANIZACION.md](ORGANIZACION.md).

## Sin publicar

### Documentación y organización

- Decisiones confirmadas de la segunda vuelta guardadas en `DISENO_DEMO.md`, con IDs D/Q y distinción entre acuerdos, propuestas y reglas pendientes.
- Tareas, dependencias y criterios de aceptación en `PENDIENTES.md`; instrucciones para retomar el proyecto en `AGENTS.md`.
- Conversación ramificada del guardián y objetivo final común documentados. La falta de energía queda pendiente de la comprobación del usuario en KOTOR.
- Convención de versiones, changelog y protocolo de inicio/cierre de trabajo; revisión de dependencias para que una duda local no bloquee toda la iteración.
- Repositorio privado `Dioniss97/ShadowsOfKharuun` preparado, con historial, ramas y etiquetas subidos mediante HTTPS; milestone `Demo 0.3.0` y 13 issues enlazados al backlog.
- Engram actualizado de 1.7.1 a 3.3.2 estable, con SHA256 verificado, respaldo de memoria/configuración y conservación de los registros anteriores. MCP y plugin oficial de Codex configurados, proyecto fijado y cinco resúmenes manuales de contexto guardados. Protocolo MCP probado; carga de herramientas/hooks en el agente requiere recargar Codex.
- Revisión previa a producción: lectura de Engram desde el MCP de esta sesión verificada y política explícita de consultas exclusivas a `shadowsofkharuun`, conservando memorias ajenas. Instalado jq 1.8.2 oficial, dependencia ausente de los hooks; escritura de agente pendiente de recarga/registro confirmado del cliente.
- Respuestas D21–D24 incorporadas al diseño y backlog: curación con salud llena consume ronda/recurso, persecución por toda la zona accesible, reinicio completo de misión y congelación de tiempo/recursos durante el diálogo. Q02/Q03/Q07 cerradas; Q01 sigue pendiente. Las 13 issues se revisan contra estos criterios sin iniciar implementación.

Estos cambios son de documentación. La misión unificada, ráfaga, botiquines, curación y rutas nuevas están **planificadas**, no implementadas; su alcance está en el diseño y no se cuenta como funcionalidad entregada.

## 0.2.0 — 2026-10-12

Etiqueta: `v0.2.0`. Commit de entrega: `f516f41`.

### Añadido

- Duelo táctico separado con selección de objetivo, rondas independientes, una acción actual y cuatro órdenes pendientes.
- Ataque básico automático, aproximación física, pausa táctica con preparación de órdenes y controles de cancelación/retirada.
- Empuje, descarga y acción Defensa; energía, recargas y cálculo de acierto/crítico.
- Pruebas del duelo y cuatro capturas reales; la misión original permanece disponible.

### Corregido

- Espada orientada hacia delante y animación con contacto diferido.
- Colisiones sólidas entre protagonista y enemigos.
- Ataques enemigos limitados por visibilidad; empuje cancela su impacto preparado.
- Selección al comenzar pausado, colocación inicial de cuerpos e interacción de botones y teclado.

### Verificación y límites

56 comprobaciones tácticas sin ventana y 60 con GPU; regresión original de 34/43 comprobaciones; partidas normales del bot completadas. Evidencia en [RESULTADO.md](RESULTADO.md).

El combate táctico solo se aplica al duelo. La misión del templo mantiene su combate de acción. Personajes procedurales y Godot portátil; sin modelos Blender ni exportación independiente del motor.

## 0.1.0 — 2026-10-12

Etiqueta: `v0.1.0`. Commit de entrega verificada: `138d459`; implementación inicial: `5262e15`.

### Añadido

- Asalto al templo: menú, exploración, diálogo con tres respuestas, tres acólitos, guardián, victoria y derrota.
- Movimiento, cámara, pausa, habilidades, HUD, colisiones y rampa del templo.
- Mundo, personajes y efectos procedurales; textos en español y TTS de Windows cuando hay voz disponible.
- Lanzador `PLAY.bat`, pruebas funcionales, capturas con GPU y bot de partida normal.

### Verificación histórica

La entrega registró 33 comprobaciones sin ventana y 42 con GPU, ocho capturas reales y una victoria del bot. Estos resultados pertenecen a esta versión; los informes locales de prueba se sobrescriben al ejecutar nuevas pruebas. El informe histórico está conservado en `RESULTADO.md` dentro del commit `138d459`.
