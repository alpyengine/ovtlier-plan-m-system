# Changelog — Outlier Plan M System

All notable changes across the three indicators are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Tags use the format `indicator/vX.Y` (e.g. `dashboard/v5.2`, `trend-template/v7`, `position-sizer/v5`).

---

## Market Dashboard

### [dashboard/v5.2] — 2026-08-21 (Current)

#### Added
- `tamPanelInput`: configurable text size input (`tiny` / `small` / `normal` / `large`, default `small`).
- `f_textSize()` helper function resolving the string input to the corresponding `size.*` constant.
- `TS` and `TS_SML` constants: resolved text size applied consistently across all table cells.
  `TS_SML` is fixed to `size.tiny` for description/secondary cells regardless of the input.

#### Changed
- **Anti-repainting fix (Part 1):** all `request.security()` calls now use
  `lookahead = barmerge.lookahead_on` and `[1]` offset on the expression,
  matching the pattern used in Plan A. Previously calls used current-bar values.
  `f_isBullish()` and `f_relStrength()` updated accordingly.
  Note: `"D"` timeframe in `f_relStrength()` is kept by design — RS always measures
  20 calendar days regardless of the active chart timeframe.
- **Visual redesign (Part 2):** dark palette replaced by light palette consistent
  with Market Dashboard design-v5, Plan A, and Position Sizer v5:
  - Surface: `#ffffff` (odd rows) / `#f4f5f8` (even rows alternating)
  - Header background: `#eef0f6`
  - Badges: tag-green (`#dcfce7` / `#14532d`) and tag-red (`#fee2e2` / `#991b1b`)
  - Amber for ESPERAR state: `#fef3c7` / `#b45309`
  - Excluded sectors: `#dde0e8` background / `#8c92a0` text
  - Semaphore row colors use 10% transparency variants for added prominence
- `bgcolor()` background colors updated to match light palette:
  green `#dcfce7` / amber `#fef3c7` / red `#fee2e2` at 88% transparency.
- Sector estado labels simplified: `✔ OPERAR` -> `OPERAR`, `◎ ESPERAR` -> `ESPERAR`,
  `✘ BAJISTA` -> `BAJISTA` (badge color conveys status, text is cleaner).

#### Fixed
- All `request.security()` calls now return confirmed previous-bar values,
  eliminating potential repainting on live bars.

---

### [dashboard/v5.1]

#### Added
- Dedicated row (row 6) exclusively for the sector counter, now spanning all 4 columns.
- Dedicated row (row 7) for sector column headers (`Sector | Tendencia | RS 20d | Estado`),
  restoring the header that was invisible in v5 due to cell merging.
- Three-level differentiation in the sector `Estado` column:
  `✔ OPERAR` (bullish + positive RS), `◎ ESPERAR` (bullish, negative RS), `✘ BAJISTA` (bearish trend).

#### Changed
- Table expanded from 18 to 19 rows.
- Sector data loop starts at row 8 (was row 7).

#### Fixed
- Column header `Tendencia` was not visible in v5 because it shared a merged cell
  with the sector counter. Now correctly displayed in its own dedicated row.

---

### [dashboard/v5.0]

#### Added
- 4 new sectors: Software (IGV), Agricultura (DBA), Commodities (DBC), Metales Preciosos (GLD)
  — expanding coverage from 7 to 11 sectors.
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
- `marketYellow` boolean: three-state traffic light. Yellow state fires when SPY is bullish
  but breadth or sector count are insufficient.
- Sector header row shows `SECTORES X/Y alcistas` with dynamic background.

#### Changed
- Title row updated to three states: `✔ OPERAR HOY`, `◎ PRECAUCIÓN`, `✘ NO OPERAR`.
- `bgcolor()` updated to reflect three states: green / yellow / red.

---

### [dashboard/v3.0]

#### Added
- Per-sector exclusion toggles for all 7 sectors including the 5 core ones
  (XLK, XLF, XLI, XLY, XLC) that were previously non-configurable.

#### Changed
- `activeSectors` respects all 7 exclusion booleans.
- `SectorData` array uses all 7 dynamic exclusion inputs.

---

### [dashboard/v2.0]

#### Added
- `excludeXLVInput` and `excludeXLEInput` boolean toggles: users can now include
  Sanidad (XLV) and Energía (XLE) in the active sector count. Previously hardcoded as excluded.

