# Draft Findings & Material Inventory (Day 6 Block 1)

This inventory collects all empirical findings, evidence sources, interpretations, and business implications derived across Days 1 through 5 (`notebooks/01_data_understanding.ipynb` to `05_sql_analysis.ipynb`, `sql/01_basis_analysis.sql`, and `reports/figures/`).

---

## 1. Data Understanding & Profiling

### Finding 1: Massive Raw Transaction Volume with Non-Uniform Customer Tracking
- **Evidence:** `notebooks/01_data_understanding.ipynb`, shape (541,909, 8), date range 2010-12-01 08:26:00 to 2011-12-09 12:50:00 (373 days). `CustomerID` is null for 135,080 rows (24.93%).
- **Interpretation:** Approximately a quarter of transactions were placed by guest/unregistered checkouts or aggregated bulk channel sales without persistent user accounts.
- **Implication:** Customer-level lifetime value and segmentation must explicitly isolate the 406,829 identified rows (4,372 distinct customers) from guest checkouts to prevent understating customer retention or overestimating churn.

### Finding 2: High Presence of Cancellations, Returns, and Negative Values
- **Evidence:** 9,288 transactions (~1.71%) begin with the invoice prefix 'C'. 10,624 line items have negative quantities (min: -80,995), and 2,517 records have `UnitPrice <= 0` (including system corrections, sample distributions, and Amazon fee adjustments).
- **Interpretation:** Cancellations and inventory write-offs exist in the transactional ledger alongside standard purchases. 1,336 negative quantity rows lacked the 'C' prefix, indicating unlabelled stock adjustments.
- **Business Implication:** Financial analysis must strictly differentiate Gross Revenue (£10,644,560.42 across valid sales) from Net Revenue (£9,747,747.93 reflecting returns and adjustments).

---

## 2. Data Cleaning Decisions Log

### Actions Taken:
1. **Invoice Number & Cancellation Flag:** Converted `InvoiceNo` to string and extracted `IsCancelled = InvoiceNo.startswith('C')`.
2. **Missing Description Imputation:** Filled 1,454 missing text descriptions with `"Missing_Description"` rather than dropping rows, preserving transaction amounts.
3. **CustomerID Normalization:** Cast `CustomerID` from float to string, stripped trailing `".0"`, and standardized null representations to `"Null"` for guest checkout tracking without loss of transaction revenue.
4. **Negative Quantities & Administrative Fees Identified:** Segregated non-product administrative stock codes (`POST`, `DOT`, `M`, `D`, `CRUK`, `BANK CHARGES`) to avoid skewing physical product inventory counts.
5. **Temporal Feature Extraction:** Generated `Year`, `Month`, `Day`, `Hour`, `DayOfWeek` from `InvoiceDate`.
6. **Financial Metrics:** Calculated item-level `Revenue = Quantity * UnitPrice`. Saved clean dataset to `data/processed/online_retail_clean.csv` (541,909 rows, 15 columns).

---

## 3. Revenue Analysis & Seasonality

### Finding 1: Extreme Fourth-Quarter Seasonality with November Climax
- **Evidence:** `reports/figures/01_monthly_revenue_trend.png`; SQL Query Q6. Gross monthly revenue surged from £737,014 in August 2011 to £1,058,590 in September (+43.6% MoM), £1,154,979 in October (+9.1% MoM), and peaked at £1,509,496 in November 2011 (+30.7% MoM). November accounts for 14.18% of total gross annual revenue (15.00% of net revenue).
- **Interpretation:** The business sells gifts, seasonal decorations, and novelty homeware, resulting in intense holiday/Christmas pre-season purchasing from both wholesale retailers and end-consumers stocking up in Q4.
- **Business Implication:** Supply chain, supplier purchase orders, and warehouse staffing must ramp aggressively starting in July/August. Cash flow management must prepare for lean early Q1 months (Jan-Feb).

### Finding 2: Incomplete December Truncation
- **Evidence:** December 2011 recorded £638,793 gross revenue across only 9 operational days (through Dec 9), down 57.7% MoM compared to full November.
- **Interpretation:** The apparent crash in December revenue is an artifact of dataset cutoff on December 9th, rather than a collapse in customer demand. In fact, daily run-rate in early December remained elevated (£70,977/day vs £50,316/day in November).
- **Business Implication:** Annual forecasting must annualize December's run rate or benchmark against December 2010 (£823,746) to prevent distorted predictive models.

---

## 4. Product Portfolio & Operational Performance

### Finding 1: Bimodal Product Catalog: Everyday Novelties vs. Outlier Bulk Wholesales
- **Evidence:** `reports/figures/03_top_products_by_revenue.png`, `04_top_products_quantity.png`; SQL Query Q3 & Q11. Top revenue drivers: `DOTCOM POSTAGE` (£206,249), `REGENCY CAKESTAND 3 TIER` (£174,485), `PAPER CRAFT , LITTLE BIRDIE` (£168,470), `WHITE HANGING HEART T-LIGHT HOLDER` (£106,293). Top quantity sellers: `PAPER CRAFT , LITTLE BIRDIE` (80,995 units), `MEDIUM CERAMIC TOP STORAGE JAR` (78,033 units), `WORLD WAR 2 GLIDERS ASSTD DESIGNS` (55,047 units).
- **Interpretation:** Certain SKUs (like `PAPER CRAFT` and `CERAMIC STORAGE JAR`) achieved top revenue via isolated single-transaction massive wholesale orders (80,995 units sold in single invoice 581483), whereas `REGENCY CAKESTAND` and `WHITE HANGING HEART` are consistent, high-velocity recurring retail bestsellers.
- **Business Implication:** Inventory replenishment policies should separate steady-state core retail lines from volatile high-volume institutional wholesale runs.

