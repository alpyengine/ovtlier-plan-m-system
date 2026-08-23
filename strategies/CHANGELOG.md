# Changelog — Outlier Plan M System

All notable changes across the three indicators are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Tags use the format `indicator/vX.Y` (e.g. `dashboard/v5.1`, `trend-template/v6`, `position-sizer/v4`).

---

## Market Dashboard

### [dashboard/v5.1] — Current

#### Added
- Dedicated row (row 6) exclusively for the sector counter, now spanning all 4 columns.
- Dedicated row (row 7) for sector column headers (`Sector | Tendencia | RS 20d | Estado`), restoring the header that was invisible in v5 due to cell merging.
- Three-level differentiation in the sector `Estado` column: `✔ OPERAR` (bullish + positive RS), `◎ ESPERAR` (bullish, negative RS), `✘ BAJISTA` (bearish trend).

#### Changed
- Table expanded from 18 to 19 rows.
- Sector data loop starts at row 8 (was row 7).

#### Fixed
- Column header `Tendencia` was not visible in v5 because it shared a merged cell with the sector counter. Now correctly displayed in its own dedicated row.

---

### [dashboard/v5.0]

#### Added
- 4 new sectors: Software (IGV), Agricultura (DBA), Commodities (DBC), Metales Preciosos (GLD) — expanding coverage from 7 to 11 sectors.
- Alert system: three `alertcondition()` calls that fire on regime transitions (Verde, Amarillo, Rojo).
- Explicit Pine Script v6 type annotations on all function parameters.
- `@function` and `@param` annotations on all named functions.

#### Changed
- XLE (Energía) is no longer excluded by default — it is now a first-class sector with its own toggle.
- Table expanded from 14 to 18 rows.
- `maxval` for `minSectorsInput` raised from 7 to 11.

---

### [dashboard/v4.0]

#### Added
- `minSectorsInput`: configurable minimum bullish sectors (default 3, max 7). Previously hardcoded.
- `totalActive` counter: tracks non-excluded sectors for the `X/Y alcistas` display.
- `marketYellow` boolean: three-state traffic light. Yellow state fires when SPY is bullish but breadth or sector count are insufficient.
- Sector header row shows `SECTORES X/Y alcistas` with dynamic background.

#### Changed
- Title row updated to three states: `✔ OPERAR HOY`, `◎ PRECAUCIÓN`, `✘ NO OPERAR`.
- `bgcolor()` updated to reflect three states: green / yellow / red.

---

### [dashboard/v3.0]

#### Added
- Per-sector exclusion toggles for all 7 sectors including the 5 core ones (XLK, XLF, XLI, XLY, XLC) that were previously non-configurable.

#### Changed
- `activeSectors` respects all 7 exclusion booleans.
- `SectorData` array uses all 7 dynamic exclusion inputs.

---

### [dashboard/v2.0]

#### Added
- `excludeXLVInput` and `excludeXLEInput` boolean toggles: users can now include Sanidad (XLV) and Energía (XLE) in the active sector count. Previously hardcoded as excluded.

#### Changed
- `activeSectors` calculation updated for XLV and XLE toggles.
- Sector names cleaned: removed hardcoded `✘` prefix from XLV/XLE names.

---

### [dashboard/v1.3]

#### Changed
- MMFI breadth proxy removed entirely (`SKILLING:MMFI` proved unreliable across accounts).
- Breadth replaced with dual native proxy: `spyRsi > 50 AND spyClose > spyEma200`.
- Requires new `request.security()` call for `spyEma200`.
- Dashboard breadth row label updated: `%Acc>MM50` → `RSI>50+E200`.

---

### [dashboard/v1.2]

#### Fixed
- `mmfiOk` was assigned `na` when MMFI was unavailable instead of `false`, causing `breadthOk` to evaluate incorrectly. Replaced with explicit `mmfiLoaded` boolean (`not na(mmfiClose)`).
- `breadthStatus` in the table now reads from pre-computed `breadthOk` instead of recalculating inline.

---

### [dashboard/v1.1]

#### Fixed
- `SectorData` UDT moved from inside the `if barstate.islast` block to global scope. Pine Script v6 requires UDT declarations at top-level scope; declaring them inside a conditional block caused a compile error.

---

### [dashboard/v1.0] — Initial release

