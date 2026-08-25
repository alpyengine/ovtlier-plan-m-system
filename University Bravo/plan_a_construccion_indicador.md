# De las fuentes al indicador del Plan A
### Cómo se tradujo el método de Christopher Uhl en un indicador de swing trading Pine Script v6

---

## Qué es el Plan A y en qué se diferencia del Plan M

El Plan A es el marco de swing trading de Uhl. Opera en **temporalidades Daily y Weekly** y se centra en una idea concreta: comprar pullbacks de calidad dentro de regímenes de mercado alcistas confirmados. Mientras el Plan M busca momentum — entrar cuando la acción ya está subiendo con fuerza — el Plan A espera a que el precio "respire" y vuelva a una zona de soporte institucional antes de entrar.

Uhl lo describe así en sus vídeos:

> *"Plan A es para cuando no hay setups de Plan M. El mercado está alcista, la acción también, pero no hay señal de momentum en este momento. Entonces esperas el pullback."*

La ganancia promedio por trade es menor que en el Plan M (+1.22% vs +2.25%), pero las señales son más frecuentes y el riesgo por operación es más controlable porque se entra cerca de soporte.

**Una regla absoluta:** nunca habrá señal de compra del Plan A cuando hay señal de venta del Plan M activa sobre el mismo activo. Los dos planes son complementarios, no conflictivos.

---

## La estructura del indicador: una gate + un sistema de puntuación

La decisión de diseño más importante fue separar las condiciones en dos categorías con distinto peso:

**Condición obligatoria (gate):** La C1 de régimen de mercado. Si el mercado no está en tendencia alcista, el indicador bloquea cualquier señal independientemente de cuántas condiciones adicionales se cumplan. Es una puerta binaria, no puntuada.

**Condiciones puntuadas (C2–C7):** El resto de condiciones suman puntos a un score. El veredicto final depende de cuántos puntos acumula el setup en ese momento concreto. Esto refleja la idea de Uhl de que los mejores setups cumplen múltiples criterios simultáneamente, pero raramente todos al mismo tiempo.

```
Score máximo dinámico:
  5 puntos base (C2–C6)
  +1 si C7 divergencia activada en modo puntuado
  +1 si verificación de TF superior activada en modo puntuado
  = máximo 7 puntos posibles
```

**Niveles de señal:**

| Veredicto | Condición |
|-----------|-----------|
| READY | C1 pasa + score ≥ scoreMax − 1 |
| WATCH | C1 pasa + score == scoreMax − 2 |
| NOT READY | C1 falla o score insuficiente |

---

## Las condiciones una a una: fuente → lógica → código

### C1 — Régimen de Mercado Broad (gate obligatoria)

**Qué dice Uhl:** El sistema Outlier siempre arranca desde el mercado. Antes de mirar cualquier acción, el SPY debe estar en tendencia alcista. En el Plan A, Uhl extiende esta verificación al QQQ también, porque los activos tecnológicos — que son el universo principal del Plan A — tienen alta correlación con el Nasdaq.

**Traducción a código:**

```pine
spyBullish = spyClose > ta.ema(spyClose, emaRegimeInput)
qqqBullish = qqqClose > ta.ema(qqqClose, emaRegimeInput)
c1 = spyBullish and qqqBullish
```

La EMA de referencia es la de 20 períodos por defecto, configurable. Si cualquiera de los dos índices está por debajo de su EMA, C1 falla y el indicador muestra NOT READY sin procesar el resto de condiciones.

**Diferencia respecto al Plan M:** En el Plan M, el régimen se calcula con el Trend Template simplificado de Uhl (EMA10 > EMA20 y precio > EMA50). En el Plan A se usa solo la posición del precio respecto a la EMA20, que es una condición más amplia y permisiva — coherente con el hecho de que el Plan A opera en pullbacks, donde el precio puede estar temporalmente por debajo de medias más cortas.

### C1b — Régimen en Timeframe Superior (opcional)

**Qué dice Uhl:** En sus análisis de swing, Uhl siempre verifica que la tendencia superior confirme. Si estás en Daily, el Weekly debe estar también alcista. Si estás en Weekly, el Monthly.

**Traducción a código:** Se implementó como una verificación adicional configurable mediante `request.security()` al timeframe inmediatamente superior. Tiene dos modos:

- **Gate obligatoria** (`c1bObligatoria = true`): si el TF superior no confirma, bloquea la señal igual que C1.
- **Puntuada** (`c1bObligatoria = false`): suma +1 al score si confirma, no penaliza si no.

Por defecto está desactivada para mantener el indicador operativo en cualquier configuración sin necesidad de ajuste manual.

---

### C2 — Pullback con Contexto de Tendencia

**Qué dice Uhl:** El Plan A entra en pullbacks, pero no en cualquier retroceso. El precio tiene que haber estado claramente en tendencia antes de retroceder, y el pullback tiene que llegar a la zona de la EMA rápida — no desplomarse por debajo de ella.