#### Changed
- `activeSectors` calculation updated for XLV and XLE toggles.
- Sector names cleaned: removed hardcoded `✘` prefix from XLV/XLE names.

---

### [dashboard/v1.3]

#### Changed
- MMFI breadth proxy removed entirely (`SKILLING:MMFI` proved unreliable across accounts).
- Breadth replaced with dual native proxy: `spyRsi > 50 AND spyClose > spyEma200`.
- Requires new `request.security()` call for `spyEma200`.
- Dashboard breadth row label updated: `%Acc>MM50` -> `RSI>50+E200`.

---

### [dashboard/v1.2]

#### Fixed
- `mmfiOk` was assigned `na` when MMFI was unavailable instead of `false`,
  causing `breadthOk` to evaluate incorrectly. Replaced with explicit
  `mmfiLoaded` boolean (`not na(mmfiClose)`).
- `breadthStatus` in the table now reads from pre-computed `breadthOk`
  instead of recalculating inline.

---

### [dashboard/v1.1]

#### Fixed
- `SectorData` UDT moved from inside the `if barstate.islast` block to global scope.
  Pine Script v6 requires UDT declarations at top-level scope; declaring them inside
  a conditional block caused a compile error.

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

### [trend-template/v7] — 2026-08-21 (Current)

#### Changed
- **Visual redesign:** full light palette consistent with Market Dashboard v5.2,
  Plan A, and Position Sizer v5. Replaces the previous dark/opaque palette.
  - Table background: `#eef0f6` (header), `#ffffff` / `#f4f5f8` alternating rows
  - Badges: tag-green (`#dcfce7` / `#14532d`) and tag-red (`#fee2e2` / `#991b1b`)
  - Step 4 header: amber `#fef3c7` / `#b45309` (unchanged in intent, updated hex)
  - Verdict rows: green/amber/red light badge palette
  - Primary text: `#000000` (black) for maximum contrast on light backgrounds
  - `condLabel()` updated: `PASS` -> `✅  PASS`, `FAIL` -> `❌  FAIL`
- `tamPanelInput`: configurable text size input (`tiny` / `small` / `normal` / `large`).
  `textSize()` helper resolves the string to the `size.*` constant.
  `TS` variable applied to all table cells; verdict row uses `size.normal` fixed.
- `table.delete()` / `table.new()` pattern on `barstate.islast`:
  table is now recreated each time (previously `var table` with persistent reference).
  Ensures clean re-render when inputs change without reloading the indicator.
- `tablePos()` function renamed to `tablePos(string pos)` — now a named function
  matching the style of the other indicators.
- Frame width increased to 2, border color set to `#d1d5db`.

#### Note
No changes to signal logic (C1-C11), condition thresholds, SMA periods,
52-week range parameters, overextension limit, resistance zone, or alerts.

---

### [trend-template/v6]

#### Fixed
- CE10095: removed duplicate `atr14` / `resistZone` variable declarations that existed
  in both the conditions block and the plots block. The plots block now reuses `atr14`,
  `resistanceTop`, and `resistanceBottom` directly from the conditions block.

---

### [trend-template/v5]

#### Added
- C9 — Overextension check (fully automatic): calculates distance from price to SMA50
  in ATR multiples. Configurable limit (`atrMaxMult`, default 2.5).
  Value shown dynamically in table cell.
- C10 — Resistance zone proxy (semi-automatic): scans last 60 bars for candle highs
  inside the 1xATR-2xATR band above current price.
- C11 — Earnings window (manual input): user enters days to next earnings. PASS if > 21 days.
  Default 99.
- Visual orange band plotted on chart: `close + 1xATR` to `close + 2xATR` with fill.
- Step 4 section header row added to table separating C1-C8 from C9-C11.
- Table expanded from 13 to 17 rows.
- New input group `Step 4 — Manual Checks` with `atrMaxMult` and `earningsDays` inputs.

---

### [trend-template/v4]

#### Changed
- All table cell backgrounds changed from semitransparent to fully opaque solid colors.
- Condition rows: solid dark navy `#1a1a2e`.
- PASS: `color.teal opacity 10` -> solid teal. FAIL: `color.red opacity 10` -> solid red.
- Verdict row colors fully opaque: teal / orange / maroon.
- Footer: `color.silver` text on solid `#1a1a1a` background.
- Subheader: `#2d2d2d` solid background with silver text.

