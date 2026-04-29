# Outlier Plan M System — Indicadores TradingView

> Indicadores TradingView que implementan el pipeline de entrada del Plan M de Christopher Uhl: validación de mercado top-down, Trend Template individual de 11 condiciones, y cálculo de posición basado en ATR.

📖 [English version](./README.md)

---

## Por qué Plan M y no trend following genérico

El Plan M es el plan específico más rentable del método Outlier, definido con criterios concretos y respaldados por backtesting:

- **Win rate del 56.9%** sobre más de 7.000 trades
- **Ganancia media por trade: +2.25%** en acciones → ~14% con opciones de delta 80
- **Media de días en posición: 17 días** (swing, no intraday)
- **Solo activo cuando:** el SPY está en tendencia alcista, el sector objetivo tiene más greed que el mercado, y la acción cumple el Trend Template

Los tres indicadores de este repositorio implementan exactamente el checklist de entrada del Plan M, en secuencia estricta. No es trend following genérico — es el pipeline de validación específico del Plan M.

---

## Los tres indicadores

| Indicador | Archivo | Función en el pipeline |
|-----------|---------|----------------------|
| Market Dashboard | `ovtlier_market_dashboard.pine` | Paso 1 — semáforo top-down: SPY + 11 sectores |
| Trend Template | `ovtlier_trend_template.pine` | Pasos 2–4 — checklist de 11 condiciones sobre la acción |
| Position Sizer | `outlier_position_sizer.pine` | Paso 5 — cálculo del tamaño de posición basado en ATR |

Úsalos siempre en secuencia. Saltarse cualquier paso invalida la operación dentro del método Outlier.

---

## Indicador 1 — Market Dashboard v5.1

Panel de control del régimen de mercado que determina en tiempo real si las condiciones son favorables para el Plan M. Evalúa tres niveles simultáneamente:

1. **SPY (mercado global)** — ¿está el mercado en tendencia alcista?
2. **Amplitud de mercado** — ¿es la tendencia amplia y estructuralmente sana?
3. **11 ETFs sectoriales** — ¿cuántos sectores lideran al mercado?

### El semáforo de tres estados

| Estado | Color | Significado |
|--------|-------|-------------|
| ✔ OPERAR HOY — Condiciones OK | 🟢 Verde | SPY alcista + amplitud OK + mínimo de sectores alcistas cumplido |
| ◎ PRECAUCIÓN — Condiciones parciales | 🟡 Amarillo | SPY alcista, pero amplitud o sectores insuficientes |
| ✘ NO OPERAR — Mercado bajista | 🔴 Rojo | SPY no cumple el Trend Template mínimo |

El fondo del gráfico refleja el mismo estado con 93% de transparencia, visible directamente sobre las velas.

### Análisis del SPY — cuatro componentes

**Tendencia (Trend Template Outlier):** `EMA10 > EMA20` y `precio > EMA50`. Condición binaria absoluta — sin ella, señal verde imposible.

**Momentum (RSI):** RSI(14) del SPY contra umbral configurable (por defecto 55). Confirma que el impulso alcista es genuino.

**Volumen:** Volumen actual del SPY vs. su SMA(20). Por encima de la media indica participación institucional; por debajo se señala en amarillo sin bloquear la señal.

**Amplitud de mercado:** Proxy dual — `RSI(14) > 50` Y `precio > EMA200`. Confirma que la tendencia tiene base estadística y estructural sólida.

### Análisis sectorial — dos dimensiones por sector

**Tendencia sectorial:** Misma lógica de EMAs que el SPY aplicada a cada ETF — `EMA10 > EMA20` y `precio > EMA50`.

**Fuerza relativa vs. SPY (RS 20 días):** Rentabilidad del sector en 20 días menos la del SPY en el mismo período. El método Outlier exige RS positiva antes de buscar acciones en ese sector.

| Estado del sector | Condición |
|-------------------|-----------|
| ✔ OPERAR | Tendencia alcista + RS positiva vs. SPY |
| ◎ ESPERAR | Tendencia alcista pero RS negativa |
| ✘ BAJISTA | No cumple el Trend Template sectorial |

### Los 11 sectores monitorizados

