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
SELECT v.voivodeship_name, ROUND(AVG(si.quantity * p.net_sale_price), 2) AS average_sales
FROM sales_history sh
INNER JOIN customers c 
ON sh.customer_id = c.customer_id
INNER JOIN locations l 
ON c.location_id = l.location_id
INNER JOIN voivodeships v 
ON l.voivodeship = v.voivodeship_id
INNER JOIN sales_items si 
ON sh.sales_id = si.sales_id
INNER JOIN products p 
ON si.product_id = p.product_id
GROUP BY v.voivodeship_name
ORDER BY average_sales DESC;