---

### [trend-template/v2]

#### Fixed
- CE10156: multiline ternary expressions now use line continuation `\` syntax.
- CE10123: `alertcondition()` requires `const string` message. Replaced with `alert()`
  calls for dynamic messages; retained static `alertcondition()` for alert panel.

---

### [trend-template/v1] — Initial release

#### Added
- 8-condition Trend Template (C1-C8): SMA 50/150/200 structure, 52-week high/low range.
- Table checklist with 13 rows.
- Three SMA plots on chart: SMA50 (blue), SMA150 (orange), SMA200 (red).
- Three-state background: teal (8/8), yellow (6-7/8), red (< 6/8).
- Three alert conditions: Full Approval (8/8), Watch (6-7/8), Price crossed SMA200.
- `SCRIPT_VERSION`, `SCRIPT_DATE`, `SCRIPT_NAME` constants.
- Configurable: SMA periods, 52w thresholds, table position, show/hide toggles.

---

## Position Sizer

### [position-sizer/v5] — 2026-08-21 (Current)

#### Added
- `tamPanelInput`: configurable text size input (`tiny` / `small` / `normal` / `large`).
  `resolveSize()` helper resolves the string to the `size.*` constant.
  Applied via `SZ` variable to all table cells (separator row uses `size.tiny` fixed).

#### Changed
- **Visual redesign:** full light palette consistent with Market Dashboard v5.2,
  Plan A, and Trend Template v7. Replaces the previous dark palette.
  - Surface: `#ffffff` (odd rows) / `#f4f5f8` (even rows)
  - Header background: `#eef0f6`
  - Labels/values: `#1a1f2e` (dark text on light background)
  - Ticker in header: `#b45309` (amber — prominent without being strident)
  - Separator row: `#f4f5f8` background / `#4b5563` text
  - Shares/contracts value: `#14532d` (tag-green-text)
  - Stop loss value: `#dc2626` (red)
  - Capital warning: `#dc2626` (red if > 30%), `#14532d` (green if OK)
  - Alert row: tag-green-bg (`#dcfce7`) or tag-red-bg (`#fee2e2`) with matching text
  - Frame: `#d1d5db` (light gray border), border: `#e5e7eb` (very subtle cell separator)
- Header layout: title left-aligned (`OUTLIER  POSITION  SIZER`),
  ticker right-aligned in amber — replaces the previous full-width merged header.
- `tablePosition()` helper extended to 9 positions
  (Top/Middle/Bottom x Left/Center/Right).

#### Note
No changes to calculation logic, ATR formula, position sizing, options mode,
stop loss line plot, or alert strings.

---

### [position-sizer/v4]

#### Changed
- Separator row (row 1): background `#0a0f18` -> `#102040`, text `#2a4060` -> `#7fb8e8`.
  Label updated to `PARÁMETROS DE RIESGO` in uppercase.
- Status row (row 7): conditional background — dark red `#2a0010` on alert,
  dark green `#002a1a` when OK.
- Label column: lightened from `#c8d8e8` to `#ddeeff`.

---

### [position-sizer/v3]

#### Changed
- Maximum contrast palette: background `#080c12`, labels `#c8d8e8`, values `#ffffff`,
  teal `#00ffcc`, red `#ff3355`. Frame width 1 -> 2, frame color -> `#1e3a5f`.

---

### [position-sizer/v2]

#### Added
- 9-position table placement input. `tablePosition()` helper via `switch` statement.
- `table.set_position()` for dynamic repositioning without reloading.
- Visual separator row (row 1). Third status alert when `rawShares == 0`.

#### Fixed
- Blank cells caused by computing display strings inside `if barstate.islast`.
  All strings now pre-computed at global scope.

---

### [position-sizer/v1] — Initial release

#### Added
- ATR-based position sizing: `Shares = floor(DollarRisk / StopDistance)`.
- Options mode: `Contracts = floor(Shares / 100 / Delta)`.
- Capital used display with % of balance.
- Dynamic stop-loss line on chart (red dashed).
- 7-row table: header, dollar risk, ATR, stop price, shares/contracts, capital, status.
- Two status alerts: risk > 2%, capital concentration > 30%.
- `calcDollarRisk()`, `calcStopDistance()`, `calcShares()` helper functions.
