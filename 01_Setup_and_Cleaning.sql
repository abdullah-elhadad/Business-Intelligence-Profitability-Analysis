CREATE TABLE dim_products (
    product_key     INT PRIMARY KEY,
    product_id      INT,
    product_number  VARCHAR(50),
    product_name    VARCHAR(255),
    category_id     VARCHAR(20),
    category        VARCHAR(50),
    subcategory     VARCHAR(50),
    maintenance     VARCHAR(10),
    cost            DECIMAL(10,2),
    product_line    VARCHAR(50),
    start_date      DATE
);

CREATE TABLE dim_fast_sales (
    order_number    VARCHAR(20),
    product_key     INT,
    customer_key    INT,
    order_date      DATE,
    shipping_date   DATE,
    due_date        DATE,
    sales_amount    DECIMAL(10,2),
    quantity        INT,
    price           DECIMAL(10,2),

    CONSTRAINT fk_product
        FOREIGN KEY (product_key)
        REFERENCES dim_products(product_key)
);

INSERT INTO dim_products (
    product_key,
    product_id,
    product_number,
    product_name,
    category_id,
    category,
    subcategory,
    maintenance,
    cost,
    product_line,
    start_date
)
SELECT
    CAST(product_key AS INT),
    CAST(product_id AS INT),
    product_number,
    product_name,
    category_id,
    category,
    subcategory,
    maintenance,
    CAST(cost AS DECIMAL(10,2)),
    product_line,
    CAST(start_date AS DATE)
FROM products;

INSERT INTO dim_fast_sales (
    order_number,
    product_key,
    customer_key,
    order_date,
    shipping_date,
    due_date,
    sales_amount,
    quantity,
    price
)
SELECT
    order_number,
    CAST(product_key AS INT),
    CAST(customer_key AS INT),
    CAST(order_date AS DATE),
    CAST(shipping_date AS DATE),
    CAST(due_date AS DATE),
    CAST(sales_amount AS DECIMAL(10,2)),
    CAST(quantity AS INT),
    CAST(price AS DECIMAL(10,2))
FROM fact_sales;


SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM dim_products;

SELECT COUNT(*) FROM fact_sales;
SELECT COUNT(*) FROM dim_fast_sales;




SELECT *
FROM dim_fast_sales
WHERE sales_amount <> quantity * price;


SELECT p.product_key, p.product_name
FROM dim_products p
LEFT JOIN dim_fast_sales s
    ON p.product_key = s.product_key
WHERE s.product_key IS NULL;


SELECT s.*
FROM dim_fast_sales s
LEFT JOIN dim_products p
    ON s.product_key = p.product_key
WHERE p.product_key IS NULL;

SELECT *
FROM dim_fast_sales
WHERE shipping_date < order_date
   OR due_date < shipping_date;

SELECT *
FROM dim_fast_sales
WHERE
    order_number IS NULL
 OR product_key IS NULL
 OR order_date IS NULL
 OR sales_amount IS NULL
 OR quantity IS NULL;

UPDATE dim_fast_sales
SET order_date = DATEADD(day, -7, shipping_date)
WHERE order_date IS NULL;

SELECT COUNT(*) AS still_null_order_dates
FROM dim_fast_sales
WHERE order_date IS NULL;