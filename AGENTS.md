# Shadows of Kharuun: contexto del proyecto

Proyecto Godot para un jugador, centrado en historia. Comunicar en español.

- Antes de planificar o cambiar el juego, consultar `DISENO_DEMO.md` y `PENDIENTES.md`. Contienen las decisiones actuales, las dudas y el trabajo pendiente. `ORGANIZACION.md` define la rutina y el punto de reanudación; `CHANGELOG.md` identifica entregas reales.
- `COMBATE.md` y `RESULTADO.md` describen la primera entrega verificada. Sus controles y reglas no son la especificación de la segunda vuelta. `README.md` describe cómo ejecutar la versión existente.
- Registrar nuevas respuestas del usuario en `DISENO_DEMO.md`; actualizar tareas y criterios en `PENDIENTES.md`. Distinguir confirmado, propuesta, pendiente e implementado/verificado. Las instrucciones nuevas del usuario prevalecen sobre estos documentos.
- En una ronda de estudio, revisión o preguntas, modificar solo documentación; no interpretar respuestas de diseño como una petición de implementar. Cuando el usuario pida implementar, proceder dentro del alcance autorizado sin pedir una aprobación redundante.
- Si aparece una duda de comportamiento importante que los acuerdos no resuelven, plantear opciones clicables mediante la herramienta de preguntas disponible y continuar el trabajo independiente. No reabrir decisiones confirmadas. Resolver ajustes técnicos rutinarios y valores iniciales de equilibrio con criterio propio, dejando constancia de que son provisionales.
- Para una entrega jugable, comprobar los flujos afectados, órdenes con distintos destinatarios, recursos, pausa, colisiones y final/reinicio; usar las herramientas locales de `tools/` descritas en `README.md`. No marcar una tarea como verificada sin evidencia.
- Al empezar, comprobar rama y cambios locales y escoger una tarea concreta. Al cerrar, actualizar estado, decisiones, pruebas y siguiente paso. Una duda bloquea solo su parte dependiente; no bloquear trabajo independiente.
- Versionar entregas verificadas con etiquetas Git locales `vX.Y.Z` y changelog. Los cambios solo de documentación no cambian la versión jugable. No mover etiquetas ni presentar funciones planificadas como entregadas.
- Si Engram está conectado, usarlo para recuperar y guardar decisiones/hallazgos/resúmenes con referencias al repositorio. Verificar recuerdos contra el diseño vigente; no crear otra especificación ni importar recuerdos ajenos. Si no está disponible, continuar con los documentos locales.
- No añadir multijugador ni ampliar el universo, mapa o sistemas fuera de la iteración acordada.
