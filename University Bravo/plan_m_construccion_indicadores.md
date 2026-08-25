# De las fuentes a los indicadores del Plan M
### Cómo se tradujo el método de Christopher Uhl en tres indicadores Pine Script v6

---

## El punto de partida: las fuentes

Las fuentes del proyecto son las transcripciones de los vídeos de Outlier University de Christopher Uhl. En esas transcripciones, Uhl explica su método de forma verbal y pedagógica — no en forma de código ni de reglas formales. El trabajo de construcción consistió en extraer la lógica operativa implícita en sus explicaciones y convertirla en condiciones programables en Pine Script v6.

---

## La estructura jerárquica que lo organiza todo

Lo primero que emergió de las fuentes fue que el método de Uhl no es un indicador único, sino un **proceso de filtrado en cascada con tres niveles obligatorios**:

```
Mercado (SPY) → Sector → Acción individual
```

Uhl repite consistentemente que nunca se busca una acción sin haber verificado primero el mercado, y nunca se mira el mercado sin haber identificado el sector con más flujo institucional. Esta jerarquía top-down es la que determinó que se necesitaban exactamente **tres indicadores separados**, uno por nivel, y que el orden de uso es estricto y no negociable:

1. **Market Dashboard** — ¿Permite el mercado operar hoy?
2. **Ovtlier Trend Template** — ¿Cumple esta acción los criterios de entrada?
3. **Outlier Position Sizer** — ¿Cuántas acciones o contratos compro?

Saltarse cualquier paso invalida la operación dentro del método Outlier.

---

## Indicador 1 — Market Dashboard

### Qué dice Uhl en las fuentes

> *"Solo opero cuando el SPY está en tendencia alcista, el Fear & Greed está bajo 70 y al menos unos cuantos sectores me están dando más greed que el mercado."*

De esta afirmación se extrajeron tres bloques de lógica independientes.

### Bloque SPY — Tendencia del mercado

La condición de tendencia alcista se tradujo al Trend Template simplificado de Uhl:

```
EMA10 > EMA20  →  tendencia de corto plazo alcista
Precio > EMA50 →  precio sobre tendencia de medio plazo
```

El RSI como confirmador de momentum y el volumen como validador de participación institucional vienen de la explicación de Uhl sobre lo que distingue una tendencia real de un simple rebote técnico. Sin volumen por encima de su media, la tendencia puede ser una trampa.

### Bloque de amplitud — El proxy del Fear & Greed

El Fear & Greed de Uhl **no es replicable directamente** en Pine Script porque utiliza su propio feed de datos propietario, no accesible desde TradingView. Se construyó un proxy dual que captura la misma idea estructural:

```
RSI(14) > 50       →  el mercado tiene momentum positivo
Precio > EMA200    →  el mercado está sobre su tendencia de largo plazo
```

Ambas condiciones deben cumplirse simultáneamente. Si el SPY está por debajo de su EMA200, el mercado no tiene base estructural suficiente para operar con el Plan M, independientemente de lo que diga el RSI.

### Bloque de sectores — El flujo institucional

Uhl habla de identificar qué sectores tienen "más greed que el mercado". Eso se tradujo como **fuerza relativa positiva vs. SPY calculada en 20 días**, que es el período que él usa habitualmente en sus análisis en vídeo.

La fórmula es:

```
RS = Rendimiento del sector (20d) − Rendimiento del SPY (20d)
RS > 0  →  el sector supera al mercado  →  OPERAR
RS < 0  →  el mercado supera al sector  →  ESPERAR
```

El semáforo de tres estados — verde, amarillo, rojo — viene del concepto de Uhl de que hay momentos para operar con plena exposición, momentos para reducir tamaño y momentos para no hacer absolutamente nada.

| Estado | Condición |
|--------|-----------|
| Verde — OPERAR | SPY alcista + amplitud OK + mínimo de sectores con RS positiva |
| Amarillo — PRECAUCIÓN | SPY alcista pero amplitud o sectores insuficientes |
| Rojo — NO OPERAR | SPY no cumple el Trend Template mínimo |

---

## Indicador 2 — Ovtlier Trend Template

### Qué dice Uhl en las fuentes

Esta es la parte donde la fuente es más explícita. Uhl adapta el **Trend Template de Mark Minervini** — ocho condiciones basadas en medias móviles simples y posición relativa al rango de 52 semanas — y lo combina con sus propias verificaciones adicionales que llama "Paso 4".

### Condiciones C1–C8 — El Trend Template de Minervini-Uhl

Las condiciones C1–C8 vienen directamente de Minervini, que Uhl cita y adapta. La traducción a Pine Script fue directa: cada condición es una comparación booleana entre el precio de cierre y una media móvil calculada con `ta.sma()`.

