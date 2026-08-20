#!/usr/bin/env bash
# =============================================================================
# setup_repo.sh — Outlier Plan M System · Git history reconstruction
# =============================================================================

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================

REPO_DIR="/Users/alex/Coding/TradingProjects/Ovtlier/outlier-plan-m-system"
DASHBOARD_DIR="/Users/alex/Coding/TradingProjects/Ovtlier/Outlier-Market-Dashboard"
TEMPLATE_DIR="/Users/alex/Coding/TradingProjects/Ovtlier/TrendTemplate"
SIZER_DIR="/Users/alex/Coding/TradingProjects/Ovtlier/PositionSizer"
REMOTE_URL="https://github.com/alpyengine/outlier-plan-m-system.git"

GIT_USER="alpyengine"
GIT_EMAIL="alpyengine@gmail.com"

# =============================================================================
# STEP 1 — Initialise repository
# =============================================================================

echo "▶ Initialising repository..."

cd "$REPO_DIR"
git init
git branch -M main
git config user.name  "$GIT_USER"
git config user.email "$GIT_EMAIL"

mkdir -p indicators strategies libs
touch strategies/.gitkeep libs/.gitkeep

git add README.md README_ES.md CHANGELOG.md LICENSE \
        strategies/.gitkeep libs/.gitkeep

git commit -m "chore: initial repository setup — Outlier Plan M System

Initialises the monorepo for the three Plan M TradingView indicators.
Adds root README (EN), README_ES (ES), unified CHANGELOG, and LICENSE
(MPL 2.0). Placeholder .gitkeep files for strategies/ and libs/.

Indicators to be added in subsequent commits:
  - ovtlier_market_dashboard.pine  (v1.0 -> v5.1)
  - ovtlier_trend_template.pine    (v1   -> v6)
  - outlier_position_sizer.pine    (v1   -> v4)"

echo "✔ Initial commit done."

# =============================================================================
# STEP 2 — Market Dashboard (v1.0 -> v5.1)
# =============================================================================

DASHBOARD="$REPO_DIR/indicators/ovtlier_market_dashboard.pine"

echo ""
echo "▶ Committing Market Dashboard history..."

cp "$DASHBOARD_DIR/market_dashboard_v1.pine"     "$DASHBOARD"
git add indicators/ovtlier_market_dashboard.pine
git commit -m "feat(dashboard): v1.0 — initial release

Core SPY analysis via EMA 10/20/50 stack, RSI momentum filter,
volume vs MA. Market breadth proxy using SKILLING:MMFI with RSI
fallback. 7-sector dashboard (XLK, XLF, XLI, XLY, XLC active;
XLV, XLE excluded). Relative strength vs SPY over 20 days.
f_isBullish() and f_relStrength() helpers. SectorData UDT.
Configurable table position. bgcolor() bar background.
Two-state traffic light: marketGreen boolean."
git tag dashboard/v1.0

cp "$DASHBOARD_DIR/market_dashboard_v1_0_1.pine" "$DASHBOARD"
git add indicators/ovtlier_market_dashboard.pine
git commit -m "fix(dashboard): v1.1 — move SectorData UDT to global scope

Pine Script v6 requires UDT declarations at top-level scope.
SectorData type was declared inside if barstate.islast block,
causing a compile error on some accounts. Moved to global scope
between colour helpers and table initialisation."
git tag dashboard/v1.1

cp "$DASHBOARD_DIR/market_dashboard_v1_0_2.pine" "$DASHBOARD"
git add indicators/ovtlier_market_dashboard.pine
git commit -m "fix(dashboard): v1.2 — correct MMFI fallback boolean logic

mmfiOk was assigned na (not false) when MMFI data was unavailable,
causing breadthOk to evaluate incorrectly via the na(mmfiOk) chain.

- Introduced explicit mmfiLoaded boolean: not na(mmfiClose)
- mmfiOk now evaluates to false when MMFI is unavailable
- breadthOk simplified: mmfiLoaded ? mmfiOk : spyRsi > 50
- Table breadthStatus cell reads from pre-computed breadthOk"
git tag dashboard/v1.2

cp "$DASHBOARD_DIR/market_dashboard_v1_0_3.pine" "$DASHBOARD"
git add indicators/ovtlier_market_dashboard.pine
git commit -m "refactor(dashboard): v1.3 — replace MMFI with dual native proxy

SKILLING:MMFI proved unreliable across TradingView accounts.
Replaced with dual proxy using only native SPY data.

- Added spyEma200 via request.security()
- breadthOk = spyRsi > 50 AND spyClose > spyEma200
- mmfiLoaded hardcoded false; mmfiClose set to na
- Breadth row label: '%Acc>MM50' -> 'RSI>50+E200'
- Breadth row value: shows 'RSI:XX.X E200:up/down'"
git tag dashboard/v1.3

