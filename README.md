# Outlier Plan M System — TradingView Indicators

> TradingView indicators implementing Christopher Uhl's Plan M entry pipeline — top-down market validation, individual stock Trend Template (11 conditions), and ATR-based position sizing.

📖 [Versión en español](./README_ES.md)

---

## Why Plan M and not generic trend following

Plan M is the highest-performing specific plan in the Outlier method, defined with concrete, backtested criteria:

- **Win rate: 56.9%** across more than 7,000 trades
- **Average gain per trade: +2.25%** in stocks → ~14% with 80-delta options
- **Average holding period: 17 days** (swing, not intraday)
- **Only active when:** SPY is in an uptrend, the target sector shows more greed than the market, and the individual stock passes the Trend Template

The three indicators in this repository implement exactly the Plan M entry checklist, in strict sequence. This is not generic trend following — it is the specific validation pipeline of Plan M.

---

## The three indicators

| Indicator | File | Role in the pipeline |
|-----------|------|----------------------|
| Market Dashboard | `ovtlier_market_dashboard.pine` | Step 1 — top-down traffic light: SPY + 11 sectors |
| Trend Template | `ovtlier_trend_template.pine` | Steps 2–4 — 11-condition stock checklist |
| Position Sizer | `outlier_position_sizer.pine` | Step 5 — ATR-based position sizing |

Use them in sequence. Skipping any step invalidates the trade within the Outlier method.

---

## Indicator 1 — Market Dashboard v5.1

A market regime control panel that determines in real time whether conditions are favorable for Plan M. It evaluates three levels simultaneously:

1. **SPY (broad market)** — Is the market in an uptrend?
2. **Market breadth** — Is the trend broad and structurally healthy?
3. **11 sector ETFs** — How many sectors are leading the market?

### The three-state traffic light

| State | Color | Meaning |
|-------|-------|---------|
| ✔ TRADE TODAY — Conditions OK | 🟢 Green | SPY bullish + breadth OK + minimum bullish sectors met |
| ◎ CAUTION — Partial conditions | 🟡 Yellow | SPY bullish, but breadth or sector count insufficient |
| ✘ DO NOT TRADE — Bearish market | 🔴 Red | SPY does not meet the Trend Template |

The chart background mirrors the same state at 93% transparency.

### SPY analysis — four components

**Trend (Outlier Trend Template):** `EMA10 > EMA20` and `price > EMA50`. Binary gate — without this condition, a green signal is impossible.

**Momentum (RSI):** RSI(14) against a configurable threshold (default 55). Confirms the bullish impulse is genuine.

**Volume:** Current SPY volume vs. its SMA(20). Above average signals institutional participation; below average flags a yellow warning without blocking the overall signal.

**Market Breadth:** Dual proxy — `RSI(14) > 50` AND `price > EMA200`. Confirms the trend has sufficient statistical and structural backing.

### Sector analysis — two dimensions per sector

**Sector trend:** Same EMA stack logic as SPY applied to each ETF — `EMA10 > EMA20` and `price > EMA50`.

**Relative strength vs. SPY (RS 20 days):** Sector return over 20 days minus SPY return over the same period. The Outlier method requires the target sector to show more greed than the market before searching for individual stocks within it.

| Sector status | Condition |
|---------------|-----------|
| ✔ TRADE | Bullish trend + positive RS vs. SPY |
| ◎ WAIT | Bullish trend but negative RS |
| ✘ BEARISH | Bearish trend — does not meet the Trend Template |

### The 11 monitored sectors

| ETF | Sector | Default |
|-----|--------|---------|
| XLK | Technology | ✔ Active |
| IGV | Software | ✔ Active |
| XLF | Financials | ✔ Active |
| XLI | Industrials | ✔ Active |
| XLY | Consumer Discretionary | ✔ Active |
| XLC | Communication Services | ✔ Active |
| XLV | Health Care | ✘ Excluded |
| XLE | Energy | ✘ Excluded |
| DBA | Agriculture | ✘ Excluded |
| DBC | Commodities | ✘ Excluded |
| GLD | Precious Metals | ✘ Excluded |

Excluded sectors still appear in the table with live data but do not count toward the traffic light threshold.

### Alerts

Three `alertcondition` definitions fire on regime **transitions** only (not on every bar): Market Green, Market Yellow, Market Red.

---

## Indicator 2 — Ovtlier Trend Template v6

An individual stock validation checklist implementing the **11-condition Outlier Trend Template**, derived from Minervini's methodology and adapted with Uhl's principles. Apply this indicator on the daily chart of a stock **after** the Market Dashboard shows green.

The table is divided into two clearly separated blocks:

- **C1–C8:** the classic Trend Template — moving average structure and annual range position.
- **C9–C11:** the Step 4 additional checks, now integrated directly in the table.

### C1–C8 — Classic Trend Template

| Code | Condition | Pine Script | Meaning |
|------|-----------|-------------|---------|
| C1 | Price > SMA 150 | `close > sma150` | Medium-term uptrend |
| C2 | Price > SMA 200 | `close > sma200` | Long-term uptrend |
| C3 | SMA 150 > SMA 200 | `sma150 > sma200` | Correctly ordered moving average structure |
| C4 | SMA 200 rising | `sma200 > sma200[21]` | Long-term trend is accelerating, not flat |
| C5 | SMA 50 > SMA 150 & 200 | `sma50 > sma150 and sma50 > sma200` | Short-term momentum leading |
| C6 | Price > SMA 50 | `close > sma50` | Price above short-term trend |
| C7 | Price ≥ +25% above 52w Low | `close >= low52w * 1.25` | Stock is not broken or in recovery |
| C8 | Price within 25% of 52w High | `close >= high52w * 0.75` | Stock is in a zone of real strength |

