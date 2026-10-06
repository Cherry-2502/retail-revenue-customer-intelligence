# E-Commerce Sales & Customer Analytics

[![Python](https://img.shields.io/badge/Python-3.14-blue.svg?logo=python&logoColor=white)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791.svg?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Pandas](https://img.shields.io/badge/Pandas-3.0-150458.svg?logo=pandas&logoColor=white)](https://pandas.pydata.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An end-to-end commercial analytics investigation of **541,909 UK-based online retail transactions** (£10.64M gross / £9.75M net revenue across Dec 2010–Dec 2011) using **Python, PostgreSQL, and Jupyter Notebooks** to diagnose sales trends, customer behavior, product mix, and geographic concentration.

---

## Executive Summary

- **Total Volume & Revenue:** Analyzed **541,909 raw transactions** across 373 days, representing **£10,644,560.42** in gross revenue and **£9,747,747.93** in net revenue across **22,064 gross orders**.
- **Extreme Q4 Seasonality:** Monthly revenue climbed **+104.8%** from August (£737k) to a November peak of **£1,509,496.33** gross (14.18% of annual sales), driven by holiday gift stocking. Early December was tracking at a record run-rate of **£70,977/day** prior to dataset cutoff on December 9.
- **Severe Pareto Concentration:** The **top 10% of customers generate 60.05% of customer spend** (£4.98M of £8.30M identified spend), and the top 10 individual wholesale accounts alone account for **16.50%** (£1.37M).
- **Strong Repeat Loyalty vs. 30% First-Order Churn:** **69.97%** of customers are repeat buyers (averaging 5.08 orders per customer), while **30.03%** (1,313 accounts) transacted only once, highlighting a prime conversion opportunity.
- **RFM Segmentation Matrix:** An elite **"Champions" cohort (22.05% of accounts) generates 67.72% of customer spend** (£5.62M). Concurrently, **689 "At Risk" accounts** represent **£756k (9.11%)** in imminent danger of permanent attrition.
- **Geographic Vulnerability:** The enterprise is **84.00% dependent on the UK market** (£8.19M net), with leading export destinations in the Netherlands (£285k), EIRE (£263k), Germany (£222k), and France (£197k).

---

## Business Problem

Management posed four core operational questions:
1. **Sales & Seasonality:** When do sales peak, what drives monthly volatility, and how should inventory and warehouse capacity scale?
2. **Customer Dynamics:** Who are our most valuable customers, how loyal is our customer base, and where is customer attrition occurring?
3. **Product Performance:** Which products drive genuine recurring volume versus one-off wholesale spikes, and how do basket sizes vary?
4. **Market Expansion:** How concentrated is revenue geographically, and what operational barriers hinder international European expansion?

---

## Dataset Overview

- **Source:** [UCI Machine Learning Repository — Online Retail Dataset (ID 352)](https://archive.ics.uci.edu/dataset/352/online%2Bretail)
- **Coverage:** December 1, 2010 08:26:00 to December 9, 2011 12:50:00 (373 calendar days)
- **Records:** 541,909 transactions across 8 attributes
- **Key Attributes:**
  - `InvoiceNo`: 6-digit transaction identifier (prefix `'C'` denotes cancellation)
  - `StockCode`: 5-digit product SKU or administrative charge code
  - `Description`: Product name (1,454 missing records, ~0.27%)
  - `Quantity`: Units per line item (ranges from -80,995 to +80,995; 10,624 negative values)
  - `InvoiceDate`: Timestamp of transaction
  - `UnitPrice`: Product price in GBP (£) (2,517 non-positive price records)
  - `CustomerID`: 5-digit customer identifier (135,080 missing values, ~24.93%)
  - `Country`: Customer domicile country (38 distinct nations)

---

## Tech Stack & Architecture

- **Data Processing & Feature Engineering:** Python 3.14, Pandas, NumPy
- **Exploratory Data Analysis & Visualization:** Matplotlib, Seaborn
- **Database & Query Layer:** PostgreSQL 16, SQLAlchemy 2.0, Psycopg2
- **Environment & Notebooks:** JupyterLab, Virtual Environment (`venv`)
- **Version Control:** Git, GitHub

---

## Repository Structure

```text
ecommerce-sales-analytics/
├── data/
│   ├── raw/                           # Raw Excel ledger (excluded from git tracking)
│   │   └── Online Retail.xlsx
│   ├── processed/                     # Cleaned, standardized datasets
│   │   ├── online_retail_clean.csv    # Master cleaned transactional table (541,909 rows)
│   │   └── customer_summary.csv       # Customer-level metrics & RFM aggregates (4,372 rows)
│   └── docs/                          # Data cleaning documentation
│       └── Progress.md
├── notebooks/                         # Ordered Jupyter analysis notebooks
│   ├── 01_data_understanding.ipynb    # Data profiling & initial inspection
│   ├── 02_data_cleaning.ipynb         # Data transformation & feature engineering pipeline
│   ├── 03_exploratory_analysis.ipynb  # Core visualizations & distribution analysis
│   ├── 04_customer_analysis.ipynb     # Customer metrics, RFM segmentation & Pareto analysis
│   └── 05_sql_analysis.ipynb          # PostgreSQL database connection & query execution
├── sql/                               # Production SQL queries
│   ├── 01_basic_analysis.sql          # Aggregate sums, counts, group-bys (Q1–Q5)
│   ├── 02_intermediate_analysis.sql   # Time-series, subqueries, AOV, shares (Q6–Q10)
│   └── 03_advanced_analysis.sql       # CTEs, window functions (RANK, LAG, NTILE) (Q11–Q15)
├── reports/                           # Final business deliverables
│   ├── analysis_summary.md            # Comprehensive 11-section executive report
│   ├── draft_findings.md              # Material inventory & empirical finding log
│   └── figures/                       # Publication-quality generated figures
│       ├── 01_monthly_revenue_trend.png
│       ├── 02_top_countries_by_revenue.png
│       ├── 03_top_products_by_revenue.png
│       ├── 04_top_products_quantity.png
│       ├── 05_order_value_distribution.png
│       ├── 06_orders_by_hour_of_day.png
│       ├── orders_per_customer.png
│       └── revenue_concentration.png
├── .gitignore                         # Complete environment & file exclusion rules
├── LICENSE                            # MIT Open Source License
├── README.md                          # Project documentation (this file)
└── requirements.txt                   # Reproducible Python dependencies
```

---

## Data Cleaning & Transformation Pipeline

All cleaning decisions were systematically evaluated and logged in `notebooks/02_data_cleaning.ipynb`:
1. **Cancellation Tracking:** Extracted boolean flag `IsCancelled = InvoiceNo.startswith('C')`. Exactly 9,288 transactions were confirmed cancellations.
2. **Missing Description Imputation:** Filled 1,454 missing descriptions with `"Missing_Description"`, preserving transaction amounts for financial summaries.
3. **CustomerID Standardization:** Converted identifiers from float to string, stripped trailing decimal representations (`r'\.0$'`), and mapped missing representations to `"Null"`. Guest checkouts (~24.9%) were retained for overall store revenue but isolated from customer RFM cohorts.
4. **Revenue Engineering:** Derived `Revenue = Quantity × UnitPrice`. Positive quantities represent gross revenue; negative quantities reflect return deductions for net revenue calculations.
5. **Temporal Decomposition:** Extracted `Year`, `Month`, `Day`, `Hour`, and `DayOfWeek` from `InvoiceDate`.
6. **Administrative Code Filtering:** Segregated non-merchandise fees (`POST`, `DOT`, `M`, `D`, `CRUK`, `BANK CHARGES`) from product sales rankings.

---

## Key Analysis & Visual Insights

### 1. Revenue Trends & Seasonality
![Monthly Revenue Trend](reports/figures/01_monthly_revenue_trend.png)

- **Q4 Holiday Ramp:** Gross monthly revenue expanded steadily from £523k in February to £1.06M in September (+43.6% MoM), £1.15M in October (+9.1% MoM), and peaked at **£1,509,496.33 in November (+30.7% MoM)**.
- **December Truncation:** December 2011 generated £638,793 across only 9 operational days (through Dec 9). The apparent 57.7% MoM decline is an artifact of dataset cutoff; daily run-rate remained higher than November (£70,977/day vs £50,317/day).

---

### 2. Customer Concentration & RFM Segmentation
![Revenue Concentration](reports/figures/revenue_concentration.png)
![Orders per Customer](reports/figures/orders_per_customer.png)

- **Extreme Pareto Inequality:** 
  - **Top 1%** (44 customers) generate **29.92%** of spend (£2.48M).
  - **Top 5%** (219 customers) generate **48.59%** of spend (£4.03M).
  - **Top 10%** (438 customers) generate **60.05%** of spend (£4.98M).
- **High Retention Core:** 69.97% (3,059 customers) are repeat purchasers, averaging 5.08 orders per account. 30.03% (1,313 customers) transacted only once.

#### RFM Segmentation Breakdown (Quintile Scoring, Snapshot: 2011-12-09)
| Segment | Customer Count | % Customers | Revenue Contribution (£) | % Revenue | Avg Spend / Customer (£) |
|---|---|---|---|---|---|
| **Champions** | 964 | 22.05% | £5,620,812.18 | 67.72% | £5,830.72 |
| **Regulars** | 970 | 22.19% | £1,231,429.63 | 14.84% | £1,269.52 |
| **At Risk** | 689 | 15.76% | £756,019.58 | 9.11% | £1,097.27 |
| **Lost** | 1,060 | 24.25% | £398,791.57 | 4.80% | £376.22 |
| **New Customers** | 689 | 15.76% | £293,012.85 | 3.53% | £425.27 |
| **Total** | **4,372** | **100.00%** | **£8,300,065.81** | **100.00%** | **£1,898.46** |

---

### 3. Product Catalog Dynamics
![Top 10 Products by Revenue](reports/figures/03_top_products_by_revenue.png)
![Top 10 Products by Quantity](reports/figures/04_top_products_quantity.png)

- **Consistent Bestsellers vs Outliers:** True recurring merchandise anchors are `REGENCY CAKESTAND 3 TIER` (£174,484.74; 2,019 orders) and `WHITE HANGING HEART T-LIGHT HOLDER` (£106,292.77; 2,369 orders). In contrast, items like `PAPER CRAFT , LITTLE BIRDIE` (£168,469.60) reflect single-transaction massive wholesale clearances (80,995 units in invoice 581483).

---

### 4. Operational & Order Distributions
![Order Value Distribution](reports/figures/05_order_value_distribution.png)
![Orders by Hour of Day](reports/figures/06_orders_by_hour_of_day.png)

- **Basket Size Skew:** Mean Average Order Value (AOV) is **£482.44**, while the median is **£272.61** (skewness = 52.74). The 75th percentile is £460.45; the top 5% exceeds £1,485.28.
- **Midday Purchasing Window:** 63.5% of all orders occur between 10:00 and 14:00, peaking at 12:00 (15.70% of transactions). No transactions occur between 20:00 and 06:00.

---

### 5. Geographic Distribution
![Top 10 Countries by Revenue](reports/figures/02_top_countries_by_revenue.png)

- **UK Domestic Dominance:** The UK generates **£8,187,806.36** net revenue (**84.00%** of total net sales) and **£9,003,097.96** gross revenue (**84.58%** of total gross sales).
- **Key Export Corridors:** Netherlands (£284.7k net / 2.92%), EIRE (£263.3k net / 2.70%), Germany (£221.7k net / 2.27%), France (£197.4k net / 2.03%), Australia (£137.1k net / 1.41%). Postage charges (`POSTAGE`) rank as the #1 revenue item in Germany and France, representing a major friction to cross-border expansion.

---

## SQL Analytics Benchmark

The PostgreSQL database (`ecommerce_db`, table `retail_transactions`) validates all headline metrics:

```sql
-- Monthly Net Revenue Trend & MoM Growth (Sample from sql/03_advanced_analysis.sql)
WITH monthly_rev AS (
    SELECT
        DATE_TRUNC('month', invoice_date) AS month_date,
        TO_CHAR(DATE_TRUNC('month', invoice_date), 'YYYY-MM') AS year_month,
        ROUND(SUM(revenue), 2) AS revenue
    FROM retail_transactions
    GROUP BY DATE_TRUNC('month', invoice_date)
    ORDER BY DATE_TRUNC('month', invoice_date)
)
SELECT
    year_month,
    revenue,
    LAG(revenue) OVER (ORDER BY month_date) AS prev_month_revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month_date)) * 100.0 / 
          LAG(revenue) OVER (ORDER BY month_date), 2) AS mom_growth_pct
FROM monthly_rev;
```

| year_month | revenue (£) | prev_month_revenue (£) | mom_growth_pct (%) |
|---|---|---|---|
| **2010-12** | £748,957.02 | *NULL* | *N/A* |
| **2011-01** | £560,000.26 | £748,957.02 | -25.23% |
| **2011-02** | £498,062.65 | £560,000.26 | -11.06% |
| **2011-03** | £683,267.08 | £498,062.65 | +37.19% |
| **2011-04** | £493,207.12 | £683,267.08 | -27.82% |
| **2011-05** | £723,333.51 | £493,207.12 | +46.66% |
| **2011-06** | £691,123.12 | £723,333.51 | -4.45% |
| **2011-07** | £681,300.11 | £691,123.12 | -1.42% |
| **2011-08** | £682,680.51 | £681,300.11 | +0.20% |
| **2011-09** | £1,019,687.62 | £682,680.51 | +49.37% |
| **2011-10** | £1,070,704.67 | £1,019,687.62 | +5.00% |
| **2011-11** | £1,461,756.25 | £1,070,704.67 | +36.52% |
| **2011-12** | £433,668.01 | £1,461,756.25 | -70.33% (truncated Dec 9) |

---

## Strategic Business Recommendations

1. **Formalize a B2B Key Account Program for Top 5% Accounts:**
   - *Target:* 219 accounts generating £4.03M (48.59% of spend).
   - *Action:* Assign dedicated account managers, customized volume discounting schedules, and 30-day net credit terms to protect vital enterprise relationships.
2. **Deploy Automated Win-Back Flows for "At Risk" Accounts:**
   - *Target:* 689 accounts representing £756k in historical revenue currently dormant.
   - *Action:* Trigger dynamic email campaigns featuring restock alerts on previously purchased categories with limited-time reactivation incentives.
3. **Execute a First-to-Second Purchase Conversion Playbook:**
   - *Target:* 1,313 one-time purchasers (30.03% of accounts).
   - *Action:* Deliver automated post-purchase welcome drip emails with an expiring 10% discount voucher valid for 21 days post-delivery. Converting 15% of one-time buyers (≈197 accounts) at AOV represents ~£95k in incremental revenue.
4. **Advance Procurement Cycles to July/August for Q4 Seasonal Ramp:**
   - *Target:* Avoid stockouts during the September–November surge (+104.8% growth).
   - *Action:* Shift manufacturing and supplier bulk POs for top staples (`REGENCY CAKESTAND`, `WHITE HANGING HEART`, `PARTY BUNTING`) to mid-summer.
5. **Pilot a Continental European 3PL Fulfillment Node:**
   - *Target:* European export markets (Netherlands, Germany, France).
   - *Action:* Partner with a bonded 3PL logistics provider in the Netherlands or Germany to offer local shipping rates and Euro-denominated checkout, eliminating the cross-border postage barrier.

---

## Limitations

1. **December 2011 Dataset Truncation:** Transaction logs terminate on December 9, 2011. December captures only 9 full days, creating an artificial MoM drop that must be normalized via daily run-rate metrics.
2. **Missing Customer Attribution (Guest Checkouts):** Exactly 135,080 transactions (24.93%) lack a `CustomerID`. These are incorporated into macro financial and SKU aggregations but excluded from individual customer lifetime value and RFM profiling.
3. **Lack of Cost & Margin Data:** Ledger records selling price (`UnitPrice`) but omits Cost of Goods Sold (COGS), freight/handling costs, and payment fees; findings reflect top-line revenue rather than gross or net profit margin.
4. **Sample-Relative RFM Quintiles:** RFM segment boundaries were generated via internal sample quintiles; thresholds are empirical to this dataset and vertical.

---

## Future Improvements

- **Probabilistic Customer Lifetime Value (CLV) Modeling:** Implement BG/NBD and Gamma-Gamma models to forecast customer retention probabilities and expected monetary value over 12 months.
- **Market Basket Association Rule Mining:** Apply Apriori or FP-Growth algorithms to discover co-purchasing affinities and automate cross-sell bundle recommendations.
- **Interactive Executive Dashboard:** Build a production Streamlit/Dash application connected to PostgreSQL with dynamic date filtering and cohort drill-downs.

---

## How to Run & Reproduce

### 1. Clone Repository & Setup Environment
```bash
git clone https://github.com/Cherry-2502/retail-revenue-customer-intelligence.git
cd retail-revenue-customer-intelligence

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows (PowerShell):
.\venv\Scripts\Activate.ps1
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Download Raw Data
Download the Online Retail dataset from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/352/online%2Bretail) and save the Excel workbook to:
```text
data/raw/Online Retail.xlsx
```

### 3. Run Jupyter Notebooks in Order
Launch Jupyter and execute notebooks 01 through 05 sequentially:
```bash
jupyter lab
```
1. `notebooks/01_data_understanding.ipynb` — Data profiling and null audit.
2. `notebooks/02_data_cleaning.ipynb` — Generates `data/processed/online_retail_clean.csv`.
3. `notebooks/03_exploratory_analysis.ipynb` — Generates core figures in `reports/figures/`.
4. `notebooks/04_customer_analysis.ipynb` — Generates `data/processed/customer_summary.csv` and RFM analysis.
5. `notebooks/05_sql_analysis.ipynb` — Loads clean data into PostgreSQL `retail_transactions` table.

### 4. Execute SQL Queries
Connect to PostgreSQL and run the modular query scripts in `sql/`:
```bash
psql -U postgres -d ecommerce_db -f sql/01_basic_analysis.sql
psql -U postgres -d ecommerce_db -f sql/02_intermediate_analysis.sql
psql -U postgres -d ecommerce_db -f sql/03_advanced_analysis.sql
```

---

## Author & Contact

- **Author:** Gopi
- **Project Repository:** [ecommerce-sales-analytics](https://github.com/Cherry-2502/retail-revenue-customer-intelligence)
- **License:** [MIT License](LICENSE)