cp "$DASHBOARD_DIR/market_dashboard_v2.pine"     "$DASHBOARD"
git add indicators/ovtlier_market_dashboard.pine
git commit -m "feat(dashboard): v2.0 — configurable exclusion toggles for XLV and XLE

XLV (Sanidad) and XLE (Energia) were previously hardcoded as excluded.
Users can now include either sector via input booleans.

- Added excludeXLVInput and excludeXLEInput boolean inputs (grp5)
- activeSectors count respects toggles for XLV and XLE
- Sector name strings cleaned: removed hardcoded X prefix
- SectorData array uses dynamic exclusion booleans for all 7 sectors"
git tag dashboard/v2.0

cp "$DASHBOARD_DIR/market_dashboard_v3.pine"     "$DASHBOARD"
git add indicators/ovtlier_market_dashboard.pine
git commit -m "feat(dashboard): v3.0 — full per-sector exclusion for all 7 sectors

Extended exclusion toggles from 2 sectors (XLV, XLE) to all 7.
Users can now remove any sector from the active count independently.

- Added excludeXLKInput, excludeXLFInput, excludeXLIInput,
  excludeXLYInput, excludeXLCInput inputs (grp5, all default false)
- activeSectors updated to respect all 7 exclusion booleans"
git tag dashboard/v3.0

cp "$DASHBOARD_DIR/market_dashboard_v4.pine"     "$DASHBOARD"
git add indicators/ovtlier_market_dashboard.pine
git commit -m "feat(dashboard): v4.0 — three-state traffic light and sector threshold

Binary green/not-green signal becomes three-state traffic light
(green/yellow/red), and sector threshold is configurable.

- Added minSectorsInput: configurable min bullish sectors (default 3)
- Added totalActive: denominator for 'X/Y alcistas' display
- Added marketYellow: true when SPY bullish but breadth/sectors low
- Title row: OPERAR HOY / PRECAUCION / NO OPERAR
- Sector header row: columns 0-1 merged for counter with dynamic bg
- bgcolor() updated to three states: green / yellow / red"
git tag dashboard/v4.0

cp "$DASHBOARD_DIR/market_dashboard_v5.pine"     "$DASHBOARD"
git add indicators/ovtlier_market_dashboard.pine
git commit -m "feat(dashboard): v5.0 — 11 sectors, alert system, full type annotations

Largest update: sector coverage expands to 11 ETFs and an alert
system is added for regime transition notifications.

- Added 4 new sectors: IGV (Software), DBA (Agricultura),
  DBC (Commodities), GLD (Metales Preciosos)
- XLE promoted to first-class sector (excluded by default via toggle)
- Added 4 new exclusion toggles (all default true)
- Table expanded from 14 to 18 rows
- maxval for minSectorsInput raised to 11
- 3 alertcondition() calls on regime transitions
- Full Pine Script v6 type annotations on all inputs and functions"
git tag dashboard/v5.0

cp "$DASHBOARD_DIR/market_dashboard_v5_1.pine"   "$DASHBOARD"
git add indicators/ovtlier_market_dashboard.pine
git commit -m "fix(dashboard): v5.1 — separate sector counter and column headers

Tendencia column header was invisible in v5 (shared merged cell
with sector counter). Resolved by splitting into two dedicated rows.

- Table expanded from 18 to 19 rows
- Row 6: sector counter spans all 4 columns (full-width merge)
- Row 7: dedicated sector column headers row
- Sector loop starts at row 8 (was row 7)
- Estado column: 3 cases: OPERAR / ESPERAR / BAJISTA"
git tag dashboard/v5.1

echo "✔ Market Dashboard committed (v1.0 -> v5.1, 9 commits, 9 tags)."

# =============================================================================
# STEP 3 — Trend Template (v1 -> v6)
# =============================================================================

TEMPLATE="$REPO_DIR/indicators/ovtlier_trend_template.pine"

echo ""
echo "▶ Committing Trend Template history..."

cp "$TEMPLATE_DIR/Ovtlier_Trend_Template_v1.pine" "$TEMPLATE"
git add indicators/ovtlier_trend_template.pine
git commit -m "feat(trend-template): v1 — initial release

8-condition Trend Template based on Minervini-Uhl methodology.

Conditions:
  C1: Price > SMA 150  C2: Price > SMA 200  C3: SMA 150 > SMA 200
  C4: SMA 200 slope up  C5: SMA 50 > SMA 150 and 200  C6: Price > SMA 50
  C7: Price >= +25% above 52w Low  C8: Price within 25% of 52w High