| Código | Condición | Pine Script | Significado operativo |
|--------|-----------|-------------|----------------------|
| C1 | Precio > SMA 150 | `close > sma150` | Tendencia de medio plazo alcista |
| C2 | Precio > SMA 200 | `close > sma200` | Tendencia de largo plazo alcista |
| C3 | SMA 150 > SMA 200 | `sma150 > sma200` | Estructura de medias ordenada |
| C4 | SMA 200 pendiente positiva | `sma200 > sma200[21]` | La tendencia larga acelera, no está plana |
| C5 | SMA 50 > SMA 150 y 200 | `sma50 > sma150 and sma50 > sma200` | El corto plazo lidera al largo |
| C6 | Precio > SMA 50 | `close > sma50` | Precio sobre tendencia de corto plazo |
| C7 | Precio ≥ +25% sobre mínimo 52s | `close >= low52w * 1.25` | La acción no está rota estructuralmente |
| C8 | Precio dentro del 25% del máximo | `close >= high52w * 0.75` | La acción está en zona de fuerza real |

El veredicto — VALID BUY SETUP / WATCH / NOT READY — se basa exclusivamente en estas ocho condiciones.

### Condiciones C9–C11 — El Paso 4 de Uhl

Estas tres condiciones vienen de lo que Uhl describe como verificaciones manuales que hace antes de ejecutar cualquier entrada. En versiones anteriores del indicador se hacían fuera del código; a partir de la v6 se integraron en la propia tabla.

**C9 — Sobreextensión (automática)**

Uhl advierte repetidamente de no comprar cuando el precio está demasiado lejos de su media de corto plazo. La condición se implementó como el ratio entre la distancia al SMA50 y el ATR actual:

```
Ratio = (Precio − SMA50) / ATR(14)
Límite máximo: 2.5×ATR
```

Si el ratio supera 2.5, la acción está sobreextendida y la entrada tiene demasiado riesgo de pullback inmediato.

**C10 — Resistencias en la zona inmediata (semi-automática)**

Uhl habla de los Order Blocks — zonas donde hay traders atrapados esperando salir al break-even — y de no entrar si hay resistencia relevante en la zona de 2×ATR por encima del precio actual. Se implementó como una búsqueda automática de máximos de vela en esa banda, con visualización de la zona en el gráfico para confirmación visual del usuario.

**C11 — Ventana de earnings (manual)**

Uhl es explícito: nunca entra con una presentación de resultados a menos de 21 días. Esta condición **no es automatable** con datos públicos de TradingView porque el calendario de earnings no está disponible como feed en Pine Script. Se implementó como un input manual que el usuario actualiza antes de cada operación potencial.

```pine
daysToEarnings = input.int(99, "Days to next Earnings")
c11 = daysToEarnings >= 21
```

El valor por defecto es 99 — fuera de riesgo — para que el indicador no bloquee operaciones por error si el usuario olvida actualizarlo.

---

## Indicador 3 — Outlier Position Sizer

### Qué dice Uhl en las fuentes

Este indicador viene de una única fórmula que Uhl atribuye a **Larry Hite** (primer gestor de hedge fund en superar los 1.000 millones de dólares) y que repite en prácticamente todos sus vídeos sobre gestión de riesgo:

```
Riesgo en dólares  = Balance × Riesgo%
Riesgo por acción  = ATR(14) × 2
Número de acciones = Riesgo$ / (ATR × 2)
```

### La extensión para opciones

La extensión para opciones — dividir entre 100 y entre el delta — la añade Uhl cuando explica sus calls de 80 delta como vehículo preferido del Plan M. La lógica es que una opción de delta 0.80 mueve $0.80 por cada $1 que sube la acción, y un contrato controla 100 acciones. La fórmula base es la misma, ajustada para que el riesgo en dólares refleje el movimiento real de la opción y no el del subyacente:

```
Contratos = floor( Riesgo$ / (ATR × 2) / 100 / Delta )
```

### La escala de riesgo recomendada

Uhl es muy específico sobre cómo escalar el porcentaje de riesgo con la experiencia. Esta tabla se incorporó directamente al indicador como guía visual:

| Experiencia | Riesgo por operación |
|-------------|---------------------|
| Año 1 — Principiante | 1% |
| Año 2 — Intermedio | 2% |
| Año 3+ — Avanzado | 4–6% |
| Uhl (16 años) | 6% |

---

## Resumen del proceso de traducción

El proceso de construcción siguió siempre el mismo flujo:

1. **Identificar** qué decía Uhl verbalmente en las transcripciones
2. **Encontrar** la condición matemática que captura esa idea
3. **Implementar** en Pine Script con los parámetros que Uhl menciona explícitamente o que son estándar en el análisis técnico
4. **Documentar** cualquier desviación respecto a la fuente original

Donde la condición no era replicable automáticamente — Fear & Greed, calendario de earnings — se construyó el mejor proxy disponible o se dejó como input manual, con documentación explícita de por qué y qué limitación implica.

---

*Documento generado a partir de las transcripciones de Outlier University de Christopher Uhl.*
*Referencia técnica: `outlier_system_reference_EN_v3.0.md` y `outlier_sistema_resumen_ES_v3.0.md`*
