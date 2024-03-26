USE walmart;
SELECT * FROM sales;
-- Feature Engineering
-- Add a new column named day_time to give insight of sales in the Morning, Afternoon and Evening. 
-- This will help answer the question on which part of the day most sales are made.
SELECT time ,(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS day_time
FROM sales;

-- adding the new column to the table

ALTER TABLE sales ADD COLUMN day_time VARCHAR(20);

UPDATE sales SET day_time = (CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END);
-- Add a new column named day_name that contains the extracted days of the week on which the given transaction took place 
-- (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest.

SELECT Date , DAYNAME(Date) day_name FROM sales;
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales SET day_name = DAYNAME(Date);

-- Add a new column named month_name that contains the extracted months of the year on which the given transaction took place 
-- (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales SET month_name = MONTHNAME(Date);

-- Exploratoty Data Analysis
-- Unique cities
SELECT DISTINCT (City) FROM sales;

-- Which city is each branch
SELECT DISTINCT ('City'), Branch FROM sales;

-- How many unique product lines does the data have
ALTER TABLE sales RENAME COLUMN `Product line` TO Product_line;
SELECT COUNT(DISTINCT(Product_line)) AS Total_product_line FROM sales;

-- most common payment method
SELECT Payment , COUNT(Payment) AS cnt
FROM sales GROUP BY Payment 
ORDER BY cnt DESC LIMIT 1; 

-- most selling product line
SELECT Product_line , COUNT(Product_line) AS cnt
FROM sales GROUP BY Product_line 
ORDER BY cnt DESC;

-- total revenue by month
SELECT month_name, ROUND(SUM(Total),2) AS Revenue
FROM sales GROUP BY month_name 
ORDER BY Revenue DESC;

-- month having largest COGS
SELECT month_name, SUM(cogs) cogs FROM sales 
GROUP BY month_name 
ORDER BY cogs DESC;

-- product line had the largest revenue
SELECT Product_line,SUM(Total) Total_Revenue FROM sales 
GROUP BY Product_line 
ORDER BY Total_Revenue DESC;

-- City with the largest revenue
SELECT City,Branch,SUM(Total) Total_Revenue FROM sales 
GROUP BY City , Branch
ORDER BY Total_Revenue DESC;

-- product line had the largest tax
SELECT Product_line , AVG(`Tax 5%`)  AS avg_tax FROM sales
GROUP BY Product_line
ORDER BY avg_tax DESC ;

-- branch sold more products than average product sold
SELECT Branch , AVG(Quantity) avg_quantity FROM sales 
GROUP BY Branch 
HAVING avg_quantity > (SELECT AVG(Quantity) FROM sales);

-- most common product line by gender
SELECT Gender,Product_line,COUNT(Gender) cnt FROM sales 
GROUP BY Gender,Product_line 
ORDER BY cnt DESC;

-- average rating of each product line
SELECT Product_line,ROUND(AVG(Rating),2) AS avg_rating FROM sales 
GROUP BY Product_line 
ORDER BY avg_rating DESC;

-- Number of sales made in each time of the day per weekday
SELECT day_time,COUNT(*) total_sale FROM sales
WHERE day_name='Monday' 
GROUP BY day_time
ORDER BY total_sale DESC ;

-- Which of the customer types brings the most revenue
SELECT `Customer type`, SUM(Total) Total_Revenue FROM sales 
GROUP BY `Customer type`
ORDER BY Total_Revenue DESC;

-- Which city has the largest tax percent
SELECT City, AVG(`Tax 5%`) Total_Revenue FROM sales 
GROUP BY City
ORDER BY Total_Revenue DESC;

-- Which customer type pays the most in tax
SELECT `Customer type`, AVG(`Tax 5%`) Total_Revenue FROM sales 
GROUP BY `Customer type`
ORDER BY Total_Revenue DESC;

-- unique customer types
SELECT DISTINCT `Customer type` FROM sales;

-- unique payment methods
SELECT DISTINCT Payment FROM sales;

-- customer types buys most
SELECT `Customer type`, COUNT(*)cnt FROM sales
GROUP BY `Customer type`
ORDER BY cnt DESC;

-- gender of the most of the customers
SELECT Gender, COUNT(*)cnt FROM sales
GROUP BY Gender
ORDER BY cnt DESC;

-- gender distribution per branch
SELECT Branch, Gender, COUNT(*) count_gender FROM sales 
GROUP BY Branch, Gender
ORDER BY Branch;

-- Which time of the day do customers give most ratings
SELECT day_time, COUNT(*) cnt FROM sales
GROUP BY day_time
ORDER BY cnt;

-- Which time of the day do customers give most ratings per branch
WITH new_table AS 
(WITH max_cnt AS 
(SELECT Branch, day_time, COUNT(*) cnt FROM sales 
GROUP BY Branch, day_time)
SELECT Branch, day_time, cnt, RANK() OVER (PARTITION BY Branch ORDER BY cnt DESC) rnk FROM max_cnt) 
SELECT Branch, day_time, cnt FROM new_table WHERE rnk=1;

-- Which day of the week has the best average ratings per branch
SELECT  day_name,Branch,avg_rating FROM 
(SELECT t.* ,RANK() OVER(PARTITION BY day_name ORDER BY avg_rating DESC)rnk 
FROM 
(SELECT day_name, Branch, AVG(Rating) avg_rating FROM sales 
GROUP BY day_name, Branch
ORDER BY avg_rating DESC)t)t1
WHERE t1.rnk=1;




























