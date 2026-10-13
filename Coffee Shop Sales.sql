-- 1. Create the Compute Engine
CREATE WAREHOUSE coffee_wh WITH WAREHOUSE_SIZE = 'XSMALL'

-- 2. Create the Storage Area
CREATE DATABASE coffee_db;
CREATE SCHEMA coffee_schema;

-- Tell Snowflake to use the workspace we just built
USE WAREHOUSE coffee_wh;
USE DATABASE coffee_db;
USE SCHEMA coffee_schema;

-- Create our table
CREATE TABLE sales(order_id INT, customer_name STRING, order_details VARIANT);

-- Insert some sample data (using PARSE_JSON to simulate web data)
INSERT INTO sales(order_id, customer_name, order_details)
SELECT 1, 'Alice', PARSE_JSON('{"item": "Caramel Latte", "price": "5.50"}')

INSERT INTO sales(order_id, customer_name, order_details)
SELECT 2, 'Bob', PARSE_JSON('{"item": "Black Coffee", "price": "3.00"}')

SELECT * FROM sales


SELECT order_id,
       customer_name,
       -- Go into the JSON and pull out the 'item' as a String
       order_details:item::STRING AS coffee_type,
       -- Go into the JSON and pull out the 'price' as a Number
       order_details:price::FLOAT AS price
FROM sales
"""
Imagine you are tired and you accidentally overwrite everyone's name in the database because you forgot the WHERE clause.
"""
-- The Mistake: This changes EVERY name to 'UNKNOWN'
UPDATE sales
SET customer_name = 'UNKNOWN'

"""
Because Snowflake saves your data in immutable (unchangeable) blocks, your old data wasn't actually destroyed. We can use Time Travel to look 5 minutes into the past and fix it.
"""
-- Query the data exactly as it looked 5 minutes (300 seconds) ago
SELECT * FROM sales AT(OFFSET => -300);

-- To fix the table, we can just replace it with the past version
CREATE OR REPLACE TABLE sales AS
SELECT * FROM sales AT(OFFSET => -300);