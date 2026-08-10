# Retail Sales Analysis SQL Project

## Project Overview
This project demonstrates an end-to-end data analysis workflow using SQL (PostgreSQL). The objective is to analyze retail sales performance, clean raw transactional data, perform exploratory data analysis (EDA), and solve key business decision-making queries.

Through this project, key SQL skills are showcased, including database design, data cleaning, aggregation, group filtration, subqueries, CTEs, and window functions.

---

## Database Schema & Table Structure

```sql
CREATE DATABASE sql_project_p2;

DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
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
);
```

## Data Cleaning Workflow
Inspected the dataset for NULL values across critical financial and transactional columns and cleaned incomplete rows to maintain data integrity.

```sql
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
```

## Exploratory Data Analysis (EDA)
Key foundational metrics extracted during initial investigation:

- Total Sales Volume: Count of valid transaction records.
- Customer Reach: Count of unique customer IDs (COUNT(DISTINCT customer_id)).
- Product Diversity: Distinct product categories available in stock.

```sql
-- Total Transactions Count
SELECT COUNT(transactions_id) AS total_sales FROM retail_sales;

-- Unique Customers Count
SELECT COUNT(DISTINCT customer_id) AS total_unique_customers FROM retail_sales;

-- Product Categories
SELECT DISTINCT category FROM retail_sales;
```

## Key Business Analysis & Solutions

1. Specific Date Sales Tracking
Retrieve all recorded transactions executed on 2022-11-05.
```sql
SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05'
```

2. High-Quantity Clothing Sales (Nov-2022)Filter transactions in the 'Clothing' category with a quantity >= 4 during November 2022.
```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND quantity >= 4
  AND sale_date >= '2022-11-01' 
  AND sale_date < '2022-12-01'
```

3. Category Total Revenue & Order Count
Calculate overall sales performance metrics grouped per category.
```sql
SELECT 
    category,
    SUM(total_sale) AS total_sales,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category
```

4. Average Customer Age in 'Beauty' Category
Determine the average customer age purchasing from the Beauty category.
```sql
SELECT 
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty'
```

5. High-Value Transactions Filter
Extract all sales transactions exceeding a total value of 1,000.
```sql
SELECT * 
FROM retail_sales
WHERE total_sale > 1000
```

6. Demographics Breakdown per Category
Analyze transaction volume grouped by product category and customer gender.
```sql
SELECT 
    category,
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category
```

7. Highest Performing Month per Year (Window Function)
Identify the best-performing sales month for each year based on average monthly sales using RANK().
```sql
SELECT 
    year,
    month,
    avg_sales
FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year, 
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sales,
        RANK() OVER(
            PARTITION BY EXTRACT(YEAR FROM sale_date) 
            ORDER BY AVG(total_sale) DESC
        ) AS rank
    FROM retail_sales
    GROUP BY 1, 2
) AS t1
WHERE rank = 1
```

8. Top 5 Revenue-Generating Customers
Determine the top 5 customers ranked by cumulative expenditure.
```sql
SELECT 
    customer_id AS customer,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5;
```

9. Hourly Shift Sales Analysis 
Categorize orders into Morning, Afternoon, and Evening shifts using a Common Table Expression (CTE) and CASE evaluation.
```sql
WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) AS total_orders    
FROM hourly_sale
GROUP BY shift;
```


## Advanced SQL Concepts Applied

To go beyond simple querying, this project incorporates advanced database and data engineering practices:

**Analytical Window Functions:** Used `RANK() OVER (PARTITION BY ... ORDER BY ...)` instead of simple grouping to perform multi-level trend analysis without losing row-level context.
**CTE vs. Subquery Performance:** Utilized Common Table Expressions (`WITH` clauses) for complex time-series queries to improve code modularity, readability, and execution plan organization.
**Optimization-Aware Filtering:** Implemented explicit date-range filters (`sale_date >= '2022-11-01' AND sale_date < '2022-12-01'`) rather than scalar date functions, ensuring full utilization of index scans on date columns.
**Defensive Data Cleaning:** Validated multi-column `NULL` conditions prior to data manipulation to prevent skewed aggregate values (`AVG`, `SUM`).


## Key Business Insights

1 - Customer Segmentation: Demographic patterns help target specific age groups and genders for promotions (e.g., Beauty category demographics).

2 - Sales Trends: Window functions reveal peak monthly periods, supporting seasonal inventory preparation.

3 - Operational Optimization: Time-shift classification indicates peak shopping hours to optimize staffing and sales operations.
