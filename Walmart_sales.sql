create database if not exists walmartsales;
use walmartsales;
create table if not exists sales(
					invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
                    branch VARCHAR(5) NOT NULL,
                    city VARCHAR(30) NOT NULL,
                    customer_type VARCHAR(30) NOT NULL,
                    gender VARCHAR(10) NOT NULL,
                    product_line VARCHAR(100) NOT NULL,
                    unit_price DECIMAL(10,2) NOT NULL,
                    quantity INT NOT NULL,
                    VAT FLOAT(6,4) NOT NULL,
                    total DECIMAL(12,4) NOT NULL,
                    date DATETIME NOT NULL,
                    time TIME NOT NULL,
                    payment_method VARCHAR(15) NOT NULL,
                    cogs DECIMAL(10,2) NOT NULL,
                    gross_margin_pct FLOAT(11,9),
                    gross_income DECIMAL(12,4) NOT NULL,
                    rating FLOAT(2,1)
);
select * from sales limit 10;

-- ----------------------------------------------------------------------------------
-- ---------------- Feature Engineering ---------------------------------------------

-- TIME OF DAY 
SELECT time, 
	   (CASE 
            WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
            WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
            ELSE "Evening"
		END) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE 
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
	END);
    
-- DAY NAME
SELECT date,DAYNAME(date) FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);

UPDATE sales
SET day_name = DAYNAME(date);

-- MONTH NAME
SELECT date,MONTHNAME(date) FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = MONTHNAME(date);

-- ------------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------------
-- ----------------------------- Generic ----------------------------------------------

-- How many unique cities does the data have?
SELECT
	DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM sales;

-- -----------------------------------------------------------------------------------
-- ----------------------------------- PRODUCT ---------------------------------------

-- How many unique product lines does the data have?
SELECT
	COUNT(DISTINCT product_line) AS Unique_Product_Lines
FROM sales;

-- What is the most common payment method?
SELECT
	payment_method,
	COUNT(payment_method) AS CNT
FROM sales
GROUP BY payment_method
ORDER BY CNT DESC;

-- What is the most selling product line?
SELECT
	product_line,
	COUNT(product_line) AS CNT
FROM sales
GROUP BY product_line
ORDER BY CNT DESC;

-- What is the total revenue by month?
SELECT 
	month_name AS month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT 
	month_name AS month,
    SUM(cogs) AS total_cogs
FROM sales
GROUP BY month
ORDER BY total_cogs DESC;

-- What product line has the largest revenue?
SELECT
	product_line,
    SUM(total) AS revenue
FROM sales
GROUP BY product_line
ORDER BY revenue DESC;

-- What is the city with the largest revenue?
SELECT
	city,
    SUM(total) AS revenue
FROM sales
GROUP BY city
ORDER BY revenue DESC;

-- What product line has the largest VAT?
SELECT
	product_line,
    AVG(VAT) AS avg_VAT
FROM sales
GROUP BY product_line
ORDER BY avg_VAT DESC;

-- Fetch each product line and add a column to those product line showing "Good","Bad". Good if its greater than avg sales


-- Which branch sold more products than average products sold?
SELECT 
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING qty > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS cnt
FROM sales
GROUP BY gender,product_line
ORDER BY cnt DESC;

-- What is the average rating of each product line?
SELECT
	product_line,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- -----------------------------------------------------------------------------------
-- ----------------------------------- Sales -----------------------------------------

-- Number of sales made in each time of the day per week day?
SELECT 
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
    SUM(total) AS revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue DESC;

-- Which city has the largest tax percent/VAT (Value Added Tax)?
SELECT
	city,
    AVG(VAT) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which customer type pays the most in VAT?
SELECT 
	customer_type,
    AVG(VAT) as avg_vat
FROM sales
GROUP BY customer_type
ORDER BY avg_vat DESC;


-- -----------------------------------------------------------------------------------
-- ----------------------------- Customer --------------------------------------------

-- How many unique customer types does the data have?
SELECT DISTINCT customer_type FROM sales;

-- How many unique payment methods does the data have?
SELECT DISTINCT payment_method FROM sales;

-- What is the most common customer type?
SELECT
	customer_type,
    COUNT(customer_type) AS cnt
FROM sales
GROUP BY customer_type
ORDER BY cnt DESC;

-- Which customer type buys the most?
SELECT 
	customer_type,
    COUNT(*) AS cstmr_cnt
FROM sales
GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT 
    gender, COUNT(*) AS gender_cnt
FROM
    sales
GROUP BY gender
ORDER BY gender_cnt DESC;


-- What is the gender distribution per branch?
SELECT 
    gender, COUNT(*) AS gender_cnt
FROM
    sales
WHERE branch = "A"
GROUP BY gender
ORDER BY gender_cnt DESC;

SELECT 
    gender, COUNT(*) AS gender_cnt
FROM
    sales
WHERE branch = "B"
GROUP BY gender
ORDER BY gender_cnt;

SELECT 
    gender, COUNT(*) AS gender_cnt
FROM
    sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt;

SELECT 
    branch, gender, COUNT(gender) AS cnt
FROM
    sales
GROUP BY branch , gender
ORDER BY branch;

-- Which time of day do the customers give more rating?
SELECT 
    time_of_day, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of day do the customers give more rating per branch?
SELECT 
    time_of_day, branch, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY time_of_day , branch
ORDER BY branch , avg_rating DESC;

-- Which day of the week has the best avg ratings?
SELECT 
    day_name, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 1;

-- Which day of the week has the best avg ratings per branch?
SELECT 
    day_name,branch, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY day_name,branch
ORDER BY branch,avg_rating DESC;

SELECT 
    day_name, AVG(rating) AS avg_rating
FROM
    sales
WHERE branch = "A"
GROUP BY day_name
ORDER BY avg_rating DESC;

-- 