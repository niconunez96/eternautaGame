# Progresión de campaña — El Eternauta Metroidvania

> **Para Hermes:** este documento fija una progresión de diseño; no implica implementar código todavía.

**Objetivo:** construir una campaña de 8–12 horas con un Buenos Aires interconectado, movilidad realista, pocas habilidades, armas improvisadas progresivas y la red de resistencia como sistema de mapa.

**Principios innegociables**

- Juan Salvo es una persona corriente: sin doble salto, dash, wall-jump ni poderes.
- Las cuatro habilidades de exploración se mantienen contenidas: traje aislante, filtros/sellado, kit de reparación y decodificador alienígena.
- Las armas son pocas, improvisadas y progresivas; cada una debe combatir y abrir un tipo de obstáculo concreto.
- Las radios y repetidoras revelan el mapa. Ayudar a grupos de supervivientes altera rutas y refugios.
- Los Ellos no son un jefe final visible: la campaña termina con el accidente temporal que convierte a Juan en el Eternauta.

---

## Estructura no lineal y revisitas

La tabla describe un **orden de descubrimiento probable**, no una cadena de niveles cerrada. La campaña debe funcionar como una red de zonas conectadas:

- Desde cada zona, el jugador ve al menos uno o dos bloqueos que podrá resolver más tarde con una habilidad, un arma o un cambio en la red de supervivientes.
- Al obtener una mejora, se reabren rutas en **varias** zonas anteriores, no sólo en la siguiente zona principal.
- Las repetidoras, refugios, ascensores y puertas reparadas acortan los retornos; revisitar debe sentirse como descubrimiento, no como caminar por el mismo pasillo durante minutos.
- Algunas rutas pueden tener más de una solución: por ejemplo, reparar un ascensor, volar un derrumbe o recibir apoyo de un grupo de supervivientes.
- El objetivo narrativo marca una dirección, pero el jugador decide cuándo despejar accesos opcionales, rescatar gente, recuperar recursos o buscar atajos.

### Retornos principales propuestos

- **Traje aislante:** Chalet → primer exterior de Vicente López.
- **Radio/repetidora:** revela auxilios y rutas opcionales de Vicente López; habilita refugios que preparan el regreso desde General Paz.
- **Escopeta:** vuelve a Vicente López y General Paz para abrir barricadas, garajes y refugios encerrados.
- **Kit de reparación:** habilita ascensores y puentes de servicio en River, General Paz y el barrio inicial; crea conexiones verticales/atajos.
- **Filtros/sellado:** abre desagües y túneles contaminados en zonas ya conocidas, además de los subterráneos de Belgrano.
- **Bombas:** rompen muros agrietados y derrumbes en Vicente López, General Paz y el Centro; deben revelar salas opcionales, rescates y al menos una ruta alternativa principal.
- **Decodificador:** abre compuertas invasoras repartidas por el mapa, con lore, recursos y caminos cortos hacia el final.

### Regla de diseño

Cada habilidad o arma nueva debe abrir **al menos dos retornos útiles** fuera de la zona donde se obtiene: uno que acerque el objetivo principal y otro opcional que aporte supervivientes, recursos, información o un atajo.

---

## Vista de progresión

| Fase | Zona principal | Progreso obtenido | Bloqueo que abre | Hito enemigo |
|---|---|---|---|---|
| Prólogo | Chalet de Vicente López | Traje aislante | Salida a la nieve | Supervivencia, sin jefe |
| 1 | Barrios de Vicente López | Radio portátil + primera repetidora | Mapa local y refugios | Encuentro de cascarudo |
| 2 | General Paz y depósitos | Escopeta | Barricadas y cerraduras débiles | Cascarudo de asalto |
| 3 | River Plate | Kit de reparación | Ascensores, tableros, puentes y atajos | Nodo de teledirección |
| 4 | Barrancas de Belgrano / Subterráneos | Filtros y sellado | Gases, nieve densa y túneles contaminados | Gurbo |
| 5 | Centro ocupado / Congreso | Bombas improvisadas | Muros agrietados y derrumbes | Sistema central de control |
| 6 | Puesto de los Manos | Decodificador alienígena | Terminales y puertas invasoras | Mano: encuentro moral, no muerte obligatoria |
| Final | Nave invasora / espacio temporal | Ninguna habilidad nueva | Cierre de rutas y escape | Huida, accidente temporal |

