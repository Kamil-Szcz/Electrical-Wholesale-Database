-- 1. Which products are sold most often?
SELECT p.product_id, SUM(si.quantity) AS sales_total
FROM products p
INNER JOIN sales_items si
ON p.product_id = si.product_id
GROUP BY p.product_id
ORDER BY sales_total DESC;

-- 2. What are the sales trends by month/days?
-- by month
SELECT SUM(si.quantity) AS sales_total, TO_CHAR(sh.sale_date, 'YYYY-MM') AS month
FROM sales_items si
INNER JOIN sales_history sh
ON si.sales_id = sh.sales_id
GROUP BY TO_CHAR(sh.sale_date, 'YYYY-MM')
ORDER BY month;

-- by day
SELECT SUM(si.quantity) AS sales_total, TO_CHAR(sh.sale_date, 'YYYY-MM-DD') AS day
FROM sales_items si
INNER JOIN sales_history sh
ON si.sales_id = sh.sales_id
GROUP BY TO_CHAR(sh.sale_date, 'YYYY-MM-DD')
ORDER BY day;

-- 3. Which days of the week generate the highest sales?
SELECT ROUND(SUM(si.quantity * p.net_sale_price), 2) AS sales_value, TO_CHAR(sh.sale_date, 'Day', 'NLS_DATE_LANGUAGE=Polish') AS day_of_week
FROM sales_items si
INNER JOIN sales_history sh
ON si.sales_id = sh.sales_id
INNER JOIN products p
ON si.product_id = p.product_id
GROUP BY TO_CHAR(sh.sale_date, 'Day', 'NLS_DATE_LANGUAGE=Polish')
ORDER BY sales_value DESC;

-- 4. Which customers generate the most revenue?
CREATE VIEW CustomerPurchaseValues AS
SELECT c.customer_name, SUM(si.quantity * p.net_sale_price) AS purchase_value
FROM  customers c
INNER JOIN sales_history sh 
ON c.customer_id = sh.customer_id
INNER JOIN sales_items si 
ON sh.sales_id = si.sales_id
INNER JOIN products p 
ON si.product_id = p.product_id
GROUP BY c.customer_name;

SELECT customer_name, ROUND(purchase_value, 2) AS purchase_value 
FROM CustomerPurchaseValues
ORDER BY purchase_value DESC;

-- 5. What is the average value of orders?
SELECT ROUND(AVG(order_value), 2) AS average_order_value
FROM 
(
SELECT sh.sales_id, SUM(si.quantity * p.net_sale_price) AS order_value
FROM sales_history sh
INNER JOIN sales_items si 
ON sh.sales_id = si.sales_id
INNER JOIN products p 
ON si.product_id = p.product_id 
GROUP BY sh.sales_id
);

-- 6. What are the average sales in each voivodeship?
SELECT v.voivodeship_name, ROUND(NVL(AVG(si.quantity * p.net_sale_price), 0), 2) AS average_sales
FROM voivodeships v
LEFT OUTER JOIN locations l 
ON v.voivodeship_id = l.voivodeship
LEFT OUTER JOIN customers c 
ON l.location_id = c.location_id
LEFT OUTER JOIN sales_history sh 
ON c.customer_id = sh.customer_id
LEFT OUTER JOIN sales_items si 
ON sh.sales_id = si.sales_id
LEFT OUTER JOIN products p 
ON si.product_id = p.product_id
GROUP BY v.voivodeship_name
ORDER BY average_sales DESC;

-- 7. Which products are running low?
SELECT product_id, product_description, quantity_in_stock, reorder_level
FROM products
WHERE reorder_level >= quantity_in_stock  
ORDER BY quantity_in_stock;

-- 8. What are the profit margins on each product?
SELECT 
    product_id 
    , product_description 
    , net_sale_price 
    , net_purchase_price 
    , (net_sale_price - net_purchase_price) AS profit_margin_value 
    , ROUND(((net_sale_price - net_purchase_price) / net_sale_price) * 100, 2) AS profit_margin_percentage
FROM 
    products 
ORDER BY 
    profit_margin_percentage DESC;