Dos condiciones deben cumplirse simultáneamente:
1. Las N barras previas cerraron por encima de la EMA rápida (hay tendencia previa demostrada).
2. El mínimo de la barra actual toca o cruza la EMA (el precio ha llegado al soporte).

**Traducción a código:**

```pine
// N barras previas sobre la EMA rápida
barsAboveEma = 0
for i = 1 to c2BarsInput
    if close[i] > emaFast[i]
        barsAboveEma += 1
prevBarsOk = barsAboveEma >= c2BarsInput

// El pullback toca la EMA
pullbackOk = low <= emaFast

c2 = prevBarsOk and pullbackOk
```

El parámetro `c2BarsInput` (por defecto 3 barras) es configurable, y la tabla muestra en tiempo real cuántas de las N barras previas cerraron sobre la EMA — por ejemplo, "2/3 barras OK" — para que el usuario pueda calibrar el setup antes de la señal definitiva.

---

### C3 — Debilidad Relativa del RSI

**Qué dice Uhl:** En un pullback de calidad, el precio retrocede pero el momentum también se debilita. Uhl usa el RSI como confirmador de que el retroceso es genuino y no simplemente que el precio está lateralizando en zona alta.

Aquí hay una distinción importante: Uhl menciona dos versiones del RSI con propósitos distintos.

- **RSI(14):** el RSI estándar. Un valor por debajo de 40 indica debilidad real en el contexto de la tendencia actual.
- **RSI(2):** un RSI de periodo muy corto, altamente sensible. Un valor por debajo de 10 señala un retroceso muy agudo en el muy corto plazo — exactamente la zona donde los pullbacks suelen agotarse y revertir.

**Traducción a código:** Ambas versiones se evalúan en paralelo con un OR lógico:

```pine
rsi14 = ta.rsi(close, 14)
rsi2  = ta.rsi(close, 2)
c3 = rsi14 < rsi14ThreshInput or rsi2 < rsi2ThreshInput
// Por defecto: rsi14 < 40 OR rsi2 < 10
```

Esto hace que C3 sea flexible: funciona tanto en retrocesos lentos y graduales (donde el RSI14 baja progresivamente) como en caídas rápidas de uno o dos días (donde el RSI2 colapsa pero el RSI14 puede seguir en zona neutral).

---

### C4 — Volumen Relativo (RVOL)

**Qué dice Uhl:** El volumen es la huella del dinero institucional. Un pullback con volumen bajo es sano — los institucionales no están vendiendo, simplemente hay pocas operaciones. Un pullback con volumen alto puede indicar distribución — los institucionales están saliendo. Uhl busca señales donde el volumen del día de pullback no sea inusualmente alto.

Sin embargo, en la implementación del Plan A el RVOL se convirtió en una condición con doble lectura: en algunos activos (SMH) el RVOL elevado en el día de señal es positivo porque indica interés institucional en la zona de soporte, mientras que en otros es negativo porque indica presión vendedora.

**Traducción a código:**

```pine
rvol = volume / ta.sma(volume, rvolLengthInput)
c4 = rvol > rvolThreshInput
// Por defecto: volumen > 1.5× su media de 20 días
```

**Hallazgo de la campaña de backtest:** La C4 fue la condición más controvertida del indicador. El backtest demostró que desactivar el gate de RVOL (Config 5) mejoró el Profit Factor en 4 de los 5 tickers del universo operativo. SMH fue la excepción donde el RVOL siguió siendo valioso. Esto llevó a la decisión de hacer C4 completamente configurable en lugar de obligatoria.

---

### C5 — Vela de Reversión (Hammer)

**Qué dice Uhl:** La confirmación visual más potente de un pullback agotado es la vela martillo (hammer): una vela con cuerpo pequeño en la parte superior y una mecha inferior larga. Indica que el precio intentó seguir bajando durante la sesión pero los compradores absorbieron toda la presión vendedora y cerraron cerca de máximos.

**Traducción a código:**

```pine
bodySize = math.abs(close - open)
lowerWick = math.min(close, open) - low
c5 = lowerWick >= bodySize * wickMultInput
// Por defecto: mecha inferior >= 2× el cuerpo
```

El ratio es configurable. En la práctica, un ratio de 2× es el mínimo que Uhl considera significativo — mechas más cortas son simplemente velas normales con algo de sombra inferior.

---

### C6 — Tendencia del Activo (SMA 50/200)

**Qué dice Uhl:** El activo en sí también debe tener estructura de tendencia alcista, no solo el mercado. Uhl usa las SMA de 50 y 200 períodos como referencia de largo plazo. Un activo que opera por debajo de su SMA50 está en territorio técnicamente neutro o bajista, independientemente de lo que haga el mercado general.

**Traducción a código:**

```pine
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)
c6 = close > sma50 and close > sma200 and sma50 > sma200
```

