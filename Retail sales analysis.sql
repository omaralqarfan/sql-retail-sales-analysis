-- SQL Retail Sales Analysis 
CREATE DATABASE sql_project_p2;

-- Creating the table 
drop table if exists Retail_sales;
create table Retail_sales 
 		( 
		transactions_id INT PRIMARY KEY,
		sale_date DATE,
		sale_time TIME,
		customer_id INT,
		gender VARCHAR(15),
		age INT,
		category VARCHAR(15), 
		quantity INT,
		price_per_unit FLOAT,
		cogs FLOAT,
		total_sale FLOAT 
		)

-- Table
select*
from retail_sales



-- DATA CLEANING
-- Identify NULL values
SELECT * FROM retail_sales
WHERE 
    sale_time IS NULL OR transactions_id IS NULL OR sale_date IS NULL OR
    gender IS NULL OR category IS NULL OR quantity IS NULL OR
    cogs IS NULL OR total_sale IS NULL OR price_per_unit IS NULL

-- Remove incomplete records
DELETE FROM retail_sales
WHERE 
    sale_time IS NULL OR transactions_id IS NULL OR sale_date IS NULL OR
    gender IS NULL OR category IS NULL OR quantity IS NULL OR
    cogs IS NULL OR total_sale IS NULL OR price_per_unit IS NULL

-- Data exploration :

-- How many sales do we have?
Select count(transactions_id) as "total sales" from retail_sales

-- How many unique customers do we have?
select count(distinct customer_id) as "total sales" from retail_sales

-- How many categories do we have?
select count(distinct category) as "categories" from retail_sales

-- What are those categories?
select distinct category from retail_sales



-- Data Analysis & Business Key Problems : 

-- sales made on '2022-11-05' 
select *
from retail_sales
where sale_date = '2022-11-05'

-- all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND quantity >= 4
  AND sale_date >= '2022-11-01' 
  AND sale_date < '2022-12-01'

-- the total sales of each category
SELECT 
    category,
    SUM(total_sale) AS total_sales,
	count(*) AS total_orders
FROM retail_sales
GROUP BY category

-- the average age of customers who purchased items from the 'Beauty' category
SELECT 
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty'

-- all transactions where the total_sale is greater than 1000
SELECT * FROM retail_sales
WHERE total_sale > 1000

-- total number of transactions made by each gender in each category
select 
	category,
	gender,
	count(*)
from retail_sales
	group by category, gender
	order by category

-- the average sale for each month and best selling month in each year
select
	year,
	month,
	avg_sales
from
(select 
	extract(Year from sale_date) as Year, 
	extract(month from sale_date) as month,
	avg(total_sale) as avg_sales,
	rank() over(partition by extract(Year from sale_date) order by avg(total_sale) DESC ) as rank
from retail_sales
group by 1,2) as t1
where rank = 1

-- top 5 customers based on the highest total sales
select 
	customer_id as customer,
	sum(total_sale) as sales
from retail_sales
group by 1 
order by 2 DESC
limit 5


-- the number unique customers who purchased items from each category
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift


	


