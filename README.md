## E-Commerce Business Performance Analytics

### Project Overview

This project analyzes an e-commerce company's business performance end-to-end using **SQL**, **Python**, and a **BI dashboard**.  
The dataset is a synthetic but realistic transactional dataset covering customers, orders, order items, products, and payments.

The analysis focuses on understanding **revenue trends, customer behavior, product performance, and payment preferences** to support data‑driven decision making for growth and profitability.

### Business Problem

The (fictional) e-commerce company wants to answer questions such as:

- How is **revenue trending over time**?
- Which **products and categories** drive the majority of sales?
- What is our **customer lifetime value (CLV)** and **average order value (AOV)**?
- How many **repeat vs one-time customers** do we have?
- What is our **order cancellation rate**, and which segments are most impacted?
- Which **payment methods** and **customer locations** generate the most revenue?

This project provides a structured analytics workflow and artifacts that a Data Analyst or Analytics Engineer can reuse or extend.

### Tools & Technologies

- **SQL**: SQLite/PostgreSQL-compatible queries for core business questions (`sql/analysis_queries.sql`)
- **Python**: `pandas`, `numpy`, `matplotlib`, `seaborn` for data cleaning, EDA, and visualization (Jupyter notebook)
- **Jupyter Notebook**: Interactive analysis in `notebooks/ecommerce_analysis.ipynb`
- **BI Tool**: Power BI or Tableau using cleaned CSV exports from `data/processed`
- **Git & GitHub**: Version control and project sharing

### Data & Folder Structure

Project root: `E-Commerce-Analytics`

- **`data/raw/`**  
  - `customers.csv`  
  - `orders.csv`  
  - `order_items.csv`  
  - `products.csv`  
  - `payments.csv`  
  Synthetic but realistic e-commerce transactional data generated via `generate_data.py`.

- **`data/processed/`**  
  BI-ready exports (created from the notebook), e.g.:  
  - `revenue_over_time.csv`  
  - `category_sales.csv`  
  - `top_products.csv`  
  - `customer_segments.csv`

- **`sql/analysis_queries.sql`**  
  Contains production-style SQL queries for:
  - Total and monthly revenue
  - Top 10 products
  - Revenue by category
  - CLV and AOV
  - Repeat vs one-time customers
  - Order cancellation rate
  - Payment method usage
  - Revenue by customer country (for map visuals)

- **`notebooks/ecommerce_analysis.ipynb`**  
  Jupyter notebook with:
  - Data loading and quality checks
  - Data cleaning and type handling
  - Unified order-level fact table
  - EDA and visualizations
  - Business insights and recommendations

- **`dashboard/`**  
  - `dashboard_mockup.png` (conceptual layout for the BI dashboard)

- **`reports/business_insights.md`**  
  Narrative business report summarizing insights and recommendations.

### Analysis Workflow

1. **Data Generation (one-time for this demo)**
   - Run `generate_data.py` to create synthetic CSVs in `data/raw/`.

2. **SQL Exploration**
   - Use `sql/analysis_queries.sql` in SQLite/PostgreSQL to:
     - Validate aggregates against notebook results
     - Explore revenue, CLV, AOV, customer behavior, and cancellations

3. **Python & Notebook Analysis**
   - Open `notebooks/ecommerce_analysis.ipynb` in Jupyter Lab/Notebook.
   - Run cells in order to:
     - Load raw data
     - Perform data quality checks and cleaning
     - Build a unified order-level dataset (joining customers, orders, items, products, payments)
     - Visualize:
       - Monthly revenue trend
       - Category-wise sales
       - Customer distribution by country/city
       - Payment method usage

4. **BI-Ready Exports**
   - From the notebook, export aggregated tables into `data/processed/`:
     - `revenue_over_time.csv`
     - `category_sales.csv`
     - `top_products.csv`
     - `customer_segments.csv`

5. **Dashboarding (Power BI / Tableau)**
   - Connect your BI tool to the CSVs in `data/processed/`.
   - Build visuals using the guidelines below.

### Dashboard Design Guidelines

When building the dashboard (e.g., in Power BI/Tableau), include:

- **KPI Cards**
  - Total Revenue
  - Total Orders
  - Average Order Value (AOV)
  - Average or Top-quartile Customer Lifetime Value (CLV)

- **Line Chart**
  - X-axis: Month (`year_month`)
  - Y-axis: Revenue
  - Highlight seasonality and growth trends.

- **Bar Chart: Category Sales**
  - X-axis: Product category
  - Y-axis: Revenue or quantity sold
  - Use this to identify hero and underperforming categories.

- **Map: Sales by Location**
  - Geography: Country (and optionally city)
  - Metric: Revenue
  - Useful for regional strategy decisions.

- **Filters / Slicers**
  - Date range
  - Product category
  - Customer country
  - Payment type
  - Order status

### Example Key Insights (from the synthetic data)

These are examples of the types of findings the notebook is designed to surface:

- **Revenue Concentration**: A small set of categories (e.g., Electronics and Fashion) drive a majority of revenue, while others (e.g., Toys, Books) are niche but steady.
- **Customer Behavior**: A meaningful share of customers are **repeat buyers**, contributing disproportionately to total revenue versus one-time shoppers.
- **Order Economics**: **AOV** is higher for Electronics and Home & Kitchen, suggesting opportunities for bundles and premium positioning.
- **Geographic Performance**: Revenue is skewed towards a few key markets (e.g., USA, UK), indicating room to grow in underpenetrated regions.
- **Payment Preferences**: Digital methods (credit/debit cards, PayPal) dominate, with cash-on-delivery being marginal but important in specific countries.
- **Cancellations**: The **order cancellation rate** is modest but can be monitored over time to flag operational issues.

### How to Run the Project

1. **Clone the Repository**

   ```bash
   git clone https://github.com/Archie0410/ecommerce-business-analytics.git
   cd ecommerce-business-analytics
   ```

2. **Set Up Python Environment**

   ```bash
   python -m venv .venv
   .venv\Scripts\activate  # on Windows
   pip install pandas numpy matplotlib seaborn jupyter
   ```

3. **(Optional) Regenerate Data**

   ```bash
   python generate_data.py
   ```

4. **Run the Notebook**

   ```bash
   jupyter notebook notebooks/ecommerce_analysis.ipynb
   ```

5. **Load Data into BI Tool**
   - In Power BI/Tableau, connect to the CSV files in `data/processed/`.
   - Recreate or extend the dashboard using the design guidelines above.

### Intended Audience

This project is designed to demonstrate the skills of a **Data Analyst / Analytics Engineer** for portfolio and interview use:

- Translating business questions into metrics and SQL/Python analyses
- Building clean, reusable analytical datasets
- Communicating findings via visualizations, dashboards, and written reports


