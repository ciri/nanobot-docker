# Capitalism Lab Save File Reverse Engineering

## Project Structure Convention

```
/dev   → binary exploration, diffing, struct inference
/viz   → visualization of world, firms, corporations
/ds    → dashboards and derived metrics
```

---

## 1. Core Principle (Non‑Negotiable)

**The save file stores physical economic state, not accounting reports.**

* Balance sheets are NOT stored
* Income statements are NOT stored
* Reports are recomputed on load
* Save = snapshot of reality, not summaries

If something appears in a report, it is derived. If it affects the simulation, it is stored.

---

## 2. Global Architecture (Mental Model)

The save is a layered state dump:

```
[ World / Corporation Layer ]
[ Firm Array Layer          ]  ← dominant bulk
[ Unit / Sub‑entity Layer   ]
[ Assets / Metadata         ]
```

No pointer graphs in the C sense. Mostly flat arrays and indices.

---

## 3. Time Model

* No explicit year/month fields
* Time stored as a monotonic counter (ticks or months since start)
* Calendar dates are derived at runtime

Implication: detect time via deltas, not timestamps.

---

## 4. Corporation Layer (Small, Global)

Stores **financial primitives only**.

### Stored

* Cash
* Bank loans
* Shares outstanding
* Stock holdings
* Global flags (difficulty, economy mode)

### Not Stored

* Corporate income statement
* Corporate balance sheet
* Period aggregates

Corporation accounting is always:

```
corporation = sum(firms) + corp primitives
```

---

## 5. Firm Layer (Primary Decoding Target)

The save contains a **flat array of firm structs**:

```
Firm[0]
Firm[1]
Firm[2]
...
Firm[N]
```

### Structural Properties

* Fixed‑size records
* Numeric only (no strings)
* Little‑endian
* Dense int32‑heavy layout

A **firm is the smallest profit‑generating entity**.

---

## 6. Firm Logical Contents (Semantics, Not Offsets)

### Identity / Classification

* firm_id
* firm_type (retail, factory, farm, mine, media, HQ, etc.)
* owner_corp_id
* city_id

### Physical State

* employee count
* capacity
* utilization
* building value
* land / resource value

### Monthly Flows (Critical)

* monthly_revenue
* monthly_operating_cost
* monthly_profit (may be explicit or derived)

These fields change every month and drive all income statements.

### Lifetime Accumulators

* lifetime_revenue
* lifetime_profit
* years_operated

Monotonic increasing.

---

## 7. Unit / Sub‑Entity Layer

Units represent **processes**, not accounting.

Examples:

* Sales units
* Purchasing units
* Inventory units
* Manufacturing units
* Advertising units
* R&D units

### Units Store

* quantities
* utilization
* throughput
* inventory counts
* training / level

### Units Do NOT Store

* profit directly
* accounting totals

Flow is always:

```
units → firm → corporation
```

---

## 8. Retail vs Manufacturing (Structural Distinction)

### Retail Firms

* Sales units present
* Purchasing units present
* Inventory units present
* Advertising spend nearby
* No production throughput

### Manufacturing Firms

* Manufacturing units present
* Raw‑material inflows
* Production speed fields
* Technology level fields
* Often inventory buffers

Classification is **pattern‑based**, not semantic.

---

## 9. Income Statement Logic (Derived)

Computed on load:

```
for firm in firms:
    revenue = firm.monthly_revenue
    cost    = firm.monthly_operating_cost
    profit  = revenue - cost

corp.revenue = sum(firm.revenue)
corp.cost    = sum(firm.cost)
corp.profit  = sum(firm.profit)
```

Only monthly flows and lifetime accumulators exist in the save.

---

## 10. Balance Sheet Logic (Derived)

Computed on load:

```
Assets =
    cash
  + inventory_value
  + building_value
  + land/resources
  + stock_assets

Liabilities = bank_loans
Equity = Assets - Liabilities
```

Notes:

* Inventory stored as quantities, not values
* Valuation applied dynamically

---

## 11. What Is Explicitly NOT in the Save

* Balance sheets
* Income statements
* Report tables
* Product economics
* Demand curves
* Calibration constants

Those live in game data, not save files.

---

## 12. Decoding Strategy for `/dev`

### Mandatory Order

1. Identify firm struct size (stride detection)
2. Index firm array
3. Classify fields by volatility:

   * static
   * monthly flow
   * lifetime accumulator
4. Detect unit substructures
5. Map firm → corporation aggregation

### Core Technique

* Diff saves across time
* Observe what moves together
* Assign semantics last

---

## 13. Visualization Targets (`/viz`)

* Firms as nodes
* Cities as clusters
* Corporation ownership graphs
* Revenue / cost / profit heatmaps

---

## 14. Dashboard Targets (`/ds`)

All dashboards are derived:

* Corporate income statement
* Corporate balance sheet
* Firm rankings
* City‑level aggregates
* Industry composition

---

## 15. Invariant (Pin This)

**If a value appears in a report, it is computed. If it affects reality, it is stored.**
