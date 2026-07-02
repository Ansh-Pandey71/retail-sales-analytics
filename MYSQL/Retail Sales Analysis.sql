USE retail_project;

-- Executive Summary
SELECT 
ROUND(SUM(od.sales),1) as total_sales,
ROUND(SUM(od.profit),1) as total_profit,
ROUND(SUM(od.profit)*100.0 / SUM(od.sales),1) as profit_margin,
COUNT(DISTINCT o.order_id) as total_orders,
COUNT(DISTINCT c.customer_id) as total_cust,
ROUND(SUM(od.sales) / COUNT(DISTINCT o.order_id),1) as AOV
FROM customers c 
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_details od ON o.order_id = od.order_id;

-- Category Performance Analysis
SELECT p.category,
ROUND(SUM(od.sales),1) as total_sales,
ROUND(SUM(od.profit),1) as total_profit,
ROUND(SUM(od.profit)*100.0/SUM(od.sales),1) as profit_margin,
SUM(od.quantity) as total_quantity,
COUNT(DISTINCT o.order_id) as total_orders 
FROM products p 
INNER JOIN order_details od ON p.product_id  = od.product_id
INNER JOIN orders o ON od.order_id = o.order_id
GROUP BY p.category
Order By total_sales DESC;

-- Customer Analysis
-- Customer Performance
SELECT c.customer_name,
SUM(od.sales) as revenue,
SUM(od.profit) as profit,
COUNT(DISTINCT o.order_id) as orders,
CASE 
WHEN SUM(od.sales) > 300000 THEN 'High'
ELSE 'Low'
END AS Cust_Status
FROM customers c 
INNER JOIN orders o ON c.customer_id = o.customer_id 
INNER JOIN order_details od ON o.order_id = od.order_id 
GROUP BY c.customer_name;

-- Customer Segment Analysis
SELECT c.segment,
SUM(od.sales) as total_sales,
SUM(od.profit) as total_profit,
COUNT(DISTINCT c.customer_id) as total_cust,
ROUND(SUM(od.profit)*100.0 / SUM(od.sales),1) as profit_margin 
FROM customers c 
INNER JOIN orders o ON c.customer_id = o.customer_id 
INNER JOIN order_details od ON o.order_id = od.order_id 
GROUP BY c.segment;

-- Top 10 Customers
WITH top_cust AS ( 
SELECT c.customer_name,
SUM(od.sales) as total_sales
FROM customers c 
INNER JOIN orders o On c.customer_id = o.customer_id 
INNER JOIN order_details od ON o.order_id = od.order_id 
GROUP BY c.customer_name
)SELECT * FROM (
SELECT *,
RANK() OVER(Order By total_sales DESC) as rnk 
FROM top_cust)x
WHERE rnk <= 10;

-- Product Analysis
-- Product Performance
SELECT p.product_name,
SUM(od.sales) as revenue,
SUM(od.profit) as profit,
SUM(od.quantity) as total_quantity,
CASE 
WHEN SUM(od.sales) > 500000 THEN 'High'
ELSE 'Low'
END AS Product_Status
FROM products p 
INNER JOIN order_details od ON p.product_id = od.product_id 
GROUP BY p.product_name;

-- Top 10 Products
WITH top_products AS ( 
SELECT p.product_name,
SUM(od.sales) as revenue
FROM products p 
INNER JOIN order_details od ON p.product_id = od.product_id 
GROUP BY p.product_name
)SELECT * FROM (
SELECT *,
dense_rank() OVER(Order By revenue DESC) as drnk 
FROM top_products)x
WHERE drnk <= 10;

-- Loss Making Products
SELECT p.product_name,
SUM(od.sales) as revenue,
SUM(od.profit) as profit 
FROM products p 
INNER JOIN order_details od ON p.product_id = od.product_id 
GROUP BY p.product_name
HAVING SUM(od.profit) < 0;

-- Sales Trend
-- Monthly Sales Trend
WITH monthly_running AS(
SELECT DATE_FORMAT(o.order_date,'%Y-%m') as month_no,
SUM(od.sales) as total_sales 
FROM orders o
INNER JOIN order_details od ON o.order_id = od.order_id 
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m') 
Order By month_no
)
SELECT *,
SUM(total_sales) OVER(Order By month_no) as running_sales 
FROM monthly_running;

-- Monthly Growth
WITH monthly_growth AS ( 
SELECT DATE_FORMAT(o.order_date,'%Y-%m') as month_no,
SUM(od.sales) as total_sales 
FROM orders o
INNER JOIN order_details od ON o.order_id = od.order_id 
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m') 
Order By month_no
)
SELECT *,
LAG(total_sales) OVER(Order By month_no) as prev_sales,
total_sales-LAG(total_sales) OVER(Order By month_no) as sales_change,
ROUND((total_sales-LAG(total_sales) OVER(Order By month_no)*100.0 / 
LAG(total_sales) OVER(Order By month_no),1) as growth_pct
FROM monthly_growth;

-- 3-Month Moving Average
WITH monthly_avg AS ( 
SELECT DATE_FORMAT(o.order_date,'%Y-%m') as month_no,
SUM(od.sales) as total_sales 
FROM orders o
INNER JOIN order_details od ON o.order_id = od.order_id 
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m') 
Order By month_no
)
SELECT *,
ROUND(AVG(total_sales) OVER(Order By month_no
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) as running_avg 
FROM monthly_avg;

-- Regional Analysis
-- Region Performance
SELECT c.region,
SUM(od.sales) as total_sales,
SUM(od.profit) as total_profit,
ROUND(SUM(od.profit)*100.0 / SUM(od.sales),1) as profit_margin,
COUNT(DISTINCT o.order_id) as total_orders 
FROM customers c 
INNER JOIN orders o ON c.customer_id = o.customer_id 
INNER JOIN order_details od ON o.order_id = od.order_id 
GROUP BY c.region;

-- State Performance
SELECT c.state,
SUM(od.sales) as revenue
FROM customers c 
INNER JOIN orders o ON c.customer_id = o.customer_id 
INNER JOIN order_details od ON o.order_id = od.order_id 
GROUP BY c.state
Order By revenue DESC;

-- Returns Analysis
-- Return Analysis
SELECT c.region,
COUNT(DISTINCT o.order_id) as total_orders,
COUNT(DISTINCT r.order_id) as total_returned,
ROUND(COUNT(DISTINCT r.order_id)*100.0/COUNT(DISTINCT o.order_id),1) as return_pct,
CASE 
WHEN ROUND(COUNT(DISTINCT r.order_id)*100.0/COUNT(DISTINCT o.order_id),1) > 10 THEN 'High Return'
ELSE 'Normal'
END AS ReturnStatus 
FROM customers c 
INNER JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN returns r ON o.order_id = r.order_id
GROUP BY c.region;

-- Most Returned Products/Categories
SELECT * FROM products p 
WHERE EXISTS (SELECT 1 FROM order_details od 
				WHERE p.product_id = od.product_id
) AND NOT EXISTS (SELECT 1 FROM orders o  
					INNER JOIN returns r ON o.order_id = r.order_id
                    WHERE od.product_id = p.product_id);