-- 9. Which products have the highest return on investment (ROI)?
SELECT 
    product_id
    , product_description
    , net_sale_price
    , net_purchase_price
    , ROUND(((net_sale_price - net_purchase_price) / net_purchase_price) * 100, 2) AS ROI_percentage
FROM 
    products
WHERE 
    net_purchase_price > 0 -- Excludes products with zero or unknown purchase cost
ORDER BY 
    ROI_percentage DESC;

-- 10. What are the projected revenues based on current sales trends? 
-- The query calculates the revenue forecast based on the average revenue of the last 3 months
WITH Monthly_Sales AS 
(
    SELECT TRUNC(sh.sale_date, 'MM') AS sales_month, SUM(si.quantity * p.net_sale_price) AS monthly_revenue
    FROM sales_history sh
    INNER JOIN sales_items si
    ON sh.sales_id = si.sales_id
    INNER JOIN products p
    ON si.product_id = p.product_id 
    GROUP BY 
    TRUNC(sh.sale_date, 'MM')
),
MovingAverage AS 
(
    SELECT sales_month, AVG(monthly_revenue) OVER (ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_revenue
    FROM Monthly_Sales
)

SELECT sales_month, ROUND(moving_avg_revenue, 2) AS forecasted_revenue
FROM MovingAverage
ORDER BY sales_month DESC;

-- 11. What products should be promoted to increase sales?
-- This query identifies products with high margins but low total sales
SELECT 
    p.product_id
    , p.product_description
    , ROUND((p.net_sale_price - p.net_purchase_price) / p.net_purchase_price * 100, 2) AS profit_margin_percentage
    , SUM(si.quantity) AS total_sales_quantity
FROM products p
INNER JOIN sales_items si 
ON p.product_id = si.product_id
GROUP BY p.product_id, p.product_description, p.net_sale_price, p.net_purchase_price
HAVING SUM(si.quantity) < (SELECT AVG(SUM(quantity)) FROM sales_items GROUP BY product_id) -- Products below average sales
ORDER BY profit_margin_percentage DESC, total_sales_quantity ASC;

-- 12. Which salesman has completed the most transactions?
SELECT e.employee_id, e.first_name, e.last_name, COUNT(sh.sales_id) AS transaction_count
FROM employees e
INNER JOIN jobs j
ON e.job_id = j.job_id
INNER JOIN sales_history sh
ON e.employee_id = sh.seller
WHERE j.job_title = 'Sales Representative'
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY transaction_count DESC;

--13. Which salesman sold the most products?
SELECT e.employee_id, e.first_name, e.last_name, SUM(si.quantity) AS number_of_products_sold
FROM employees e
INNER JOIN jobs j
ON e.job_id = j.job_id
INNER JOIN sales_history sh
ON e.employee_id = sh.seller
INNER JOIN sales_items si
ON sh.sales_id = si.sales_id
WHERE j.job_title = 'Sales Representative'
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY number_of_products_sold DESC;

-- 14. Which salesman generated the most revenue?
SELECT e.employee_id, e.first_name, e.last_name, ROUND(SUM(si.quantity * p.net_sale_price), 2) AS revenue
FROM employees e
INNER JOIN jobs j
ON e.job_id = j.job_id
INNER JOIN sales_history sh
ON e.employee_id = sh.seller
INNER JOIN sales_items si
ON sh.sales_id = si.sales_id
INNER JOIN products p
ON si.product_id = p.product_id
WHERE j.job_title = 'Sales Representative'
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY revenue DESC;

-- 15. Which salesman sold the most in each voivodeship?
WITH sales_data AS 
(
SELECT 
    v.voivodeship_name
    , e.employee_id
    , e.first_name
    , e.last_name
    , SUM(si.quantity * p.net_sale_price) AS total_sale
FROM 
voivodeships v
LEFT OUTER JOIN locations l 
ON v.voivodeship_id = l.voivodeship
LEFT OUTER JOIN customers c 
ON l.location_id = c.location_id
LEFT OUTER JOIN sales_history sh 
ON c.customer_id = sh.customer_id
LEFT OUTER JOIN employees e 
ON sh.seller = e.employee_id
LEFT OUTER JOIN sales_items si 
ON sh.sales_id = si.sales_id
LEFT OUTER JOIN products p 
ON si.product_id = p.product_id
GROUP BY v.voivodeship_name, e.employee_id, e.first_name, e.last_name
)

SELECT
    v.voivodeship_name
    , CASE 
        WHEN sd.first_name IS NULL AND sd.last_name IS NULL THEN '!Lack of sales!'
        ELSE sd.first_name || ' ' || sd.last_name 
        END AS salesman
    , COALESCE(sd.total_sale, 0) AS total_sale
FROM 
    voivodeships v
LEFT OUTER JOIN 
    (SELECT voivodeship_name, first_name, last_name, total_sale
    FROM sales_data
    WHERE (voivodeship_name, total_sale) 
    IN (
        SELECT voivodeship_name, MAX(total_sale)
        FROM sales_data
        GROUP BY voivodeship_name
        )
    ) sd 
ON v.voivodeship_name = sd.voivodeship_name
ORDER BY v.voivodeship_name;

-- 16. What is the average value of an order for a particular salesman? 
SELECT e.employee_id, e.first_name, e.last_name, ROUND(AVG(si.quantity * p.net_sale_price), 2) AS average_value
FROM employees e
INNER JOIN jobs j
ON e.job_id = j.job_id
INNER JOIN sales_history sh
ON e.employee_id = sh.seller
INNER JOIN sales_items si
ON sh.sales_id = si.sales_id
INNER JOIN products p
ON si.product_id = p.product_id
WHERE j.job_title = 'Sales Representative'
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY average_value DESC;

-- 17. Which products bring in the most revenue in each voivodeship?
WITH product_popularity AS
(
SELECT 
    v.voivodeship_name
    , p.product_id
    , p.product_description
    , SUM(si.quantity * p.net_sale_price) AS total_sale
FROM voivodeships v
LEFT OUTER JOIN locations l
ON v.voivodeship_id = l.voivodeship
LEFT OUTER JOIN customers c
ON l.location_id = c.location_id
LEFT OUTER JOIN sales_history sh
ON c.customer_id = sh.customer_id
LEFT OUTER JOIN sales_items si
ON sh.sales_id = si.sales_id
LEFT OUTER JOIN products p
ON si.product_id = p.product_id
GROUP BY v.voivodeship_name, p.product_id, p.product_description
)

SELECT
    v.voivodeship_name
    , COALESCE(pp.product_id, '!Lack of sales!') AS product_id 
    , COALESCE(pp.total_sale, 0) AS total_sale
FROM 
voivodeships v
LEFT OUTER JOIN 
    (SELECT voivodeship_name, product_id, total_sale
    FROM product_popularity
    WHERE (voivodeship_name, total_sale) 
    IN (
        SELECT voivodeship_name, MAX(total_sale)
        FROM product_popularity
        GROUP BY voivodeship_name
        )
    ) pp 
ON v.voivodeship_name = pp.voivodeship_name
ORDER BY total_sale DESC;

-- 18. Which products have the lowest profit margins?
SELECT 
    product_id 
    , product_description 
    , net_sale_price 
    , net_purchase_price 
    , (net_sale_price - net_purchase_price) AS profit_margin_value 
    , ROUND(((net_sale_price - net_purchase_price) / net_sale_price) * 100, 2) AS profit_margin_percentage
FROM 
    products 
ORDER BY 
    profit_margin_percentage ASC;

-- 19. Which products are most seasonal?
WITH MonthlySales AS 
(
SELECT p.product_id, p.product_description, EXTRACT(MONTH FROM sh.sale_date) AS sale_month, SUM(si.quantity) AS total_quantity_sold
FROM products p
INNER JOIN sales_items si 
ON p.product_id = si.product_id
INNER JOIN sales_history sh 
ON si.sales_id = sh.sales_id
GROUP BY p.product_id, p.product_description, EXTRACT(MONTH FROM sh.sale_date)
),
SalesVariation AS 
(
SELECT product_id, product_description, ROUND(STDDEV(total_quantity_sold), 2) AS sales_std_dev -- standard deviation of monthly sales of each product
FROM MonthlySales
GROUP BY product_id, product_description
)

SELECT product_description, sales_std_dev
FROM SalesVariation
ORDER BY sales_std_dev DESC;
