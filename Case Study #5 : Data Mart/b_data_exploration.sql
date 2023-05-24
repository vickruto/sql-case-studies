/*
2. Data Exploration
1. What day of the week is used for each week_date value?
2. What range of week numbers are missing from the dataset?
3. How many total transactions were there for each year in the dataset?
4. What is the total sales for each region for each month?
5. What is the total count of transactions for each platform
6. What is the percentage of sales for Retail vs Shopify for each month?
7. What is the percentage of sales by demographic for each year in the dataset?
8. Which age_band and demographic values contribute the most to Retail sales?
9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
*/

-- 2. Data Exploration
-- 1. What day of the week is used for each week_date value?


-- 2. What range of week numbers are missing from the dataset?

-- availabe week_numbers ::
select distinct week_number from clean_weekly_sales order by week_number

-- 3. How many total transactions were there for each year in the dataset?

select calendar_year, count(*) as `number of transactions` 
from clean_weekly_sales 
group by calendar_year;

-- 4. What is the total sales for each region for each month?

select month_number, 
       region, 
       count(*) as `number of transactions` 
from clean_weekly_sales 
group by month_number, region 
order by region, month_number;

-- 5. What is the total count of transactions for each platform

select platform, 
       count(*) as `number of transactions` 
from clean_weekly_sales group by platform;

-- 6. What is the percentage of sales for Retail vs Shopify for each month?



-- 7. What is the percentage of sales by demographic for each year in the dataset?



-- 8. Which age_band and demographic values contribute the most to Retail sales?



-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?




