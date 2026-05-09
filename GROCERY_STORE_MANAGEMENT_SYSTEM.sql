CREATE DATABASE GROCERY_STORE_MANAGEMENT;
USE  GROCERY_STORE_MANAGEMENT;

CREATE TABLE supplier (
 sup_id TINYINT PRIMARY KEY AUTO_INCREMENT,
 sup_name VARCHAR(255),
 address TEXT
);

SELECT * FROM  supplier ;

CREATE TABLE categories (
 cat_id TINYINT PRIMARY KEY AUTO_INCREMENT,
 cat_name VARCHAR(255)
);
SELECT * FROM categories ;
CREATE TABLE employees (
 emp_id TINYINT PRIMARY KEY AUTO_INCREMENT,
 emp_name VARCHAR(255),
 hire_date VARCHAR(255)
);
SELECT * FROM  employees ;

CREATE TABLE customers (
 cust_id SMALLINT PRIMARY KEY AUTO_INCREMENT,
 cust_name VARCHAR(255),
 address TEXT
);
SELECT * FROM  customers ;

CREATE TABLE products (
 prod_id TINYINT PRIMARY KEY AUTO_INCREMENT,
 prod_name VARCHAR(255),
 sup_id TINYINT,
 cat_id TINYINT,
 price DECIMAL(10,2),
 FOREIGN KEY (sup_id) REFERENCES supplier(sup_id)
 ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (cat_id) REFERENCES categories(cat_id)
 ON UPDATE CASCADE ON DELETE CASCADE
);
SELECT * FROM  products ;

CREATE TABLE orders (
 ord_id SMALLINT PRIMARY KEY AUTO_INCREMENT,
 cust_id SMALLINT,
 emp_id TINYINT,
 order_date VARCHAR(255),
 FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
 ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
 ON UPDATE CASCADE ON DELETE CASCADE
);
SELECT * FROM  orders ;

CREATE TABLE order_details (
 ord_detID SMALLINT AUTO_INCREMENT PRIMARY KEY,
 ord_id SMALLINT,
 prod_id TINYINT,
 quantity TINYINT,
 each_price DECIMAL(10,2),
 total_price DECIMAL(10,2),
 FOREIGN KEY (ord_id) REFERENCES orders(ord_id)
 ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (prod_id) REFERENCES products(prod_id)
 ON UPDATE CASCADE ON DELETE CASCADE
);
SELECT * FROM  order_details;
SHOW TABLES;

# BUSINESS PROBLEM
/*
A grocery store is facing challenges in understanding its overall business performance due to the lack of a centralized data analysis system. 

The store is unable to effectively track customer purchasing behavior, identify top-selling products, evaluate supplier contributions, monitor employee performance, and analyze sales trends over time.

As a result, the business struggles to make informed decisions related to inventory management, customer retention, supplier selection, and sales optimization.

This project aims to leverage SQL-based data analysis to generate meaningful insights from transactional data, enabling the business to improve operational efficiency, increase revenue, and make data-driven strategic decisions.
*/
# PROBLEM STATMENT
/*
“I understood that the business has data but no insights. 
So I analyzed customer behavior, product performance, sales trends, supplier contribution, 
and employee performance using SQL to help the business make better decisions.”
*/

# OBJECTIVE
/*
The main objective of this project is to transform raw transactional data into 
meaningful business insights using SQL. 

By analyzing customer behavior, product performance, sales trends, supplier contribution,
 and employee efficiency, the project aims to support better decision-making, improve 
 operational efficiency, and increase overall profitability of the grocery store.
*/
--  Customer Analysis----------------------------------------------------------------
# 1. How many unique customers placed orders?
SELECT COUNT(DISTINCT cust_id) AS total_customers
FROM orders;

#2. Which customers placed the highest number of orders?
SELECT c.cust_name,
       COUNT(o.ord_id) AS total_orders
FROM customers c
JOIN orders o
ON c.cust_id = o.cust_id
GROUP BY c.cust_name
ORDER BY total_orders DESC;

#What is the total and average purchase value per customer?
SELECT 
    c.cust_id,
    c.cust_name,
    SUM(od.total_price) AS total_purchase_value,
    AVG(od.total_price) AS average_purchase_value