Added:
- 13-row table checklist with header, conditions, verdict, version footer
- SMA 50/150/200 plots on chart
- Three-state background: teal (8/8), yellow (6-7/8), red (<6/8)
- Three alertcondition() calls: Full Approval, Watch, SMA200 crossover
- SCRIPT_VERSION / SCRIPT_DATE / SCRIPT_NAME version constants
- Configurable SMA periods, 52w thresholds, table position, show/hide"
git tag trend-template/v1

cp "$TEMPLATE_DIR/Ovtlier_Trend_Template_v2.pine" "$TEMPLATE"
git add indicators/ovtlier_trend_template.pine
git commit -m "fix(trend-template): v2 — fix CE10156 and CE10123 compile errors

CE10156: multiline ternary expressions failed to parse without line
continuation markers. Added backslash continuation on all multiline
ternaries in bgColor and tablePos() function.

CE10123: alertcondition() requires const string message.
- Replaced dynamic alertcondition() messages with alert() calls
- Retained static alertcondition() for TradingView alert panel"
git tag trend-template/v2

cp "$TEMPLATE_DIR/Ovtlier_Trend_Template_v3.pine" "$TEMPLATE"
git add indicators/ovtlier_trend_template.pine
git commit -m "fix(trend-template): v3 — high-contrast solid table backgrounds

All table cell backgrounds changed from semitransparent to fully
opaque solid colors for maximum readability on all chart themes.

Note: original file saved as v3 contains SCRIPT_VERSION = 'v4'
internally due to a save naming error. Code is identical to what
was labeled v4 at the time.

- Condition rows: color.new(color.black, 75) -> solid #1a1a2e (navy)
- PASS: color.teal opacity 10 -> solid color.teal
- FAIL: color.red opacity 10 -> solid color.red
- Verdict: teal/orange/maroon fully opaque
- Footer: color.silver text on solid #1a1a1a background"
git tag trend-template/v3

cp "$TEMPLATE_DIR/Ovtlier_Trend_Template_v4.pine" "$TEMPLATE"
git add indicators/ovtlier_trend_template.pine
git commit --allow-empty -m "refactor(trend-template): v4 — same as v3 codebase, explicit version tag

This commit aligns the repository tag with the SCRIPT_VERSION constant
embedded in the code (v4). File Ovtlier_Trend_Template_v4.pine is
identical in logic to v3.pine due to a file naming error during
development. Tag trend-template/v4 added for traceability."
git tag trend-template/v4

cp "$TEMPLATE_DIR/Ovtlier_Trend_Template_v5.pine" "$TEMPLATE"
git add indicators/ovtlier_trend_template.pine
git commit -m "feat(trend-template): v5 — integrate Step 4 checks as C9, C10, C11

Manual verification steps previously done outside the indicator
are now integrated directly in the table.

C9 — Overextension (fully automatic):
  dist(price, SMA50) / ATR(14) < atrMaxMult (default 2.5)
  Shown dynamically: C9 Overext. 1.18 ATR (max 2.5)

C10 — Resistance zone (semi-automatic proxy):
  Scans last 60 bars for candle highs in band [close, close + 2xATR]
  Orange band plotted on chart between 1xATR and 2xATR above price.

C11 — Earnings window (manual input):
  earningsDays > 21. Default 99 (always PASS on load).

Table expanded from 13 to 17 rows.
Step 4 section header added between C8 and C9."
git tag trend-template/v5

cp "$TEMPLATE_DIR/Ovtlier_Trend_Template_v6.pine" "$TEMPLATE"
git add indicators/ovtlier_trend_template.pine
git commit -m "fix(trend-template): v6 — fix CE10095 duplicate variable declaration

CE10095: same variable name declared twice in the same scope.
The plots block in v5 re-declared atr14, resistZoneTop and
resistZoneBottom which already existed in the conditions block.

- Removed duplicate declarations in the plots block
- p1 now plots resistanceTop (from conditions block)
- p2 now plots resistanceBottom + atr14 (reuses existing variables)
- Logic and visual output identical to v5"
git tag trend-template/v6

echo "✔ Trend Template committed (v1 -> v6, 6 commits, 7 tags)."

# =============================================================================
# STEP 4 — Position Sizer (v1 -> v4)
# =============================================================================

SIZER="$REPO_DIR/indicators/outlier_position_sizer.pine"

echo ""
echo "▶ Committing Position Sizer history..."

cp "$SIZER_DIR/outlier_position_sizer_v1.pine" "$SIZER"
git add indicators/outlier_position_sizer.pine
git commit -m "feat(position-sizer): v1 — initial release

ATR-based position sizing implementing the Uhl/Height formula.

Formula:
  Dollar risk = Balance x (Risk% / 100)
  Stop dist   = ATR(14) x Multiplier
  Shares      = floor(Dollar risk / Stop dist)
  Contracts   = floor(Shares / 100 / Delta)  [options mode]

Added:
- 7-row table: header, dollar risk, ATR, stop price,
  shares/contracts, capital used, status alert