#### Added
- SPY analysis: EMA trend (10/20/50), RSI momentum, volume vs MA.
- Market breadth proxy using `SKILLING:MMFI` with RSI fallback.
- 7-sector dashboard: XLK, XLF, XLI, XLY, XLC (active) + XLV, XLE (excluded).
- Relative strength calculation per sector vs SPY over 20 days.
- `f_isBullish()` and `f_relStrength()` helper functions.
- `SectorData` UDT for array-based sector rendering.
- Configurable table position (4 options).
- `bgcolor()` bar background: green / yellow / red.
- Two-state traffic light: `marketGreen` boolean.

---

## Trend Template

### [trend-template/v6] — Current

#### Fixed
- CE10095: removed duplicate `atr14` / `resistZone` variable declarations that existed in both the conditions block and the plots block. The plots block now reuses `atr14`, `resistanceTop`, and `resistanceBottom` directly from the conditions block.

---

### [trend-template/v5]

#### Added
- C9 — Overextension check (fully automatic): calculates distance from price to SMA50 in ATR multiples. Configurable limit (`atrMaxMult`, default 2.5). Value shown dynamically in table cell.
- C10 — Resistance zone proxy (semi-automatic): scans last 60 bars for candle highs inside the 1×ATR–2×ATR band above current price.
- C11 — Earnings window (manual input): user enters days to next earnings. PASS if > 21 days. Default 99.
- Visual orange band plotted on chart: `close + 1×ATR` to `close + 2×ATR` with fill, for visual confirmation of C10.
- Step 4 section header row added to table separating C1–C8 from C9–C11.
- Table expanded from 13 to 17 rows.
- New input group `⚠️ Step 4 — Manual Checks` with `atrMaxMult` and `earningsDays` inputs.

---

### [trend-template/v4]

#### Changed
- All table cell backgrounds changed from semitransparent (`color.new(color.black, 70–80)`) to fully opaque solid colors.
- Condition rows now use solid dark navy `#1a1a2e` instead of semitransparent black.
- PASS color: `color.teal opacity 10` → `color.teal opacity 0` (fully opaque solid green).
- FAIL color: `color.red opacity 10` → `color.red opacity 0` (fully opaque solid red).
- Verdict row colors fully opaque: teal / orange / maroon.
- Footer row: text color changed to `color.silver` on solid `#1a1a1a` background.
- Subheader row: `color.new(#2d2d2d, 0)` background with silver text.

> **Note on file naming:** The original file `Ovtlier_Trend_Template_v3.pine` contained the v4 codebase internally (`SCRIPT_VERSION = "v4"`). This commit corresponds to that file. The version number mismatch is a save error in the original workflow; the code is identical to what is labeled v4.

---

### [trend-template/v2]

#### Fixed
- CE10156: multiline ternary expressions now use line continuation `\` syntax. Previously the compiler failed to parse multiline ternaries without continuation markers.
- CE10123: `alertcondition()` requires a `const string` message — dynamic strings are not allowed. Replaced with `alert()` calls for dynamic messages, and retained static `alertcondition()` for TradingView alert panel compatibility.

---

### [trend-template/v1] — Initial release

#### Added
- 8-condition Trend Template (C1–C8): SMA 50/150/200 structure, 52-week high/low range.
- Table checklist with 13 rows: header, ticker/timeframe subheader, column headers, 8 condition rows, verdict row, version footer.
- Three SMA plots on chart: SMA50 (blue, thin), SMA150 (orange, thin), SMA200 (red, thick).
- Three-state background: teal (8/8), yellow (6–7/8), red (< 6/8).
- Three alert conditions: Full Approval (8/8), Watch (6–7/8), Price crossed SMA200.
- `SCRIPT_VERSION`, `SCRIPT_DATE`, `SCRIPT_NAME` constants for version tracking.
- Configurable: SMA periods, 52w high/low thresholds, table position, show/hide toggles.

---

## Position Sizer

### [position-sizer/v4] — Current

#### Changed
- Separator row (row 1) redesigned: background changed from near-black `#0a0f18` to medium blue `#102040`, text changed from invisible dark blue `#2a4060` to readable light blue `#7fb8e8`, label updated to `PARÁMETROS DE RIESGO` in uppercase.
- Status row (row 7) now has a conditional background: dark red `#2a0010` when any alert is active, dark green `#002a1a` when all parameters are OK. Previously always the same dark background regardless of status.
- Label color in left column lightened from `#c8d8e8` to `#ddeeff` for improved contrast.

> **Note:** No changes to calculation logic, formula, inputs, or outputs. This is a pure visual refinement.

---