FROM customers c
JOIN orders o
    ON c.cust_id = o.cust_id
JOIN order_details od
    ON o.ord_id = od.ord_id
GROUP BY c.cust_id, c.cust_name
ORDER BY total_purchase_value DESC;

#Who are the top 5 customers by total purchase amount? 
SELECT 
    c.cust_id,
    c.cust_name,
    SUM(od.total_price) AS total_purchase_amount
FROM customers c
JOIN orders o
    ON c.cust_id = o.cust_id
JOIN order_details od
    ON o.ord_id = od.ord_id
GROUP BY c.cust_id, c.cust_name
ORDER BY total_purchase_amount DESC
LIMIT 5;
--  2. Product Performance ----------------------------------------------
-- How many products exist in each category? 
SELECT 
    c.cat_name,
    COUNT(p.prod_id) AS total_products
FROM categories c
JOIN products p
    ON c.cat_id = p.cat_id
GROUP BY c.cat_name
ORDER BY total_products DESC;

-- What is the average price of products by category?
SELECT 
    c.cat_name,
    AVG(p.price) AS average_price
FROM categories c
JOIN products p
    ON c.cat_id = p.cat_id
GROUP BY c.cat_name
ORDER BY average_price DESC;

-- Which products have the highest total sales volume (by quantity)?
SELECT 
    p.prod_name,
    SUM(od.quantity) AS total_quantity_sold
FROM products p
JOIN order_details od
    ON p.prod_id = od.prod_id
GROUP BY p.prod_name
ORDER BY total_quantity_sold DESC;

-- What is the total revenue generated by each product?
SELECT 
    p.prod_name,
    SUM(od.total_price) AS total_revenue
FROM products p
JOIN order_details od
    ON p.prod_id = od.prod_id
GROUP BY p.prod_name
ORDER BY total_revenue DESC;

--  How do product sales vary by category and supplier?
SELECT 
    c.cat_name,
    s.sup_name,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.total_price) AS total_revenue
FROM order_details od
JOIN products p
    ON od.prod_id = p.prod_id
JOIN categories c
    ON p.cat_id = c.cat_id
JOIN supplier s
    ON p.sup_id = s.sup_id
GROUP BY c.cat_name, s.sup_name
ORDER BY total_revenue DESC;

-- 3. Sales and Order Trends ------------------------------------------------

-- How many orders have been placed in total?
SELECT COUNT(ord_id) AS total_orders
FROM orders;

-- What is the average value per order?
SELECT 
    AVG(total_price) AS average_order_value
FROM order_details;

SELECT 
    AVG(order_total) AS average_order_value
FROM
(
    SELECT ord_id,
           SUM(total_price) AS order_total
    FROM order_details
    GROUP BY ord_id
) AS order_summary;

-- On which dates were the most orders placed?
SELECT 
    order_date,
    COUNT(ord_id) AS total_orders
FROM orders
GROUP BY order_date
ORDER BY total_orders DESC;

-- What are the monthly trends in order volume and revenue?
SELECT 
    MONTH(STR_TO_DATE(o.order_date, '%Y-%m-%d')) AS month,
    COUNT(DISTINCT o.ord_id) AS total_orders,
    SUM(od.total_price) AS total_revenue
FROM orders o
JOIN order_details od
    ON o.ord_id = od.ord_id
GROUP BY month
ORDER BY month;

