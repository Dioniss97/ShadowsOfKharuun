# Historial de entregas

Las versiones identifican entregas jugables verificadas, mediante etiquetas Git locales. La numeración de las dos entregas existentes se asigna el 12 de octubre de 2026; las etiquetas apuntan a los commits originales y no reescriben su historial.

Última entrega estable: **v0.2.0**. Versión del árbol actual: **demo 0.3 en desarrollo**, sin etiqueta final de entrega. Política y rutina en [ORGANIZACION.md](ORGANIZACION.md).

El árbol de `feature/temple-tactical-demo` contiene ahora una build jugable de desarrollo de 0.3.0. La última entrega estable permanece en `v0.2.0`; Q01 y la aceptación humana impiden presentar esta build como entrega final.

## Sin publicar

### Demo 0.3 en desarrollo

- Correcciones B1/B2 de la prueba humana: órbita persistente en reposo/pausa y retorno solo al desplazarse; W/S conserva frente, A/D giro continuo y W+A/D arco/círculo. Selectores compactos sobre el enemigo seleccionado, ocultos fuera de combate y tras F, con seguimiento de actor/cámara y sin cubrir su cara. Issues #15/#16 en el mismo PR borrador #14.

- Misión del templo unificada con combate táctico, cola con destinatarios independientes y autoataque al último destinatario ofensivo ejecutado.
- HUD con tres selectores de categorías, cuatro órdenes pendientes, botiquines con contador, huecos futuros desactivados y retrato/recursos. Ayuda breve omitible y avisos contextuales.
- Básico y ráfaga con dos impactos; empuje, descarga, curación propia y tres botiquines. Consumo al ejecutar incluso con salud llena, sin recargas adicionales ni orden Defensa.
- Gesto con la mano izquierda, descarga desde la palma y curación verde; orientación y contacto del arma, cuerpos sólidos y comprobación de obstáculos.
- Pausa inicial una vez por encuentro, WASD tras F, persecución por la zona accesible y retorno suave de cámara sin movimiento circular involuntario.
- Diálogo ramificado del guardián después de los acólitos, recursos conservados y tiempo congelado mientras se lee. Combate y paso pacífico habilitan el mismo núcleo final del templo; reinicio completo tras derrota.
- Suite nueva de misión y bot con reglas normales; lanzadores DEMO y anteriores actualizados. Runners y motor de acción sustituidos conservados en el historial Git, retirados del árbol actual.
- Q01 aislada con protección temporal: orden sin energía conservada y mundo pausado, cancelable para continuar las pruebas. La regla definitiva de KOTOR sigue pendiente y no se crea `v0.3.0` final. Evidencia y limitaciones en RESULTADO.

### Documentación y organización

- Decisiones confirmadas de la segunda vuelta guardadas en `DISENO_DEMO.md`, con IDs D/Q y distinción entre acuerdos, propuestas y reglas pendientes.
- Tareas, dependencias y criterios de aceptación en `PENDIENTES.md`; instrucciones para retomar el proyecto en `AGENTS.md`.
- Conversación ramificada del guardián y objetivo final común documentados. La falta de energía queda pendiente de la comprobación del usuario en KOTOR.
- Convención de versiones, changelog y protocolo de inicio/cierre de trabajo; revisión de dependencias para que una duda local no bloquee toda la iteración.
- Repositorio privado `Dioniss97/ShadowsOfKharuun` preparado, con historial, ramas y etiquetas subidos mediante HTTPS; milestone `Demo 0.3.0` y 13 issues enlazados al backlog.
- Engram actualizado de 1.7.1 a 3.3.2 estable, con SHA256 verificado, respaldo de memoria/configuración y conservación de los registros anteriores. MCP y plugin oficial de Codex configurados, proyecto fijado y cinco resúmenes manuales de contexto guardados. Protocolo MCP probado; carga de herramientas/hooks en el agente requiere recargar Codex.
- Revisión previa a producción: lectura de Engram desde el MCP de esta sesión verificada y política explícita de consultas exclusivas a `shadowsofkharuun`, conservando memorias ajenas. Instalado jq 1.8.2 oficial, dependencia ausente de los hooks; escritura de agente pendiente de recarga/registro confirmado del cliente.
- Respuestas D21–D24 incorporadas al diseño y backlog: curación con salud llena consume ronda/recurso, persecución por toda la zona accesible, reinicio completo de misión y congelación de tiempo/recursos durante el diálogo. Q02/Q03/Q07 cerradas; Q01 sigue pendiente. Las 13 issues se revisan contra estos criterios sin iniciar implementación.

La documentación y organización anteriores se mantienen. Las funciones de la build de desarrollo están implementadas y comprobadas según RESULTADO, pero permanecen **sin entrega final** mientras Q01 y la aceptación humana estén pendientes.

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