Las tres subcondiciones juntas replican la estructura del Trend Template clásico de Minervini en su versión reducida: precio sobre medias, y medias ordenadas correctamente. C6 puede configurarse como obligatoria o puntuada según el perfil de riesgo del usuario.

---

### C7 — Divergencia Alcista RSI (opcional)

**Qué dice Uhl:** La divergencia alcista es la señal más potente de reversión en un pullback. Ocurre cuando el precio marca un mínimo más bajo que el mínimo anterior, pero el RSI marca un mínimo más alto. Esto indica que la presión vendedora se está agotando: el precio baja pero con menos momentum bajista cada vez.

**Traducción a código:** Se busca la divergencia comparando el mínimo actual de precio y RSI contra el mínimo de las últimas N barras:

```pine
rsi14 = ta.rsi(close, 14)

// Mínimo previo de precio y RSI en ventana configurable
prevPriceLow = ta.lowest(low,  c7LookbackInput)[1]
prevRsiLow   = ta.lowest(rsi14, c7LookbackInput)[1]

// Divergencia: precio hace LL, RSI hace HL
c7 = low < prevPriceLow and rsi14 > prevRsiLow
```

La ventana de lookback (por defecto 5 barras) es configurable. Una ventana corta detecta divergencias rápidas de 2–3 días; una ventana más larga detecta divergencias de estructura más amplia. C7 está activada por defecto en modo puntuado — suma 1 punto al score pero no es obligatoria.

---

## El sistema de scoring en conjunto

La potencia del indicador del Plan A no está en ninguna condición individual sino en la combinación. Uhl insiste en que los mejores setups son los que confluyen múltiples señales al mismo tiempo:

```
Régimen alcista (C1) + Pullback a EMA (C2) + RSI débil (C3)
+ Hammer (C5) + Tendencia activo (C6) + Divergencia RSI (C7)
= Setup de máxima calidad
```

El score numérico permite al usuario ver en tiempo real qué tan cerca está un setup de la señal completa, y tomar decisiones graduadas: esperar a una barra más, ajustar el tamaño de posición según la puntuación, o ignorar setups con score mínimo.

---

## Los modos de salida — resultado del backtest

El backtest del Plan A (v2.1) identificó cuatro modos de salida con comportamientos distintos según el activo:

| Modo | Lógica | Mejor en |
|------|--------|---------|
| B | Stop trailing basado en ATR | Tendencias prolongadas |
| C | Cierre por debajo de EMA (close) | Activos con tendencias limpias |
| D | Cruce EMA en cierre (crossunder) | VGT, MSFT |
| Zombie | Cierre forzado por máximo de barras | Protección en laterales |

El hallazgo más relevante de la campaña fue que **Config 5** (RVOL desactivado, minScore 4) superó a Config 2 (RVOL activo) en 4 de 5 tickers — SMH fue la única excepción. Esto confirmó que el gate de RVOL obligatorio estaba eliminando entradas válidas en entornos de tendencia con volumen bajo pero estructuralmente sano.

---

## El universo operativo confirmado

Tras la campaña de backtest completa, el universo del Plan A quedó definido en dos tiers:

| Ticker | Timeframe | Config | Profit Factor | Tier |
|--------|-----------|--------|---------------|------|
| VGT | Daily | Config 5 | 4.74 | 1 |
| SMH | Daily | Config 2 | 7.80 | 1 |
| IGV | Daily | Config 5 | 1.53 | 1 (condicional) |
| SPY | Daily | Config 5 | 3.48 | 2 |
| MSFT | Daily | Config 5 | 2.55 | 2 |

El timeframe Weekly fue descartado por volumen de señal insuficiente. El 4H fue descartado definitivamente en todos los tickers por win rate estructuralmente bajo (~34%).

---

## Resumen del proceso de traducción

El Plan A sigue el mismo proceso que el Plan M: identificar la idea verbal de Uhl → encontrar la condición matemática equivalente → implementar con los parámetros que él menciona → documentar las desviaciones. Las diferencias respecto al Plan M son dos:

**Mayor subjetividad en origen:** El Plan A tiene más condiciones "visuales" en las fuentes (el hammer, la divergencia RSI) que requirieron más decisiones de diseño antes de llegar a código. El Plan M usa condiciones más directamente cuantificables.

**El backtest como validador:** Mientras el Plan M todavía estaba en fase de backtest al cierre de este documento, el Plan A tiene una campaña completa (31 secciones, 5 tickers, múltiples configuraciones y timeframes) que validó o corrigió cada decisión de diseño. El caso más relevante fue C4 (RVOL): lo que parecía una condición sólida en teoría resultó ser una restricción excesiva en la práctica para 4 de los 5 activos del universo.

---

*Documento generado a partir del historial de construcción del proyecto `alpyengine/ovtlier-plan-a-system`*
*y las transcripciones de Outlier University de Christopher Uhl.*
*Repositorio: `ovtlier-plan-a-system` — Indicador activo: `ovtlier_plan_a.pine` v5.2*