-- How do order patterns vary across weekdays and weekends?
SELECT 
    CASE 
        WHEN DAYOFWEEK(STR_TO_DATE(order_date, '%Y-%m-%d')) IN (1,7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    
    COUNT(ord_id) AS total_orders
FROM orders
GROUP BY day_type;

-- SUPPLIER CONTRIBUTION ANALYSIS--------------------------------------------
-- How many suppliers are there in the database?
SELECT COUNT(sup_id) AS total_suppliers
FROM supplier;
-- Which supplier provides the most products?
SELECT 
    s.sup_name,
    COUNT(p.prod_id) AS total_products
FROM supplier s
JOIN products p
    ON s.sup_id = p.sup_id
GROUP BY s.sup_name
ORDER BY total_products DESC;
-- What is the average price of products from each supplier?
SELECT 
    s.sup_name,
    AVG(p.price) AS average_product_price
FROM supplier s
JOIN products p
    ON s.sup_id = p.sup_id
GROUP BY s.sup_name
ORDER BY average_product_price DESC;

-- Which suppliers contribute the most to total product sales (by revenue)?
SELECT 
    s.sup_name,
    SUM(od.total_price) AS total_revenue
FROM supplier s
JOIN products p
    ON s.sup_id = p.sup_id
JOIN order_details od
    ON p.prod_id = od.prod_id
GROUP BY s.sup_name
ORDER BY total_revenue DESC;

-- ADVANCED BUSINESS QUESTIONS -----------------------------------------------------

-- Rank Customers Based on Total Spending
SELECT 
    c.cust_name,
    
    SUM(od.total_price) AS total_spending,

    RANK() OVER (
        ORDER BY SUM(od.total_price) DESC
    ) AS customer_rank

FROM customers c

JOIN orders o
    ON c.cust_id = o.cust_id

JOIN order_details od
    ON o.ord_id = od.ord_id

GROUP BY c.cust_name;

-- Find Products Performing Above Average Revenue
SELECT 
    p.prod_name,
    SUM(od.total_price) AS total_revenue

FROM products p

JOIN order_details od
    ON p.prod_id = od.prod_id

GROUP BY p.prod_name

HAVING SUM(od.total_price) >
(
    SELECT AVG(product_revenue)
    
    FROM
    (
        SELECT 
            SUM(total_price) AS product_revenue
        FROM order_details
        GROUP BY prod_id
    ) AS revenue_data
);

-- Categorize Orders into High, Medium, and Low Value
SELECT 
    ord_id,
    total_price,

    CASE
        WHEN total_price >= 2000 THEN 'High Value'
        WHEN total_price >= 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_category

FROM order_details;

-- Find Top-Selling Product in Each Category
WITH product_sales AS
(
    SELECT 
        c.cat_name,
        p.prod_name,
        
        SUM(od.quantity) AS total_quantity,

        RANK() OVER
        (
            PARTITION BY c.cat_name
            ORDER BY SUM(od.quantity) DESC
        ) AS product_rank

    FROM products p

    JOIN categories c
        ON p.cat_id = c.cat_id

    JOIN order_details od
        ON p.prod_id = od.prod_id

    GROUP BY c.cat_name, p.prod_name
)

SELECT *
FROM product_sales
WHERE product_rank = 1;

-- Find Customers Spending Above Average
WITH customer_spending AS
(
    SELECT 
        c.cust_name,
        SUM(od.total_price) AS total_spending

    FROM customers c

    JOIN orders o
        ON c.cust_id = o.cust_id

    JOIN order_details od
        ON o.ord_id = od.ord_id

    GROUP BY c.cust_name
)

SELECT *
FROM customer_spending

WHERE total_spending >
(
    SELECT AVG(total_spending)
    FROM customer_spending
);
-- Employee Performance Analysis--------------------------------------------------
-- How many employees have processed orders?
SELECT 
    COUNT(DISTINCT emp_id) AS total_employees_processed_orders
FROM orders;
-- Which employees handled the most orders?
SELECT 
    e.emp_name,
    COUNT(o.ord_id) AS total_orders_handled
FROM employees e
JOIN orders o
    ON e.emp_id = o.emp_id
GROUP BY e.emp_name
ORDER BY total_orders_handled DESC;
-- Total sales value processed by each employee
SELECT 
    e.emp_name,
    SUM(od.total_price) AS total_sales_value
FROM employees e

JOIN orders o
    ON e.emp_id = o.emp_id

JOIN order_details od
    ON o.ord_id = od.ord_id

GROUP BY e.emp_name
ORDER BY total_sales_value DESC;

-- Average order value handled per employee
SELECT 
    e.emp_name,
    AVG(order_total) AS average_order_value
FROM employees e

JOIN
(
    SELECT 
        o.emp_id,
        o.ord_id,
        SUM(od.total_price) AS order_total

    FROM orders o

    JOIN order_details od
        ON o.ord_id = od.ord_id

    GROUP BY o.emp_id, o.ord_id
) AS employee_orders

ON e.emp_id = employee_orders.emp_id

GROUP BY e.emp_name
ORDER BY average_order_value DESC;
-- What is the relationship between quantity ordered and total price?
SELECT 
    quantity,
    total_price
FROM order_details
ORDER BY quantity;

SELECT 
    quantity,
    AVG(total_price) AS average_total_price
FROM order_details
GROUP BY quantity
ORDER BY quantity;

-- What is the average quantity ordered per product?
SELECT 
    p.prod_name,
    AVG(od.quantity) AS average_quantity_ordered
FROM products p

JOIN order_details od
    ON p.prod_id = od.prod_id

GROUP BY p.prod_name
ORDER BY average_quantity_ordered DESC;
-- How does the unit price vary across products and orders?
SELECT 
    p.prod_name,
    od.ord_id,
    od.each_price
FROM products p

JOIN order_details od
    ON p.prod_id = od.prod_id

ORDER BY p.prod_name;

SELECT 
    p.prod_name,
    MIN(od.each_price) AS minimum_price,
    MAX(od.each_price) AS maximum_price,
    AVG(od.each_price) AS average_price
FROM products p

JOIN order_details od
    ON p.prod_id = od.prod_id

GROUP BY p.prod_name
ORDER BY average_price DESC;

-- FINAL PERFECT 15 PPT QUERIES --------------------------------

-- 1. Top 5 Customers by Spending
SELECT c.cust_name,
SUM(od.total_price) AS total_spending
FROM customers c
JOIN orders o
ON c.cust_id=o.cust_id
JOIN order_details od
ON o.ord_id=od.ord_id
GROUP BY c.cust_name
ORDER BY total_spending DESC
LIMIT 5;
-- 2. Rank Customers by Spending
SELECT c.cust_name,
SUM(od.total_price) AS total_spending,
RANK() OVER(
ORDER BY SUM(od.total_price) DESC
) AS customer_rank
FROM customers c
JOIN orders o
ON c.cust_id=o.cust_id
JOIN order_details od
ON o.ord_id=od.ord_id
GROUP BY c.cust_name
limit 10;
-- 3. Products with Highest Sales Quantity
SELECT p.prod_name,
SUM(od.quantity) AS total_quantity
FROM products p
JOIN order_details od
ON p.prod_id=od.prod_id
GROUP BY p.prod_name
ORDER BY total_quantity DESC
limit 10;
-- 4. Revenue Generated by Each Product
SELECT p.prod_name,
SUM(od.total_price) AS revenue
FROM products p
JOIN order_details od
ON p.prod_id=od.prod_id
GROUP BY p.prod_name
ORDER BY revenue DESC;

-- 5. Top Product in Each Category
SELECT c.cat_name,
p.prod_name,
SUM(od.quantity) AS total_sales
FROM products p
JOIN categories c
ON p.cat_id=c.cat_id
JOIN order_details od
ON p.prod_id=od.prod_id
GROUP BY c.cat_name,p.prod_name
ORDER BY total_sales DESC;
-- 6. Monthly Revenue Trend
SELECT MONTH(order_date) AS month,
SUM(od.total_price) AS revenue
FROM orders o
JOIN order_details od
ON o.ord_id=od.ord_id
GROUP BY month;
-- 7. Weekend vs Weekday Orders
SELECT 
CASE
WHEN DAYOFWEEK(order_date)
IN (1,7)
THEN 'Weekend'
ELSE 'Weekday'
END AS day_type,
COUNT(*) AS total_orders
FROM orders
GROUP BY day_type;
-- 8. Supplier with Highest Revenue
SELECT s.sup_name,
SUM(od.total_price) AS revenue
FROM supplier s
JOIN products p
ON s.sup_id=p.sup_id
JOIN order_details od
ON p.prod_id=od.prod_id
GROUP BY s.sup_name
ORDER BY revenue DESC;

-- 9. Employee Handling Most Orders
SELECT e.emp_name,
COUNT(o.ord_id) AS total_orders
FROM employees e
JOIN orders o
ON e.emp_id=o.emp_id
GROUP BY e.emp_name
ORDER BY total_orders DESC;

-- 10. Rank Employees by Sales
SELECT e.emp_name,
SUM(od.total_price) AS total_sales,
RANK() OVER(
ORDER BY SUM(od.total_price) DESC
) AS emp_rank
FROM employees e
JOIN orders o
ON e.emp_id=o.emp_id
JOIN order_details od
ON o.ord_id=od.ord_id
GROUP BY e.emp_name;
-- 11. Products Above Average Price
SELECT prod_name,price
FROM products
WHERE price >
(
SELECT AVG(price)
FROM products
);
-- 12. High & Low Value Orders
SELECT ord_id,
total_price,

CASE
WHEN total_price>=2000
THEN 'High Value'
ELSE 'Low Value'
END AS order_type
FROM order_details;

-- 13. Average Quantity Ordered Per Product
SELECT p.prod_name,
AVG(od.quantity) AS avg_quantity
FROM products p
JOIN order_details od
ON p.prod_id=od.prod_id
GROUP BY p.prod_name;
-- 14. Category Wise Product Count
SELECT c.cat_name,
COUNT(p.prod_id) AS total_products
FROM categories c
JOIN products p
ON c.cat_id=p.cat_id
GROUP BY c.cat_name;
-- 15. Customers with More Than 5 Orders
SELECT c.cust_name,
COUNT(o.ord_id) AS total_orders
FROM customers c
JOIN orders o
ON c.cust_id=o.cust_id
GROUP BY c.cust_name
HAVING total_orders > 5;

-- Which product has the highest sales in each category?
WITH product_sales AS
(
SELECT c.cat_name,
       p.prod_name,
       SUM(od.quantity) AS total_sales,

RANK() OVER(
PARTITION BY c.cat_name
ORDER BY SUM(od.quantity) DESC
) AS product_rank

FROM products p
JOIN categories c
ON p.cat_id=c.cat_id
JOIN order_details od
ON p.prod_id=od.prod_id

GROUP BY c.cat_name,p.prod_name
)

SELECT *
FROM product_sales
WHERE product_rank = 1;

/*-- Recommendations (VERY IMPORTANT) SLIDE --------------------------------
• Focus on retaining high-value customers through loyalty programs.

• Maintain higher inventory for top-selling products.

• Increase promotions during high-sales periods.

• Strengthen partnerships with high-performing suppliers.

• Provide incentives for top-performing employees.

• Monitor low-performing products and optimize pricing strategies.
*/
/*
Conclusions Slide
• Top customers contribute a significant portion of total revenue.

• Certain products and categories consistently generate higher sales.

• Weekend order volume is higher compared to weekdays.

• Some suppliers contribute more revenue than others.

• Employee performance varies based on order handling and sales value.

• Product demand differs across categories and purchasing patterns.
*/

/*
The Grocery Store Management analysis successfully transformed raw transactional data 
into meaningful business insights using SQL. 

The analysis identified high-value customers, top-selling products, revenue-generating 
suppliers, and employee performance trends. It also revealed important sales patterns 
such as monthly revenue trends and customer purchasing behavior.

By applying SQL concepts such as JOINs, GROUP BY, HAVING, CASE statements, Subqueries,
Window Functions, and CTEs, the project provided a comprehensive understanding of the 
grocery store’s operations.

Overall, this analysis helps the business make data-driven decisions related to 
inventory management, customer retention, supplier evaluation, employee productivity, 
and sales optimization.
*/

/*
• Focus on retaining high-value customers by providing loyalty programs, discounts, 
and personalized offers.

• Maintain sufficient inventory for top-selling products to avoid stock shortages 
during high-demand periods.

• Increase promotional activities for low-performing products and categories to 
improve sales.

• Strengthen partnerships with suppliers contributing higher revenue and better 
product performance.

• Monitor employee performance regularly and provide incentives to high-performing 
employees.

• Analyze weekend and peak sales trends to improve staffing and inventory planning.

• Review pricing strategies for products with low sales performance and optimize them
 based on customer demand.

• Use monthly sales trends to plan seasonal offers and improve overall business 
profitability.
*/
