# Plan M — Campaña de Diagnóstico (backtest/v1)

**Script:** `ovtlier_plan_m_backtest.pine` (backtest/v1)
**Timeframe:** 1H · **Sesión:** 9:30-16:00 ET · **Universo probado:** SPY, QQQ, MSFT
**Costes:** comisión 0,05% + slippage 1 tick · **Umbral de éxito:** PF > 1,2×
**Periodo de datos:** 2020-12 a 2026-08 (limitado por historial 1H disponible en TradingView)

---

## 1. Arquitectura

`strategy()` monolítico (Opción A del spec de diseño) — replica dentro de un único
script la lógica de dos indicadores en vivo:

- **Market Dashboard v5.2** → gate de régimen binario `marketGreen` (SPY: EMA10>EMA20
  + close>EMA50 + RSI>55, amplitud RSI>50 + close>EMA200, y ≥3 de 11 sectores alcistas)
- **Ovtlier Trend Template v7** → señal de entrada `fullApproval`

Sin dependencias de librerías ni de otros scripts. Position Sizer v5 replicado vía
`f_calcShares()` (riesgo % sobre balance fijo, no compuesto).

---

## 2. Bugs encontrados y corregidos durante la campaña

Por orden cronológico — todos verificados con datos reales antes de aplicar el fix.

### 2.1 — Lookback de 52 semanas mal convertido a 1H (crítico)
El código original de v7 usa `ta.highest(high, 252)`, válido en Daily (252 días de
trading ≈ 1 año). Copiado literalmente a 1H, 252 barras = ~6 semanas, no 52. Esto
concentraba todas las señales de SPY exclusivamente en abril 2020 (ventana dominada
por el rango extremo del crash/recuperación COVID) y las hacía desaparecer el resto
del histórico. **Fix:** input `yearLookbackInput` (default 1650 barras ≈ 252 días ×
6,5 barras/día en 1H).

### 2.2 — Sizing sin tope de capital disponible
`f_calcShares()` calculaba acciones solo en función del riesgo en $, sin comprobar
si cabían en el balance. En activos de precio alto (MSFT) podía pedir más capital
del disponible, y la orden nunca se llenaba (`strategy.position_size` se quedaba en
0 para siempre, generando falsos positivos de "señal repetida sin ejecutar").
**Fix:** `qtyToEnter = min(qtyByRisk, qtyByCapital)`, con `qtyByCapital` sobre
`strategy.equity` real (no balance fijo), evitando además los recortes por
"Margin call" detectados en SPY 2020-04-29.

### 2.3 — Límite de objetos `line` superado (visual, no de datos)
Las cajas SL/TP históricas usaban 2 `line` por trade. Con >400 trades por ticker,
se superaba el límite duro de Pine de 500 objetos `line`, y Pine borraba en silencio
los más antiguos. **Fix:** una sola `box` por trade (mitad de coste), con
`max_boxes_count = 500`.

### 2.4 — Tabla de diagnóstico invisible en Bar Replay
`barstate.islast` no sigue el cursor de Bar Replay (refleja la última barra del
dataset real, no la posición del replay). **Fix:** gate eliminado, la tabla se
actualiza en cada barra confirmada.

### 2.5 — Celda vacía en la tabla de diagnóstico
Fila "8/8 Minervini veces" sin su celda de valor pintada. Fix trivial, sin impacto
en los resultados (el conteo interno `cntFull8Minervini` siempre fue correcto).

---

## 3. Decisiones de diseño revisadas

### 3.1 — `fullApproval` no incluye C10
El código fuente de v7 define `fullApproval = condCount == 8` (solo C1-C8). C9, C10
y C11 viven en filas separadas de la tabla ("Step 4") como capa de juicio visual del
trader, no como gate automático. Se probó incluir C9+C10 en el gate: la señal
colapsó a 0-2 ocurrencias en ~2 años de 1H en los tres tickers. Motivo: C8 (precio
dentro del 25% del máximo 52 semanas) y C10 (sin máximo previo en 60 barras dentro
de 2×ATR) son casi mutuamente excluyentes por construcción — estar cerca de máximos
casi garantiza que algún máximo reciente esté cerca. **C10 queda excluido del gate
de forma permanente.**

### 3.2 — C11 (earnings) excluido — limitación de datos, no de diseño
Input manual en el indicador en vivo (`earningsDays`). Sin feed de calendario de
earnings histórico fiable en Pine v6, no es automatizable. La señal real en vivo es
más estricta que este backtest.

### 3.3 — C9 reincorporado al gate (ver resultados §4)

### 3.4 — `allowOvernightInput` — toggle, no cambio permanente
Día-trade puro (cierre forzado de sesión) es el default y coincide con el diseño
original del spec (evitar riesgo de gap). Se añadió como experimento aislado, no
como sustitución del comportamiento base.

---

## 4. Resultados por configuración

Todas las cifras: día-trade salvo que se indique "overnight". Costes y umbral
según cabecera. PF = Profit Factor aproximado (ganancia bruta / |pérdida bruta|).

### 4.1 — Baseline: `fullApproval = C1-C8` únicamente

| Ticker | Trades | Win Rate | PF | PyG total |
|---|---|---|---|---|
| SPY  | 466 | 37.6% | 0.47 | -35.8% |
| QQQ  | 471 | 43.5% | 0.63 | -32.5% |
| MSFT | 344 | 44.2% | 0.64 | -30.8% |

