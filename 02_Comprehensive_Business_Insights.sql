
SELECT order_number,order_date,shipping_date,
    DATEDIFF(day, order_date, shipping_date) AS shipping_days
FROM dim_fast_sales
WHERE order_date IS NOT NULL
  AND shipping_date IS NOT NULL;


SELECT p.category,
    AVG(DATEDIFF(day, f.order_date, f.shipping_date)) AS avg_shipping_days
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
  AND f.shipping_date IS NOT NULL
GROUP BY p.category;



SELECT TOP 10 p.category,p.subcategory,p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.category,
    p.subcategory,
    p.product_name
ORDER BY
    total_revenue DESC;


SELECT TOP 10 p.product_key, p.product_name,
    SUM(f.quantity) AS total_quantity,
    SUM(f.sales_amount) AS total_revenue,
    (SUM(f.sales_amount)/SUM(f.quantity)) AS avg_price_per_unit
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_key,
    p.product_name
ORDER BY
    avg_price_per_unit ASC;


SELECT TOP 10 p.product_key, p.product_name,p.cost,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_key,
    p.product_name,
    p.cost
ORDER BY
    p.cost DESC,         
    total_quantity ASC;


SELECT p.category, p.product_name,
    SUM(f.sales_amount) AS total_revenue,
    RANK() OVER(PARTITION BY p.category ORDER BY SUM(f.sales_amount) DESC) AS revenue_rank
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.category,
    p.product_name
ORDER BY
    p.category,
    revenue_rank;


SELECT f.product_key,p.product_name,f.order_date,
    SUM(f.sales_amount) OVER(
        PARTITION BY f.product_key 
        ORDER BY f.order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
ORDER BY
    f.product_key,
    f.order_date;


SELECT TOP 10 f.order_date,p.product_name,p.category,
    SUM(f.quantity) AS total_qty_sold
FROM dim_fast_sales f
JOIN dim_products p 
    ON f.product_key = p.product_key
GROUP BY 
    f.order_date, 
    p.product_name, 
    p.category
ORDER BY 
    total_qty_sold DESC;



WITH ProductDailySales AS (
    SELECT 
        f.order_date,
        p.product_name,
        p.category,
        SUM(f.quantity) AS total_qty_sold
    FROM dim_fast_sales f
    JOIN dim_products p 
        ON f.product_key = p.product_key
    GROUP BY 
        f.order_date, 
        p.product_name, 
        p.category
),
RankedSales AS (
    SELECT *,
        RANK() OVER (PARTITION BY category ORDER BY total_qty_sold DESC) AS daily_rank
    FROM ProductDailySales
)
SELECT category,product_name,order_date,total_qty_sold,daily_rank
FROM RankedSales
WHERE daily_rank <= 5
ORDER BY category, daily_rank;



SELECT p.category,p.product_name,
    SUM(f.sales_amount) AS product_revenue,
    AVG(SUM(f.sales_amount)) OVER(PARTITION BY p.category) AS category_avg_revenue,
    SUM(f.sales_amount) - AVG(SUM(f.sales_amount)) OVER(PARTITION BY p.category) AS revenue_vs_category_avg
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.category,
    p.product_name
ORDER BY
    p.category,
    revenue_vs_category_avg DESC;


WITH daily_ranking AS (
    SELECT f.order_date,p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER(
            PARTITION BY f.order_date
            ORDER BY SUM(f.sales_amount) DESC
        ) AS daily_rank
    FROM dim_fast_sales f
    JOIN dim_products p
        ON f.product_key = p.product_key
    GROUP BY
        f.order_date,
        p.product_name
)
SELECT *
FROM daily_ranking
WHERE daily_rank <= 3
ORDER BY order_date, daily_rank;



SELECT
    YEAR(f.order_date)  AS order_year,
    MONTH(f.order_date) AS order_month,
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
GROUP BY
    YEAR(f.order_date),
    MONTH(f.order_date),
    p.category
ORDER BY
    order_year,
    order_month,
    p.category;


SELECT p.product_key,p.product_name,
    SUM(f.sales_amount) AS total_revenue,
    SUM(p.cost * f.quantity) AS total_cost,
    SUM(f.sales_amount) - SUM(p.cost * f.quantity) AS total_profit
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_key,
    p.product_name
ORDER BY
    total_profit DESC;


SELECT TOP 10
    p.product_name,
    SUM(f.sales_amount) - SUM(p.cost * f.quantity) AS total_profit
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_name
ORDER BY
    total_profit DESC;


SELECT p.product_name,
    SUM(f.sales_amount) AS total_revenue,
    SUM(p.cost * f.quantity) AS total_cost,
    SUM(f.sales_amount) - SUM(p.cost * f.quantity) AS total_profit
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_name
HAVING SUM(f.sales_amount) > 0
   AND (SUM(f.sales_amount) - SUM(p.cost * f.quantity)) < 0
ORDER BY
    total_profit;


SELECT
    YEAR(f.order_date)  AS order_year,
    MONTH(f.order_date) AS order_month,
    SUM(f.sales_amount) AS total_revenue,
    SUM(p.cost * f.quantity) AS total_cost,
    SUM(f.sales_amount) - SUM(p.cost * f.quantity) AS total_profit,
    (SUM(f.sales_amount) - SUM(p.cost * f.quantity)) * 1.0
        / SUM(f.sales_amount) AS profit_margin
FROM dim_fast_sales f
JOIN dim_products p
    ON f.product_key = p.product_key
GROUP BY
    YEAR(f.order_date),
    MONTH(f.order_date)
ORDER BY
    order_year,
    order_month;