| ETF | Sector | Por defecto |
|-----|--------|-------------|
| XLK | Tecnología | ✔ Activo |
| IGV | Software | ✔ Activo |
| XLF | Financiero | ✔ Activo |
| XLI | Industrial | ✔ Activo |
| XLY | Consumo Discrecional | ✔ Activo |
| XLC | Comunicaciones | ✔ Activo |
| XLV | Sanidad | ✘ Excluido |
| XLE | Energía | ✘ Excluido |
| DBA | Agricultura | ✘ Excluido |
| DBC | Commodities | ✘ Excluido |
| GLD | Metales Preciosos | ✘ Excluido |

Los sectores excluidos siguen apareciendo en la tabla con datos en tiempo real pero no cuentan para el semáforo.

### Alertas

Tres `alertcondition` que se disparan en **transiciones** de régimen únicamente (no en cada vela): Mercado Verde, Mercado Amarillo, Mercado Rojo.

---

## Indicador 2 — Ovtlier Trend Template v6

Checklist de validación individual de acciones que implementa las **11 condiciones del Trend Template Outlier**, derivado del sistema Minervini y adaptado con los principios de Uhl. Se aplica sobre el gráfico diario de la acción **después** de que el Market Dashboard muestre verde.

La tabla está dividida en dos bloques claramente separados:

- **C1–C8:** el Trend Template clásico — estructura de medias móviles y posición respecto al rango anual.
- **C9–C11:** las verificaciones adicionales del Paso 4, ahora integradas directamente en la tabla.

### C1–C8 — Trend Template clásico

| Código | Condición | Pine Script | Significado |
|--------|-----------|-------------|-------------|
| C1 | Precio > SMA 150 | `close > sma150` | Tendencia de medio plazo alcista |
| C2 | Precio > SMA 200 | `close > sma200` | Tendencia de largo plazo alcista |
| C3 | SMA 150 > SMA 200 | `sma150 > sma200` | Estructura de medias ordenada correctamente |
| C4 | SMA 200 con pendiente positiva | `sma200 > sma200[21]` | La tendencia larga acelera, no está plana |
| C5 | SMA 50 > SMA 150 y SMA 200 | `sma50 > sma150 and sma50 > sma200` | El corto plazo lidera al medio y largo |
| C6 | Precio > SMA 50 | `close > sma50` | Precio sobre la tendencia de corto plazo |
| C7 | Precio ≥ +25% sobre mínimo 52s | `close >= low52w * 1.25` | La acción no está rota ni en recuperación |
| C8 | Precio dentro del 25% del máximo 52s | `close >= high52w * 0.75` | En zona de fuerza real |

**Por qué SMAs y no EMAs:** El Trend Template usa medias simples (50, 150, 200) siguiendo el sistema Minervini-Uhl. Las SMAs son más lentas y menos reactivas al ruido — cuando una condición se cumple con SMAs, la tendencia está verdaderamente establecida.

### C9–C11 — Verificaciones adicionales del Paso 4

**C9 — Sobreextensión (completamente automática)**
Calcula la distancia del precio a la SMA50 en múltiplos de ATR. FAIL si la acción está a más de 2.5×ATR de su SMA50. El valor exacto aparece dinámicamente: `C9 · Overext. 1.18 ATR (max 2.5)`.

**C10 — Zona de resistencia (semi-automática, proxy conservador)**
Escanea las últimas 60 barras en busca de máximos de vela dentro de la banda 1×ATR–2×ATR por encima del precio actual. Una banda naranja se plottea visualmente en el gráfico. Un FAIL significa "revisar manualmente", no un bloqueo absoluto.

**C11 — Ventana de earnings (input manual del usuario)**
El usuario introduce los días hasta el próximo earnings en los ajustes del indicador. PASS si más de 21 días. El valor por defecto es 99 (siempre PASS al cargar) — actualizar antes de evaluar cada trade.

### Veredicto

| Veredicto | Condición | Acción |
|-----------|-----------|--------|
| 🟢 VALID BUY SETUP | 8/8 en C1–C8 | Setup perfecto — verificar C9–C11 y proceder |
| 🟡 WATCH (X/8) | 6–7/8 | Setup en desarrollo — vigilar |
| 🔴 NOT READY (X/8) | < 6/8 | No cumple — ignorar |

El veredicto se basa exclusivamente en C1–C8. C9–C11 son confirmatorias.

---

## Indicador 3 — Outlier Position Sizer v4

Calculadora de tamaño de posición que implementa la **fórmula ATR de Christopher Uhl**, derivada del modelo de gestión de riesgo de Larry Height. Cárgala sobre el gráfico de la acción **después** de que el Trend Template muestre VALID BUY SETUP.

