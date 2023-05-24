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

use data_mart;

-- 2. Data Exploration
-- 1. What day of the week is used for each week_date value?
-- :: the data consists of aggregated slices of the underlying sales data rolled up into a common day of the week which represents the start of the sales week.

select distinct dayname(week_date) as `start day of the sales week`
from clean_weekly_sales;

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

with total_monthly_sales as (
	select month_number, count(*) as total_transactions 
	from clean_weekly_sales 
	group by month_number), 
	
     monthly_retail_sales as (
	select month_number, count(*) as retail_transactions 
	from clean_weekly_sales 
	where platform like '%Retail%'
	group by month_number),

     monthly_shopify_sales as (
	select month_number, count(*) as shopify_transactions 
	from clean_weekly_sales 
	where platform like '%Shopify%'
	group by month_number)


select month_number as month,
       concat(round(retail_transactions/total_transactions*100,2), '%') as `Retail transactions`,
       concat(round(shopify_transactions/total_transactions*100,2), '%') as `Shopify transactions`
from total_monthly_sales
join monthly_retail_sales using (month_number)
join monthly_shopify_sales using (month_number)
order by month_number;

-- 7. What is the percentage of sales by demographic for each year in the dataset?

with total_annual_sales as (
	select calendar_year, count(*) as total_sales
	from clean_weekly_sales 
	group by calendar_year), 
	
     couples_annual_sales as (
	select calendar_year, count(*) as couples_sales 
	from clean_weekly_sales 
	where demographic like '%Couples%'
	group by calendar_year),

     families_annual_sales as (
	select calendar_year, count(*) as families_sales 
	from clean_weekly_sales 
	where demographic like '%Families%'
	group by calendar_year),
	
     unknown_demographic_annual_sales as (
	select calendar_year, count(*) as unknown_sales 
	from clean_weekly_sales 
	where demographic is null
	group by calendar_year)
	
select calendar_year as Year,
       concat(round(couples_sales/total_sales*100,2), '%') as `Couples Sales`,
       concat(round(families_sales/total_sales*100,2), '%') as `Families Sales`,
       concat(round(unknown_sales/total_sales*100,2), '%') as `Unknown demographic Sales`
from total_annual_sales
join couples_annual_sales using (calendar_year)
join families_annual_sales using (calendar_year)
join unknown_demographic_annual_sales using (calendar_year)
order by calendar_year;

-- 8. Which age_band and demographic values contribute the most to Retail sales?

select * 
from 
	(select demographic 
	from clean_weekly_sales 
	where platform like '%Retail%' 
	group by demographic 
	order by count(*) desc limit 1) as d
join 
	(select age_band 
	from clean_weekly_sales 
	where platform like '%Retail%' 
	group by age_band 
	order by count(*) desc limit 1) as a


-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
-- it is possible to use the avg_transaction column to calculate the annual transaction size for each year by using the transactions column for weighting the average.

with annual_avg_retail_transaction_size as (
	select calendar_year, sum(transactions*avg_transaction)/sum(transactions) as  avg_retail_transaction_size
	from clean_weekly_sales
	where platform like '%Retail%' 
	group by calendar_year),

     annual_avg_shopify_transaction_size as (
	select calendar_year, sum(transactions*avg_transaction)/sum(transactions) as  avg_shopify_transaction_size
	from clean_weekly_sales
	where platform like '%Shopify%' 
	group by calendar_year)
select calendar_year as Year,
       avg_retail_transaction_size as `Avg Retail transaction size`,
       avg_shopify_transaction_size as `Avg Shopify transaction size`
from annual_avg_retail_transaction_size
join annual_avg_shopify_transaction_size
using (calendar_year)
;