**Hallazgo:** TP (2R) casi nunca se alcanza (2-3% de los trades) porque el cierre
forzado de sesión corta la posición antes de que el precio recorra la distancia.
SL sí se alcanza con regularidad (15-19%). Asimetría desfavorable: pierdes completo
cuando falla, casi nunca ganas completo cuando acierta.

### 4.2 — `allowOvernightInput = true` (C1-C8, sin C9)

| Ticker | Trades | Win Rate | PF | PyG total |
|---|---|---|---|---|
| SPY  | 229 | 37.6% | 0.89 | -8.4% |
| QQQ  | 238 | 39.1% | 1.01 | +0.8% |
| MSFT | 197 | 36.0% | 0.90 | -11.7% |

**Hallazgo:** confirma que el cierre forzado de sesión era el cuello de botella
principal — TP pasa de 2-3% a 30-36% de aciertos. Coste real detectado: SL medio
empeora 15-33% por riesgo de gap (justo la razón original para day-trade puro).
Ninguno cruza el umbral de 1,2×.

### 4.3 — C9 reincorporado al gate (día-trade)

| Ticker | Trades | Win Rate | PF | PyG total |
|---|---|---|---|---|
| SPY  | 218 | 41.7% | 0.585 | -14.0% |
| QQQ  | 225 | 36.9% | 0.465 | -26.5% |
| MSFT | 181 | 48.6% | 0.833 | -7.5% |

**Hallazgo:** resultado mixto, asset-dependiente. Mejora SPY y MSFT, empeora QQQ
(y con solo 2 TP en QQQ, ese resultado tiene muy poca base). Patrón similar al
hallazgo de RVOL en la campaña de Plan A (mejora 4/5 tickers, un caso excepción).

### 4.4 — C9 + overnight combinados ✅

| Ticker | Trades | Win Rate | PF | PyG total |
|---|---|---|---|---|
| SPY  | 74 | 33.8% | **1.334** | **+12.7%** |
| QQQ  | 72 | 31.9% | **1.212** | **+10.1%** |
| MSFT | 56 | 33.9% | **1.404** | **+17.0%** |

**Primera configuración que supera el umbral de 1,2× en los tres tickers
simultáneamente.** Los dos hallazgos que mejoraban por separado se refuerzan al
combinarse en vez de solaparse.

**Auditoría de concentración (top-N trade como % de la ganancia bruta):**

| Ticker | Top 1 | Top 2 | Top 3 |
|---|---|---|---|
| SPY  | 6.5%  | 12.2% | 17.4% |
| QQQ  | 5.3%  | 10.5% | 15.5% |
| MSFT | 16.6% | 21.9% | 26.9% |

Ningún trade individual se acerca al umbral de descarte (>50%). **Pasa.**

**Distribución anual de trades:**

| Ticker | 2020 | 2021 | 2022 | 2023 | 2024 | 2025 | 2026 |
|---|---|---|---|---|---|---|---|
| SPY  | 3 | 17 | 2 | 6  | 27 | 14 | 5 |
| QQQ  | 3 | 18 | 0 | 13 | 17 | 16 | 5 |
| MSFT | 2 | 14 | 1 | 15 | 9  | 13 | 2 |

2022 aporta poco en los tres (coherente — año bajista para tecnología/índices, un
sistema de momentum alcista genera pocas señales ahí). Sin ventana anómala
dominando el resultado. **Pasa.**

---

## 5. Veredicto y salvedades

**La combinación `C9 en el gate + allowOvernightInput = true` es la única
configuración de esta campaña que cumple el umbral de éxito de forma consistente
y auditada.**

Salvedades que hay que sopesar antes de adoptarla como versión operativa:

1. **Ya no es day-trade puro.** El overnight contradice la premisa original del
   spec de Plan M (evitar riesgo de gap sacrificando algo de rendimiento). Es un
   sistema distinto en naturaleza, no una optimización de parámetros.
2. **Frecuencia de operación baja.** 56-74 trades en 5,5 años (~10-13/año por
   ticker) es poco para un sistema etiquetado "momentum intradiario".
3. **C9 es asset-dependiente en solitario** (§4.3) — su aporte dentro de la
   combinación ganadora no se ha aislado del todo; podría ser mayormente el
   overnight quien hace el trabajo pesado. Pendiente de descomponer si se quiere
   entender la atribución exacta.
4. **C11 (earnings) sigue sin poder probarse** — el resultado real en vivo podría
   diferir (para mejor, al evitar gaps de earnings específicamente).

---

## 6. Próximos pasos sugeridos

- [ ] Ampliar universo a los 8 tickers completos del spec (AAPL, NVDA, AMZN, META,
      TSLA) con la config ganadora (C9 + overnight) para confirmar que el patrón
      se sostiene fuera del trío de referencia.
- [ ] Probar Config B (3R) con C9 + overnight, cambiando una sola variable.
- [ ] Decidir conscientemente si el sistema pasa a llamarse "Plan M" con esta
      naturaleza híbrida, o si se documenta como una rama derivada distinta.
- [ ] Si se adopta overnight de forma permanente, considerar métricas de gap risk
      explícitas (máxima pérdida en un solo gap, no solo el SL medio agregado).

---

*Documento generado durante la sesión de diagnóstico del 2026-08-24. Actualizar de
forma acumulativa en corridas futuras — no sobrescribir el historial de hallazgos.*