### La fórmula

```
// Paso 1 — cuánto dinero podemos perder
Riesgo en dólares  = Balance × (Riesgo% / 100)

// Paso 2 — distancia del stop basada en la volatilidad real
Distancia del stop = ATR(14) × Multiplicador (por defecto 2.0)
Precio del stop    = Precio de entrada − Distancia del stop

// Paso 3 — cuántas acciones comprar
Acciones           = floor(Riesgo en dólares / Distancia del stop)

// Solo para opciones
Contratos          = floor(Acciones / 100 / Delta)
```

**Por qué ATR × 2 para el stop:** El ATR mide el movimiento promedio real de la acción en los últimos 14 períodos. Un stop a 2×ATR queda fuera del ruido estadístico normal — un movimiento de esa magnitud probablemente indica que la tesis del trade es incorrecta.

### Salidas de la tabla

| Campo | Qué muestra | Color |
|-------|-------------|-------|
| 💰 Riesgo ($) | Dólares máximos a arriesgar | Blanco |
| 📊 ATR(14) | Valor actual del ATR | Blanco |
| 🛑 Stop Loss | Precio exacto del stop, plotteado en el gráfico | Rojo vivo |
| 📦 Acciones / 📑 Contratos | Unidades a comprar, redondeadas a la baja | Teal brillante |
| 💼 Capital usado | Capital comprometido y % del balance | Teal si <30%, rojo si >30% |
| Estado | Diagnóstico automático de parámetros | Fondo verde (OK) o rojo (alerta) |

### Escalado de riesgo por experiencia (Uhl)

| Experiencia | Riesgo por operación |
|-------------|---------------------|
| Año 1 | **1%** |
| Año 2 | **2%** |
| Año 3+ | **4–6%** |
| Uhl (16 años) | **6%** |

Nunca subir el nivel de riesgo de golpe. Incrementar gradualmente después de consolidar el nivel anterior.

---

## Flujo de decisión completo

```
Semáforo VERDE (Market Dashboard)
    └── SPY: EMA10 > EMA20 y precio > EMA50          ✔
    └── Amplitud: RSI > 50 y precio > EMA200          ✔
    └── Momentum: RSI > 55                            ✔
    └── Mínimo 3 sectores con ✔ OPERAR               ✔
         │
         ▼
Sector con RS positiva vs. SPY → ✔ OPERAR
         │
         ▼
Trend Template v6 — Bloque C1–C8
    └── C1–C6: estructura de SMAs correcta           ✔
    └── C7: +25% sobre mínimo de 52 semanas          ✔
    └── C8: dentro del 25% del máximo de 52 semanas  ✔
    Veredicto: 🟢 VALID BUY SETUP (8/8)
         │
         ▼
Trend Template v6 — Bloque C9–C11
    └── C9 (auto):   sobreextensión < 2.5 ATR        ✔
    └── C10 (semi):  sin resistencias en zona 2×ATR  ✔
    └── C11 (manual): earnings a más de 21 días      ✔
         │
         ▼
Position Sizer v4
    └── Riesgo ($) = Balance × Riesgo%
    └── Stop = Precio − (ATR × 2)
    └── Acciones = floor(Riesgo$ / Distancia stop)
    └── Estado: ✓ Parámetros OK (fondo verde)
         │
         ▼
ENTRADA VÁLIDA ✔ — definir todos los niveles antes de ejecutar
```

---

## Cómo empezar

1. Abre TradingView y ve al editor de Pine Script.
2. Copia el contenido del archivo `.pine` deseado de la carpeta `indicators/`.
3. Pégalo en el editor y haz clic en **Añadir al gráfico**.
4. Aplica el **Market Dashboard** sobre un gráfico de SPY para máxima precisión.
5. Aplica el **Trend Template** y el **Position Sizer** sobre el gráfico diario de la acción individual.

---

## Versionado

- **Versiones mayores** (`v1`, `v2`…) introducen funcionalidades nuevas o cambios estructurales significativos.
- **Versiones menores** (`v1.1`, `v5.1`…) son refinamientos o correcciones dentro del mismo conjunto de funcionalidades.

El historial completo de versiones está en [CHANGELOG.md](./CHANGELOG.md).

---

## Licencia

[Mozilla Public License 2.0](./LICENSE) · © Outlier Plan M System contributors.  
Basado en la metodología Outlier University de Christopher Uhl. Para uso educativo.