### Finding 2: Highly Skewed Order Values Dominated by Mid-Tier Baskets
- **Evidence:** `reports/figures/05_order_value_distribution.png`; SQL Query Q7. Mean AOV is £482.44, whereas median AOV is £272.61 (skewness = 52.74). 75% of orders are under £460.45; the top 5% exceed £1,485.28, reaching a maximum order of £168,469.60.
- **Interpretation:** The store operates as a hybrid B2B/B2C marketplace. While standard retail shoppers purchase baskets between £100 and £400, commercial buyers place multi-thousand pound purchase orders.
- **Business Implication:** Checkout financing, bulk-tier volume discounting, and specialized trade-account credit terms could capture higher margin from wholesale buyers without alienating retail shoppers.

### Finding 3: Midday E-Commerce Purchasing Concentration
- **Evidence:** `reports/figures/06_orders_by_hour_of_day.png`. 63.5% of all orders occur between 10:00 and 14:00, peaking at 12:00 (15.70% of daily transactions). Operations cease completely between 20:00 and 06:00.
- **Interpretation:** Peak buying coincides with lunch hours and commercial business operating hours in the UK and European time zones.
- **Business Implication:** Flash sales, promotional marketing emails, and customer support staffing should be synchronized between 10:00 and 13:00 GMT for optimal conversion.

---

## 5. Customer Dynamics & Segmentation (RFM)

### Finding 1: Extreme Pareto Spend Concentration Among Top 10%
- **Evidence:** `reports/figures/revenue_concentration.png`; SQL Queries Q8 & Q9. Top 1% of customers (44 accounts) account for 29.92% of spend; Top 5% (219 accounts) drive 48.59%; Top 10% (438 accounts) drive 60.05% of spend. Top 10 customers alone account for £1,369,182 (16.50% of customer spend).
- **Interpretation:** The business carries high key-account dependency. The loss of a handful of top accounts (e.g., Customer 14646 with £279.5k or 18102 with £256.4k) would materially impact total annual profits.
- **Business Implication:** Dedicated B2B key-account management, VIP tier benefits, and contracted fulfillment SLA guarantees are required for the top 5% of customer accounts.

### Finding 2: High Repeat Buyer Stability Alongside 30% One-Time Churn
- **Evidence:** `reports/figures/orders_per_customer.png`; SQL Query Q14. 30.03% (1,313 customers) purchased only once; 69.97% (3,059 customers) are repeat purchasers (averaging 5.08 orders, max 248 orders).
- **Interpretation:** Compared to typical B2C e-commerce benchmarks (where one-time buyers frequently exceed 60-70%), a 70% repeat purchase rate is exceptionally strong, affirming solid product-market fit.
- **Business Implication:** First-to-second order conversion represents the largest immediate expansion lever. Onboarding welcome drip campaigns and immediate second-order incentives can harvest substantial lifetime value.

### Finding 3: RFM Customer Segment Breakdown
- **Evidence:** `notebooks/04_customer_analysis.ipynb`, Cell 20.
  - **Champions:** 964 customers (22.0%), generating £5,620,812.18 (67.7% of customer revenue). High recency, high frequency, high monetary.
  - **Regulars:** 970 customers (22.2%), generating £1,231,429.63 (14.8% of customer revenue). Steady purchasing, moderate spend.
  - **At Risk:** 689 customers (15.8%), generating £756,019.58 (9.1% of customer revenue). Previously high-value accounts that haven't purchased recently.
  - **Lost:** 1,060 customers (24.2%), generating £398,791.57 (4.8% of customer revenue). High dormancy, low lifetime spend.
  - **New Customers:** 689 customers (15.8%), generating £293,012.85 (3.5% of customer revenue). Recent first-time purchasers.
- **Interpretation:** Two-thirds of customer revenue is locked in the Champions cohort. At Risk accounts represent over £756k in historical revenue at imminent danger of permanent attrition.
- **Business Implication:** Priority 1 is safeguarding Champions; Priority 2 is proactive win-back re-engagement targeting At Risk customers before they slip into the Lost segment.

---

## 6. Geographic Distribution

### Finding 1: Heavy Domestic UK Concentration
- **Evidence:** `reports/figures/02_top_countries_by_revenue.png`; SQL Query Q4 & Q10. United Kingdom accounts for £8,187,806.36 net revenue (84.00% of total net) and £9,003,098 gross revenue (84.58% of total gross).
- **Interpretation:** The business remains predominantly domestic UK-centric, leaving it vulnerable to UK macroeconomic shocks and post-Brexit supply friction.
- **Business Implication:** Expanding marketing investment in Western European neighboring markets represents a viable de-risking and growth strategy.

### Finding 2: Established Footprints in High-Affluence European Hubs
- **Evidence:** Top export markets: Netherlands (£284.7k net / 2.92%), EIRE (£263.3k net / 2.70%), Germany (£221.7k net / 2.27%), France (£197.4k net / 2.03%), Australia (£137.1k net / 1.41%). Q11 demonstrates that while UK demand is broad, European markets order localized high-margin products (e.g. `POSTAGE`, `RABBIT NIGHT LIGHT`, `ROUND SNACK BOXES SET OF 4 WOODLAND`).
- **Interpretation:** International customers exhibit higher average basket values and repeat wholesale order characteristics to amortize cross-border freight costs.
- **Business Implication:** Localized European fulfillment nodes (e.g., in Netherlands or Germany) and transparent localized shipping tiers would accelerate cross-border conversion.
