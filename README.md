# 📊 Business Intelligence & Profitability Analysis (End-to-End Project)

## 📌 Project Overview
This project is a comprehensive **Business Intelligence Solution** designed to transform raw sales and operational data into strategic insights focused on **Profitability Analysis** and operational efficiency. 

The project follows a complete analytical data workflow (End-to-End), starting from raw data processing in Excel, moving through advanced data engineering and analytical modeling using **SQL Server (T-SQL)**, and concluding with a high-impact interactive dashboard built in **Power BI**.

The analysis aims to answer critical strategic questions:
* Which products and categories yield the highest **Profit Margin** (not just the highest sales)?
* How do logistics and shipping performance impact operational flow and bottom-line profitability?
* How can we benchmark individual product performance against category averages using advanced ranking?

---

## 📂 Dataset Description
The data architecture transitions through three main layers:
* **Raw Data (Excel):** Initial source containing sales records, product catalogs, and shipping dates.
* **SQL Warehouse (Cleaned Tables):**
    * `dim_fast_sales`: The main fact table, cleaned and standardized.
    * `dim_products`: Dimension table containing standardized costs and categories.
* **SQL Analytical Layer (Views):** 5 core Business Views were engineered to serve as the "Analytical Engine," feeding pre-calculated metrics (Revenue, Cost, Profit, Rank, Shipping Status) directly into Power BI.

---

## ⚙️ Methodology & Workflow
The project followed a rigorous data professional workflow:

1.  **Data Engineering (SQL Server):** * Schema design and implementation of Primary/Foreign key relationships.
    * Data cleaning and handling missing values (**NULLs**) in shipping dates using predictive logic.
2.  **Advanced Analytical Logic:** * Utilizing **Window Functions** (`RANK`, `PARTITION BY`) for dynamic product ranking.
    * Implementing **CTEs** and complex joins to create **Category Benchmarking** (comparing product revenue vs. category averages).
3.  **Data Modeling (Power BI):** * Establishing a high-performance **Star Schema** by connecting Power BI directly to the SQL Analytical Views.
4.  **Final Dashboard Design:** * Building 4 interactive report pages (Summary, Product, Category, Shipping) utilizing advanced Slicers, Tooltips, and DAX measures.

---

## 🔍 SQL Analytical Deep Dive (Views)
Five strategic SQL Views were developed to ensure data consistency and report speed:
* **`vw_monthly_financials`**: Provides a comprehensive monthly financial breakdown.
* **`vw_product_strategic_analysis`**: Analyzes the correlation between sales volume and net profit.
* **`vw_category_master_analysis`**: The "Master View" for benchmarking products against their specific category averages.
* **`vw_shipping_master_analysis`**: A logistics-focused view classifying shipping efficiency (Same Day, Fast, Standard, Delayed).
* **`monthly_revenue_profit_margin`**: A high-level view dedicated to tracking margin trends over time.

---

## 📊 Final Dashboard Features
The interactive Power BI dashboard provides a 360-degree view of the business:
* **Key Performance Indicators (KPIs):** Total Revenue, Total Profit, and Average Shipping Days.
* **Profitability Analysis:** Visualizing Profit Margin percentages across all categories.
* **Operational Trends:** Tracking the relationship between revenue growth and operational costs over time.
* **Strategic Ranking:** Automated tables showing top-performing products by month and category.

---

## 💡 Key Insights
* **Profitability vs. Revenue:** Identified high-revenue products with low-profit margins, leading to recommendations for cost restructuring.
* **Operational Efficiency:** Discovered a direct correlation between shipping speed and profit stability in specific high-value categories.
* **Category Dominance:** While the "Bikes" category drives the majority of revenue, "Accessories" show the highest potential for margin growth.

---

## 🛠️ Tools Used
* **SQL Server (T-SQL)** → Data Cleaning, Transformations, Advanced Analytics & View Engineering. 
* **Power BI** → Data Modeling (Star Schema), DAX, and Interactive Visualization.
* **Excel** → Initial Data Source.

---

## 📁 Project Files
* `01_Setup_and_Cleaning.sql` → Database schema and data cleaning scripts.
* `02_Comprehensive_Business_Insights.sql` → Advanced analytical queries.
* `03_Final_Business_Views.sql` → The 5 core SQL Views powering the dashboard.
* `BI_Profitability_Analysis.pbix` → Final Power BI Dashboard file.

