--------------------------------------------------------------------------------------------
-- 1. Monthly Revenue & Profit Margin View
--------------------------------------------------------------------------------------------
CREATE VIEW monthly_revenue_profit_margin AS
SELECT 
    p.category,
    YEAR(f.order_date) AS order_year,
    MONTH(f.order_date) AS order_month,
    SUM(f.sales_amount) AS total_revenue,
    SUM(p.cost * f.quantity) AS total_cost,
    SUM(f.sales_amount) - SUM(p.cost * f.quantity) AS total_profit,
    (SUM(f.sales_amount) - SUM(p.cost * f.quantity)) * 1.0 / NULLIF(SUM(f.sales_amount), 0) AS profit_margin
FROM dim_fast_sales f
JOIN dim_products p ON f.product_key = p.product_key
GROUP BY 
    p.category,
    YEAR(f.order_date), 
    MONTH(f.order_date);
GO

--------------------------------------------------------------------------------------------
-- 2. Monthly Financials View 
--------------------------------------------------------------------------------------------
CREATE VIEW vw_monthly_financials
AS
SELECT
    p.category,
    YEAR(f.order_date)  AS order_year,
    MONTH(f.order_date) AS order_month,
    DATEFROMPARTS(YEAR(f.order_date), MONTH(f.order_date), 1) AS order_month_date,
    SUM(f.sales_amount) AS total_revenue,
    SUM(p.cost * f.quantity) AS total_cost,
    SUM(f.sales_amount) - SUM(p.cost * f.quantity) AS total_profit,
    CASE 
        WHEN SUM(f.sales_amount) = 0 THEN 0
        ELSE (SUM(f.sales_amount) - SUM(p.cost * f.quantity)) * 1.0 / NULLIF(SUM(f.sales_amount), 0)
    END AS profit_margin
FROM dim_fast_sales f
JOIN dim_products p ON f.product_key = p.product_key
GROUP BY 
    p.category,
    YEAR(f.order_date), 
    MONTH(f.order_date);
GO

--------------------------------------------------------------------------------------------
-- 3. Product Strategic Analysis View
--------------------------------------------------------------------------------------------
CREATE VIEW vw_product_strategic_analysis AS
SELECT 
    p.product_name,
    p.category,
    p.subcategory,
    YEAR(f.order_date) AS order_year,
    MONTH(f.order_date) AS order_month,
    SUM(f.quantity) AS total_qty,
    SUM(f.sales_amount) AS total_revenue,
    SUM(p.cost * f.quantity) AS total_cost,
    SUM(f.sales_amount) - SUM(p.cost * f.quantity) AS total_profit,
    CASE 
        WHEN SUM(f.sales_amount) = 0 THEN 0 
        ELSE (SUM(f.sales_amount) - SUM(p.cost * f.quantity)) * 1.0 / SUM(f.sales_amount) 
    END AS profit_margin_pct,
    RANK() OVER(PARTITION BY YEAR(f.order_date), MONTH(f.order_date) ORDER BY SUM(f.sales_amount) DESC) AS product_rank_in_month
FROM dim_fast_sales f
JOIN dim_products p ON f.product_key = p.product_key
GROUP BY 
    p.product_name, 
    p.category, 
    p.subcategory, 
    YEAR(f.order_date), 
    MONTH(f.order_date);
GO

--------------------------------------------------------------------------------------------
-- 4. Category Master Analysis View
--------------------------------------------------------------------------------------------
CREATE VIEW vw_category_master_analysis AS
WITH category_base AS (
    SELECT 
        p.category,
        p.subcategory,
        p.product_name,
        YEAR(f.order_date) AS order_year,
        MONTH(f.order_date) AS order_month,
        DATEFROMPARTS(YEAR(f.order_date), MONTH(f.order_date), 1) AS order_month_date,
        SUM(f.quantity) AS total_qty,
        SUM(f.sales_amount) AS total_revenue,
        SUM(p.cost * f.quantity) AS total_cost,
        SUM(f.sales_amount) - SUM(p.cost * f.quantity) AS total_profit,
        AVG(DATEDIFF(day, f.order_date, f.shipping_date)) AS avg_shipping_days
    FROM dim_fast_sales f
    JOIN dim_products p ON f.product_key = p.product_key
    GROUP BY 
        p.category, p.subcategory, p.product_name, 
        YEAR(f.order_date), MONTH(f.order_date)
)
SELECT 
    *,
    CASE 
        WHEN total_revenue = 0 THEN 0 
        ELSE total_profit * 1.0 / total_revenue 
    END AS profit_margin_pct,
    AVG(total_revenue) OVER(PARTITION BY category, order_year, order_month) AS category_avg_revenue,
    total_revenue - AVG(total_revenue) OVER(PARTITION BY category, order_year, order_month) AS revenue_vs_category_avg,
    RANK() OVER(PARTITION BY category, order_year, order_month ORDER BY total_revenue DESC) AS product_rank_in_category
FROM category_base;
GO

--------------------------------------------------------------------------------------------
-- 5. Shipping Master Analysis View
--------------------------------------------------------------------------------------------
CREATE VIEW vw_shipping_master_analysis AS
SELECT 
    f.order_number,
    p.category,
    p.subcategory,
    p.product_name,
    f.order_date,
    f.shipping_date,
    DATEDIFF(day, f.order_date, f.shipping_date) AS shipping_days,
    CASE 
        WHEN DATEDIFF(day, f.order_date, f.shipping_date) = 0 THEN 'Same Day'
        WHEN DATEDIFF(day, f.order_date, f.shipping_date) <= 3 THEN 'Fast (1-3 Days)'
        WHEN DATEDIFF(day, f.order_date, f.shipping_date) <= 5 THEN 'Standard (4-5 Days)'
        ELSE 'Delayed (> 5 Days)'
    END AS shipping_status,
    f.sales_amount AS revenue,
    (p.cost * f.quantity) AS total_cost,
    (f.sales_amount - (p.cost * f.quantity)) AS profit,
    CASE 
        WHEN f.sales_amount = 0 THEN 0 
        ELSE (f.sales_amount - (p.cost * f.quantity)) / f.sales_amount 
    END AS profit_margin,
    f.quantity,
    YEAR(f.order_date) AS order_year,
    MONTH(f.order_date) AS order_month,
    DATEFROMPARTS(YEAR(f.order_date), MONTH(f.order_date), 1) AS order_month_date
FROM dim_fast_sales f
JOIN dim_products p ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL AND f.shipping_date IS NOT NULL;
GO