---

## Prólogo — Chalet de Vicente López

**Función:** enseñar vulnerabilidad, encierro y cooperación antes de cualquier combate abierto.

- Juan, Elena, Martita, Favalli y amigos están encerrados después de la nevada.
- El jugador recorre el chalet, reúne materiales y fabrica el **traje aislante** con la ayuda del grupo.
- El movimiento enseña acciones físicas: mover un mueble, subir una escalera, arrastrarse por un pasillo bloqueado y cruzar una ventana/techo bajo.
- Arma inicial: palo o herramienta contundente. Debe sentirse insuficiente y servir sólo contra amenazas menores o para apartar obstáculos ligeros.
- El final del prólogo es abrir la salida y pisar por primera vez la ciudad nevada.

**Mapa:** no hay mapa revelado aún; sólo una libreta o croquis muy incompleto del chalet.

---

## Fase 1 — Barrios de Vicente López

**Función:** presentar la exploración urbana, la nieve y la red de resistencia.

- Calles residenciales, casas cerradas, garajes, comercios pequeños, techos bajos, pasajes y un primer refugio improvisado.
- El objetivo es alcanzar una radio barrial y emitir una señal. Esto entrega la **radio portátil** como sistema, no como habilidad de movimiento.
- Al reactivar la primera repetidora se revela el mapa del barrio: refugios, rutas transitables, puntos de auxilio y zonas bloqueadas.
- Primeras amenazas: supervivientes hostiles, peligros ambientales y cascarudos aislados.

**Hito enemigo:** un cascarudo grande bloquea una salida clave. No es una pelea de precisión: se puede usar entorno, puertas, alturas bajas y objetos para sobrevivir.

**Accesos futuros visibles:** barricadas débiles, puertas con energía cortada, un acceso a desagües con aire contaminado y un derrumbe grande.

---

## Fase 2 — General Paz y depósitos

**Función:** abrir el combate a distancia sin convertirlo en shooter.

- La General Paz funciona como frontera de guerra: vehículos abandonados, pasos inferiores, puestos militares y depósitos de suministros.
- Un grupo de supervivientes/militares recupera una armería mínima y entrega la **escopeta** tras una misión de auxilio.
- La escopeta tiene munición escasa y dos usos claros: combate de corto alcance y destrucción de **barricadas o cerraduras debilitadas**.
- Con ella se regresa a Vicente López para abrir rutas cortas, refugios encerrados y una conexión alternativa a la zona militar.

**Hito enemigo:** **cascarudo de asalto**, protegido por placas y acompañado por unidades menores. La escopeta sólo expone puntos débiles; el entorno completa la resolución.

**Salida narrativa:** la resistencia concentra a los sobrevivientes en River Plate.

---

## Fase 3 — River Plate, base de resistencia

**Función:** convertir una zona conocida en una dungeon vertical y revelar el control enemigo sobre humanos.

- Tribunas, túneles, depósitos, vestuarios, puestos de mando y estructuras parcialmente destruidas.
- Se obtiene el **kit de reparación** de Favalli o de un técnico rescatado.
- El kit reactiva ascensores, tableros, compuertas, iluminación de emergencia y puentes de servicio. Abre atajos tanto en River como en zonas anteriores.
- Aquí aparecen los primeros hombres-robot. Deben plantear que disparar siempre no es la solución más humana ni la más eficiente.

**Hito enemigo:** **nodo de teledirección**. Es un combate/objetivo de sabotaje: cortar energía, proteger a aliados y desactivar antenas en vez de sólo reducir una barra de vida.

**Consecuencia:** al liberar la señal, parte del mapa de la ciudad se actualiza; también se descubre que existen zonas con nieve/gases imposibles de cruzar con el traje actual.

---

## Fase 4 — Barrancas de Belgrano y subterráneos contaminados

**Función:** introducir exploración ambiental más opresiva y movilidad urbana vertical creíble.

