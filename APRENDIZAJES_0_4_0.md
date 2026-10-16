# Aprendizajes de 0.4.0 — primer asset Blender–Godot

Registro del 16-10-2026, basado en ocho iteraciones del Vigía y su integración. No es un backlog nuevo ni autoriza ampliar el alcance. Decisiones en [DISENO_0_4_0.md](DISENO_0_4_0.md); evidencia en [QA_0_4_0.md](QA_0_4_0.md).

## Dirección artística y revisión

- Una lista de materiales y objetos no define la calidad escultórica. La primera figura de bloques biselados cumplía una descripción literal, pero fue rechazada. Conviene acordar referencias de forma y presencia antes de detallar.
- Priorizar silueta/proporciones, continuidad, anatomía simplificada, pliegues y finalmente materiales. La verticalidad se consiguió reduciendo anchura, conservando altura y pedestal; los adornos no resolvían el problema.
- Revisar frontal, perfil, posterior, tres cuartos y detalles sobre la misma geometría. La luz neutra frontal y oblicua reveló una repisa dentro de la capucha y un pellizco de mano que el render artístico escondía.
- Resolver las causas estructurales: bordes compartidos y pendientes controladas en hombros/mangas; torso retraído dentro de capucha; canal de agarre cortado después de fusionar la mano superior. Superponer volúmenes para ocultar uniones producía otros defectos.
- La simplificación de dedos juntos funciona si palma, nudillos, muñeca y pulgar tienen una silueta convincente. No requiere diez dedos separados ni formas cúbicas. El pulgar que abraza el arma queda detrás desde el frente.
- Conservar lo que funciona y limitar cada pasada a los defectos identificados. La proporción aproximada 50 % humanoide / 50 % estatua ayudó a mantener una escultura monolítica sin exigir anatomía completa.

## Escritura, piedra y horneado

- Separar materiales Blender de su resultado exportado: un shader procedural correcto no demuestra el aspecto del GLB en Godot. Hornear y comprobar pronto dentro del motor.
- Las incisiones de 14 mm ocultaban su pigmento en Cycles. El grabado superficial de 2 mm y el frente plano de la estola permitieron leer el rojo mate. Aumentar saturación o emisión no corregía la oclusión geométrica.
- Las islas UV estrechas perdían pigmento de letras completas. Reservar dos proyecciones frontales continuas dentro del mismo atlas conservó el texto; el resto de piedra recibió menos superficie UV, sin ampliar texturas.
- Las motas triangulares tenían otra causa: caras UV muy finas sin muestras mantenían un relleno lineal escrito directamente en PNG sRGB. Se aislaron con material neutro y color base sin iluminación. La codificación sRGB correcta y el completado de texeles faltantes con color de superficie vecina compatible con pigmento corrigieron las manchas.
- Desactivar normales, sombras o MSAA sin aislar el canal no identificó esa causa. Registrar cada ensayo y conservar el diagnóstico evita repetir pruebas o atribuir el defecto al primer sospechoso.
- Una inscripción completa y ordenada no equivale a legibilidad desde el patio. El texto inglés y las filas se verifican por manifiesto; el usuario valora composición, desgaste y presencia a distancia.

## Pipeline e integración

- Mantener `.blend` editable con piezas nombradas; agrupar solo las copias de exportación por material. Tres materiales, nueve mapas incrustados y un GLB permiten compartir el recurso entre dos instancias.
- Fijar versión y comandos, guardar hashes de fuente/GLB y vincularlos a los informes y capturas. Los renders viejos no acreditan un binario nuevo. Archivar la base antes de regenerar evita perder comparaciones.
- Documentar que el generador reconstruye la fuente: los ajustes reproducibles van en el script; ejecutar después de una edición manual puede sustituirla.
- Separar visual y colisión. Sustituir la figura y conservar el collider del pedestal permite mejorar el arte sin cambiar el espacio de juego. La comparación de las 49 formas del nivel y las regresiones de misión aportan evidencia complementaria.
- Blender mira a +Y y Godot a +Z en este asset. Corregir la copia al exportar y comprobar la orientación en el nivel; no girar los módulos del templo para compensar a ciegas.
- El estudio y el templo tienen luces distintas: la piedra y las runas cambian de lectura. La validación final debe incluir ambas instancias dentro del nivel, con comparaciones de cámara/resolución equivalentes.
- Comprobar también una copia sin caché. El juego directo no importaba el GLB ni registraba las clases globales en un proyecto recién copiado. `PLAY.bat` prepara los recursos mediante `--headless --editor --import` antes de lanzar; no se distribuye `.godot` ni se presupone que la caché local del desarrollador existe en otro equipo.
- El GLB final tiene 169.352 triángulos y ocupa 18.214.180 bytes. Los mapas sin pérdida aumentan la memoria de texturas del escenario aproximadamente de 78 a 141 MiB en esta medición. Compartir el recurso evita duplicarlo por instancia; queda documentado el coste, sin confundir intervalos de presentación con tiempos exclusivos de GPU.

## Gestión y procedencia

- Diferenciar aprobar una dirección, autorizar su implementación y aceptar un resultado visible. Cada cambio de alcance quedó identificado en A04-04 a A04-12; una aprobación anterior no certificaba la siguiente iteración.
- GitHub Issues conserva el estado operativo; Markdown conserva decisiones y evidencia. No mantener otra lista de tareas sincronizada en `PENDIENTES.md`.
- Las imágenes del usuario son referencias y no autorización para redistribuir modelos/texturas. La tipografía Sith AF sí se incorporó con origen, licencia y atribución; la inscripción es una transliteración gráfica del inglés, no una traducción a la lengua Sith.
- La licencia de herramientas, scripts y arte exportado son asuntos distintos. Q04-06 se resolvió mediante aprobación informada de GPL-2.0-or-later exclusivamente para los dos scripts que usan `bpy`; no aplicar una licencia al juego por deducción.
- La versión visible del menú y la ventana se obtiene de `application/config/version`, evitando tres números independientes.

Estas observaciones describen este experimento. No convierten inventario, animaciones, remodelado general, generadores universales ni optimizaciones futuras en compromisos de otra versión.
