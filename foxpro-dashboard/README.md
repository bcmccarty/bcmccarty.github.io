# Wilson Combat Product Performance Dashboard

A Visual FoxPro program demonstrating DBF database operations, SQL analytics, and CSV export for a premium firearms manufacturer's inventory management system.

## Overview

This project creates a complete business intelligence dashboard for a hypothetical Wilson Combat (premium 1911 pistol and AR-15 manufacturer) inventory and sales system. It serves as both a functional demo and a teaching example for Visual FoxPro database programming.

## Features

### Database Tables

The program creates and populates four DBF tables:

| Table | Description |
|-------|-------------|
| `PRODUCTS.DBF` | Master product catalog (SKU, description, category, cost, MSRP, weight) |
| `INVENTORY.DBF` | Stock levels by warehouse location |
| `ORDERS.DBF` | Order headers with customer and status information |
| `ORDERLINE.DBF` | Order line items with quantities and pricing |

### Sample Data

- **75+ realistic SKUs** covering:
  - 1911 Pistols (CQB, EDC, Supergrade, Combat Elite series)
  - AR-15 Rifles (complete rifles, uppers, lowers)
  - Shotguns (tactical and sporting)
  - Magazines (1911 and AR-15)
  - Parts (triggers, hammers, sights, grips, springs)
  - Accessories (cases, tools, holsters, apparel)

- **Realistic pricing** based on actual premium firearms market:
  - 1911 Pistols: $2,895 - $4,695
  - AR-15 Rifles: $1,995 - $3,195
  - Magazines: $22.95 - $64.95
  - Small parts: $8.95 - $139.95

- **850 orders** with 1-6 line items each
- **3 warehouse locations** with varying inventory levels
- Includes realistic backorder and dead stock scenarios

### Analytics Reports

1. **Gross Margin Analysis by Category**
   - Revenue, cost, and profit by product category
   - Margin percentage calculations

2. **Inventory Valuation & Weeks of Supply**
   - Total inventory at cost and retail
   - Committed vs. available inventory
   - Weeks of supply based on sales velocity

3. **Top 10 SKUs by Revenue**
   - Best-selling products ranked by total revenue
   - Units sold, profit, and margin for each

4. **Dead Stock Report**
   - Products with no sales in 90+ days
   - Inventory value at risk

5. **Backorder Exposure**
   - SKUs where committed quantity exceeds on-hand
   - Revenue at risk from unfulfilled orders

### CSV Exports

All reports are automatically exported to CSV files:
- `GrossMarginByCategory.csv`
- `InventoryValuation.csv`
- `TopSkusByRevenue.csv`
- `DeadStockReport.csv`
- `BackorderExposure.csv`

## Usage

### Requirements

- Visual FoxPro 6.0 or later (VFP 9.0 recommended)
- Windows OS (or compatible environment)

### Running the Program

1. Open Visual FoxPro
2. Navigate to the `foxpro-dashboard` directory
3. Execute the program:

```foxpro
DO WilsonCombatDashboard.prg
```

The program will:
1. Create a `DATA` subdirectory
2. Generate all database tables with sample data
3. Run all analytics queries
4. Display results on screen
5. Export CSV files to the DATA directory

## Code Structure

The program is organized into clear procedures:

```
WilsonCombatDashboard.prg
├── Main Program (setup and execution flow)
├── CreateTables - DDL for all database tables
├── PopulateProducts - 75+ product catalog entries
├── PopulateInventory - Multi-warehouse stock levels
├── PopulateOrders - 6 months of order history
├── PopulateOrderLines - Order line items
├── RunGrossMarginAnalysis - Margin by category
├── RunInventoryValuation - Stock value and weeks of supply
├── RunTopSkusByRevenue - Best sellers
├── RunDeadStockReport - No-sale items
└── RunBackorderExposure - Oversold inventory
```

## Sample SKU Patterns

The SKU naming convention follows a logical pattern:

| Pattern | Example | Description |
|---------|---------|-------------|
| `CQB-FS-45` | CQB Full-Size .45 | Series-Size-Caliber |
| `EDC-X9-9MM` | EDC X9 9mm | Series-Model-Caliber |
| `AR15-UPPER-556` | AR-15 Upper 5.56 | Platform-Component-Caliber |
| `MAG-1911-45-8` | 1911 Magazine .45 8rd | Type-Platform-Caliber-Capacity |
| `TRG-1911-ULT` | Ultralight Trigger | Type-Platform-Model |
| `GRP-1911-G10-BK` | G10 Grips Black | Type-Platform-Material-Color |

## Teaching Notes

This program demonstrates several Visual FoxPro best practices:

1. **Proper SET commands** for production code
2. **CREATE TABLE with field constraints**
3. **Index creation** for query optimization
4. **TEXT...ENDTEXT blocks** for readable SQL
5. **Cursor-based query results** (INTO CURSOR)
6. **Parameterized queries** using `?variable` syntax
7. **LEFT/INNER JOIN** for relational queries
8. **Aggregate functions** (SUM, COUNT, MAX, AVG)
9. **NVL/IIF for NULL handling**
10. **COPY TO CSV** for data export

## License

This is a demonstration/teaching example. Use freely for educational purposes.