**Why SMAs and not EMAs:** The Trend Template uses simple moving averages (50, 150, 200) following the Minervini-Uhl system. SMAs are slower and less reactive to noise — when a condition is met with SMAs, the trend is truly established.

### C9–C11 — Step 4 additional checks

**C9 — Overextension (fully automatic)**
Calculates the distance from price to SMA50 in ATR multiples. Fails if the stock is more than 2.5× ATR above its SMA50. The exact value is shown dynamically: `C9 · Overext. 1.18 ATR (max 2.5)`.

**C10 — Resistance zone (semi-automatic proxy)**
Scans the last 60 bars for any candle high that entered the 1×ATR–2×ATR band above the current price. A visual orange band is plotted on the chart. FAIL means "review manually" — not an absolute blocker.

**C11 — Earnings window (manual input)**
The user enters the days to next earnings in the indicator settings. PASS if more than 21 days away. Default is 99 (always PASS on load — update before evaluating each trade).

### Verdict

| Verdict | Condition | Action |
|---------|-----------|--------|
| 🟢 VALID BUY SETUP | 8/8 on C1–C8 | Perfect setup — check C9–C11 and proceed |
| 🟡 WATCH (X/8) | 6–7/8 | Setup developing — monitor |
| 🔴 NOT READY (X/8) | < 6/8 | Does not qualify — skip |

The verdict is based on C1–C8 only. C9–C11 are confirmatory.

---

## Indicator 3 — Outlier Position Sizer v4

A position size calculator implementing Christopher Uhl's ATR-based formula, derived from Larry Height's risk management model. Load it on the stock chart **after** the Trend Template shows VALID BUY SETUP.

### The formula

```
// Step 1 — how much money can we lose
Dollar risk     = Balance × (Risk% / 100)

// Step 2 — stop distance based on real volatility
Stop distance   = ATR(14) × Multiplier (default 2.0)
Stop price      = Entry price − Stop distance

// Step 3 — how many shares to buy
Shares          = floor(Dollar risk / Stop distance)

// For options only
Contracts       = floor(Shares / 100 / Delta)
```

**Why ATR × 2 for the stop:** ATR measures the average real movement of the stock over the last 14 periods. A 2×ATR stop sits outside normal statistical noise — a move of that size likely means the trade thesis is wrong.

### Table output

| Field | What it shows | Color |
|-------|---------------|-------|
| 💰 Risk ($) | Maximum dollars to risk | White |
| 📊 ATR(14) | Current ATR value | White |
| 🛑 Stop Loss | Exact stop price, also plotted on chart | Bright red |
| 📦 Shares / 📑 Contracts | Units to buy, floored | Bright teal |
| 💼 Capital used | Total committed capital and % of balance | Teal if <30%, red if >30% |
| Status | Automatic parameter check | Green bg (OK) or red bg (alert) |

### Risk scaling by experience (Uhl)

| Experience | Risk per trade |
|------------|---------------|
| Year 1 | **1%** |
| Year 2 | **2%** |
| Year 3+ | **4–6%** |
| Uhl (16 years) | **6%** |

Never jump risk levels abruptly. Increment gradually after consolidating the previous level.

---

## The complete decision flow

```
Green traffic light (Market Dashboard)
    └── SPY: EMA10 > EMA20 and price > EMA50     ✔
    └── Breadth: RSI > 50 and price > EMA200     ✔
    └── Momentum: RSI > 55                       ✔
    └── Minimum 3 sectors in ✔ TRADE status      ✔
         │
         ▼
Sector with positive RS vs. SPY → ✔ TRADE
         │
         ▼
Trend Template v6 — Block C1–C8
    └── C1–C6: correctly structured SMAs         ✔
    └── C7: +25% above 52-week low               ✔
    └── C8: within 25% of 52-week high           ✔
    Verdict: 🟢 VALID BUY SETUP (8/8)
         │
         ▼
Trend Template v6 — Block C9–C11
    └── C9 (auto):   Overextension < 2.5 ATR     ✔
    └── C10 (semi):  No resistance in 2×ATR zone ✔
    └── C11 (manual): Earnings > 21 days away    ✔
         │
         ▼
Position Sizer v4
    └── Risk ($) = Balance × Risk%
    └── Stop = Price − (ATR × 2)
    └── Shares = floor(Risk$ / Stop distance)
    └── Status: ✓ Parameters OK
         │
         ▼
VALID ENTRY ✔  — define all levels before executing
```

---

## Getting started

1. Open TradingView and go to the Pine Script editor.
2. Copy the contents of the desired `.pine` file from the `indicators/` folder.
3. Paste into the editor and click **Add to chart**.
4. Apply the **Market Dashboard** to a SPY chart for maximum accuracy.
5. Apply the **Trend Template** and **Position Sizer** to the individual stock chart.

---

## Versioning

- **Major versions** (`v1`, `v2`…) introduce significant new features or structural changes.
- **Minor versions** (`v1.1`, `v5.1`…) are refinements or bug fixes within the same feature set.

Full version history is in [CHANGELOG.md](./CHANGELOG.md).

---

## License

[Mozilla Public License 2.0](./LICENSE) · © Outlier Plan M System contributors.  
Based on the Outlier University methodology by Christopher Uhl. For educational purposes.
