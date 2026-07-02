CREATE DATABASE retail_project;
USE retail_project;

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(30),
    segment VARCHAR(30),
    join_date VARCHAR(20)
);

-- Products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    brand VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    cost_price DECIMAL(10,2),
    selling_price DECIMAL(10,2)
);

-- Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date VARCHAR(20),
    ship_date VARCHAR(20),
    ship_mode VARCHAR(30),
    payment_mode VARCHAR(30)
);

-- Order_Details
CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    discount DECIMAL(5,2),
    sales DECIMAL(10,2),
    cost DECIMAL(10,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- Returns
CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    order_id INT,
    return_reason VARCHAR(100),
    return_date VARCHAR(20),
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

SELECT * FROM orders;

SET SQL_SAFE_UPDATES = 0;

SELECT * FROM orders;
UPDATE orders
SET ship_date = STR_TO_DATE(ship_date, '%m-%d-%y');
ALTER TABLE orders
MODIFY ship_date DATE;

SELECT * FROM customers;

UPDATE customers
SET join_date = STR_TO_DATE(join_date, '%m-%d-%y');
ALTER TABLE customers
MODIFY join_date DATE;

SELECT * FROM returns;

UPDATE returns
SET return_date = STR_TO_DATE(return_date, '%m-%d-%y');
ALTER TABLE returns
MODIFY return_date DATE;