### [position-sizer/v3]

#### Changed
- All colors increased to maximum contrast: background darkened to `#080c12`, labels to `#c8d8e8` (bright blue-white), values to `#ffffff` (pure white), teal to `#00ffcc` (bright), red to `#ff3355` (vivid).
- Frame width increased from 1 to 2 for stronger table border.
- Frame color changed to `#1e3a5f`.

---

### [position-sizer/v2]

#### Added
- 9-position table placement input (`posInput`): Top/Middle/Bottom × Left/Center/Right.
- `tablePosition()` helper function using `switch` statement for clean position resolution.
- `table.set_position()` called on `barstate.islast` to allow dynamic repositioning without reloading.
- Visual separator row (row 1) between header and data rows.
- Third alert condition in status row: `⚠ Stop = 0, revisar ATR` when `rawShares == 0`.

#### Fixed
- Empty cells in v1 caused by computing display strings inside `if barstate.islast`. All strings now pre-computed at global scope before the conditional block, fixing the blank cell bug.

#### Changed
- Color scheme updated: dark navy palette replacing the previous default colors.
- Cell text sizes unified to `size.small` for readability.

---

### [position-sizer/v1] — Initial release

#### Added
- ATR-based position sizing formula: `Shares = floor(DollarRisk / StopDistance)`.
- Options mode: `Contracts = floor(Shares / 100 / Delta)`.
- Capital used display with percentage of account balance.
- Dynamic stop-loss price plotted on chart as a red dashed line.
- Table with 7 rows: header (ticker), dollar risk, ATR value, stop price, shares/contracts, capital used, status alert.
- Two-condition status alert: risk > 2% warning, capital concentration > 30% warning.
- `calcDollarRisk()`, `calcStopDistance()`, `calcShares()` helper functions with `@function` / `@param` annotations.
- Configurable: balance, risk%, ATR length, ATR multiplier, options toggle, delta.
---

## Backtest

### [backtest/v1] — 2026-08-23 (Current)

#### Added
- First Plan M backtest strategy combining Market Dashboard v5.2 and
  Trend Template v7 into a single monolithic `strategy()` script.
- **Gate de regimen (Dashboard v5.2):** SPY EMA10 > EMA20 and close > EMA50,
  RSI(14) > 55, breadth proxy (RSI > 50 and close > EMA200), minimum
  configurable bullish sectors (default 3 of 11). Anti-repainting:
  all `request.security()` calls use `close[1]` + `barmerge.lookahead_on`.
- **Señal de entrada (Trend Template v7 — C1-C10):**
  C1-C8 Minervini conditions (SMA 50/150/200 structure, 52w range),
  C9 overextension check (dist to SMA50 < 2.5x ATR14),
  C10 resistance zone proxy (no swing high in 1-2xATR band above price
  in last 60 bars). C11 (earnings window) excluded — no reliable
  historical earnings feed in Pine Script v6 without external data.
  See header comment for full documented limitation.
- **Position sizing (Position Sizer v5 formula):**
  `Shares = floor(DollarRisk / (ATR14 x atrStopMultInput))`.
  Stop multiplier default 1.5x (vs 2.0x in live Position Sizer v5
  — design decision for this backtest, documented in input tooltip).
- **Exit logic:**
  Stop loss at entry - (ATR14 x 1.5), configurable via `atrStopMultInput`.
  Take profit at entry + (stop distance x rMultipleInput):
  Config A = 2R (default), Config B = 3R (change only `rMultipleInput`).
  Forced close on `session.islastbar_regular` — no overnight positions.
- **Helpers:** `f_isBullish()` replicated from Dashboard v5.2;
  `f_calcShares()` replicated from Position Sizer v5.
- **Visuals:** green/red `bgcolor()` showing marketGreen regime;
  dynamic SL and TP lines plotted on chart via `plot()`;
  `plotshape()` triangle on valid entry bars.
- **Alerts:** `alert()` on entry and forced session close;
  `alertcondition()` for regime transition and full approval.
- **Strategy parameters:** `initial_capital = 25000`, commission 0.05%,
  slippage 1 tick, `process_orders_on_close = true`,
  `calc_on_every_tick = false`.

#### Known limitations (documented in file header)
- C11 (earnings window) excluded from backtest entry signal.
  Live trading adds this check manually — backtest results are
  therefore slightly more permissive than live execution.
- Single-symbol backtest only (the symbol on the active chart).
  Does not simulate portfolio allocation across multiple stocks.