- Barrancas, casonas, andamios, escaleras exteriores, túneles de servicio y tramos del subterráneo inundados o contaminados.
- El jugador consigue **filtros y sellado mejorado** de una célula médica/técnica conectada por radio.
- Esto permite entrar a zonas de nieve concentrada, gases y conductos contaminados, y reconectar repetidoras que estaban aisladas.
- El área debe depender de arrastrarse, trepar, mover cajas, cruzar tablones y usar escaleras; nunca de dobles saltos.

**Hito enemigo:** **gurbo**. No se lo derrota por daño puro: derriba paredes y modifica el escenario. La resolución consiste en usar su destrucción para abrir salida, hacerlo caer o alejarlo de civiles.

**Accesos futuros visibles:** paredes agrietadas de un sector céntrico, imposibles de abrir todavía.

---

## Fase 5 — Centro ocupado y Congreso

**Función:** mostrar una Buenos Aires tomada y llevar el arsenal a su último escalón humano.

- Avenidas devastadas, edificios públicos, estaciones, oficinas vacías y perímetros controlados.
- Tras ayudar a una célula de resistencia, Juan obtiene **bombas improvisadas**.
- Las bombas tienen capacidad limitada: combaten grupos, abren muros agrietados y despejan derrumbes. No deben utilizarse para resolver todos los enemigos.
- Con ellas se abren atajos centrales, se rescatan grupos encerrados y se llega al sector de mando invasor.

**Hito enemigo:** **sistema central de control**. Es un asalto escalonado contra infraestructura, hombres-robot y defensas de cascarudos. La victoria reduce el control local pero no gana la guerra.

**Consecuencia narrativa:** la aparente victoria provoca una respuesta mayor: nueva nevada, destrucción masiva o evacuación fallida. El jugador vuelve hacia el chalet buscando a Elena y Martita.

---

## Fase 6 — Puesto de los Manos

**Función:** revelar la cadena de dominación y preparar el final sin convertir a los Manos en villanos planos.

- Sector de alta tecnología cercano al núcleo de invasión, accesible gracias a rutas abiertas con bombas y filtros.
- Juan obtiene el **decodificador alienígena**, ya sea de un Mano capturado, aliado temporal o terminal intervenida.
- El decodificador abre compuertas, lee señales, identifica rutas de la nave y permite resolver mecanismos invasores.

**Hito enemigo:** **encuentro con un Mano**. Debe tener solución no letal o ambigua. La revelación importante es que los Manos controlan, pero también están aterrados y sometidos por los Ellos.

**Recompensa real:** acceso a la nave y conocimiento del mecanismo de escape, no un arma más poderosa.

---

## Final — Chalet, nave y fractura temporal

**Función:** cierre emocional; no una victoria militar total.

- Juan vuelve al chalet siguiendo señales sobre Elena y Martita. El lugar inicial está transformado/destruido, cerrando el círculo del mapa.
- Reúne a su familia y usa las rutas, radios y contactos creados durante el juego para llegar a una nave invasora.
- La sección final combina infiltración, escape y presión ambiental: no necesita un jefe final físico.
- Juan activa por accidente el mecanismo temporal de la nave. Elena y Martita quedan separadas; Juan atraviesa el continuo espacio-temporal.
- Última escena: Juan se convierte en el Eternauta; el ciclo con el guionista puede abrirse como epílogo.

---

## Reglas para evitar que la progresión se infle

1. No agregar habilidades de movimiento nuevas: el acceso se gana con equipo, armas y cambios del mundo.
2. No agregar armas si no abren un obstáculo o decisión táctica propia.
3. Cada zona debe tener al menos una repetidora y un grupo de supervivientes cuya ayuda cambie una ruta concreta.
4. Cada jefe debe resolver un problema narrativo o espacial, no ser sólo un enemigo con mucha vida.
5. El backtracking debe ser corto, con nuevas conexiones por radios, refugios, ascensores y puertas reparadas; evitar recorridos largos vacíos.

## Próximo artefacto recomendado

Convertir esta progresión en un diagrama de nodos del mapa: zonas, conexiones, bloqueos, repetidoras, refugios y retornos. Antes de implementar, conviene validar que cada habilidad/arma abre al menos dos rutas y que ninguna zona depende de movilidad sobrenatural.