- Dynamic stop-loss line plotted on chart (red dashed)
- Two status alerts: risk > 2%, capital concentration > 30%
- calcDollarRisk(), calcStopDistance(), calcShares() functions"
git tag position-sizer/v1

cp "$SIZER_DIR/outlier_position_sizer_v2.pine" "$SIZER"
git add indicators/outlier_position_sizer.pine
git commit -m "feat(position-sizer): v2 — movable table, dark palette, blank cell fix

Added:
- 9-position table placement input (Top/Middle/Bottom x Left/Center/Right)
- tablePosition() helper using switch statement
- table.set_position() for dynamic repositioning without reload
- Visual separator row between header and data rows
- Third status alert: Stop = 0, revisar ATR when rawShares == 0

Fixed:
- Blank cells caused by computing display strings inside
  if barstate.islast. All strings now pre-computed at global scope.

Changed:
- Dark navy color palette replacing default colors"
git tag position-sizer/v2

cp "$SIZER_DIR/outlier_position_sizer_v3.pine" "$SIZER"
git add indicators/outlier_position_sizer.pine
git commit -m "refactor(position-sizer): v3 — maximum contrast color scheme

Pure visual update, no changes to formula, inputs, or outputs.

- Background darkened: #0d1117 -> #080c12
- Labels: #8899aa -> #c8d8e8 (bright blue-white, high contrast)
- Values: #e0e8f0 -> #ffffff (pure white)
- Teal accent: #00c9a7 -> #00ffcc (bright)
- Red stop loss: #ff4d6d -> #ff3355 (vivid)
- Frame width increased from 1 to 2"
git tag position-sizer/v3

cp "$SIZER_DIR/outlier_position_sizer_v4.pine" "$SIZER"
git add indicators/outlier_position_sizer.pine
git commit -m "refactor(position-sizer): v4 — legible separator row and status row bg

Pure visual update, formula and outputs unchanged.

Separator row (row 1):
  Before: near-black bg, invisible dark text
  After:  medium blue bg (#102040), readable light blue text (#7fb8e8)
  Label:  Parametros de riesgo in uppercase

Status row (row 7) conditional background:
  Alert active -> dark red bg (#2a0010)
  All OK       -> dark green bg (#002a1a)

Label column: lightened from #c8d8e8 to #ddeeff"
git tag position-sizer/v4

echo "✔ Position Sizer committed (v1 -> v4, 4 commits, 4 tags)."

# =============================================================================
# STEP 5 — README version evolution (empty commits for doc history)
# =============================================================================

echo ""
echo "▶ Committing README version evolution..."

git commit --allow-empty -m "docs(readme): v1 -> v2 — expand system reference to three indicators

System documentation updated from v1 (Market Dashboard only) to v2
(full three-indicator pipeline).

v2 additions:
- Part 2: Trend Template v4 — 8-condition checklist, SMA rationale,
  three-state verdict, visual elements, configurable parameters
- Part 3: Position Sizer v3 — ATR formula, six table outputs,
  internal status alerts, risk scaling table by experience
- Part 4: complete decision flow diagram (all three indicators)
- Part 5: full worked example with NVDA (20k account, 1% risk)"

git commit --allow-empty -m "docs(readme): v2 -> v3 — update for Trend Template v6 and Sizer v4

System documentation updated to v3 reflecting latest indicator versions.

v3 changes:
- Trend Template updated to v6: C9/C10/C11 now part of the table
- Position Sizer updated to v4: separator and status row bg changes
- Decision flow updated: Step 4 block shows C9/C10/C11 explicitly
- NVDA example updated with C11 earnings, C9 ATR ratio, C10 band"

echo "✔ README version evolution committed."

# =============================================================================
# STEP 6 — Push to GitHub
# =============================================================================

echo ""
echo "▶ Adding remote and pushing to GitHub..."

git remote add origin "$REMOTE_URL"
git push -u origin main --tags

echo ""
echo "================================================================"
echo "✔ Repository setup complete."
echo ""
echo "  Local path : $REPO_DIR"
echo "  Remote     : $REMOTE_URL"
echo "  User       : $GIT_USER <$GIT_EMAIL>"
echo ""
echo "  Total commits : $(git log --oneline | wc -l | tr -d ' ')"
echo ""
echo "  Tags by indicator:"
echo "    dashboard/      : $(git tag | grep '^dashboard/'      | wc -l | tr -d ' ') tags (v1.0 -> v5.1)"
echo "    trend-template/ : $(git tag | grep '^trend-template/' | wc -l | tr -d ' ') tags (v1 -> v6)"
echo "    position-sizer/ : $(git tag | grep '^position-sizer/' | wc -l | tr -d ' ') tags (v1 -> v4)"
echo "================================================================"
