/*
4. Bonus Question
Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
- region
- platform
- age_band
- demographic
- customer_type
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?
*/

use data_mart;
set @baseline_week_date := '2020-06-15';


--  Before and After Sales Per Region
select region,
       12_week_before_sales as `Sales Before`,
       12_week_after_sales as `Sales After`,
       concat(round((12_week_after_sales/12_week_before_sales*100 - 100),2), '%') as `Percentage Change`
from (
	select region, sum(sales) as 12_week_before_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between 1 and 12
	group by region) as b
join (
	select region, sum(sales) as 12_week_after_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between -11 and 0
	group by region) as a
using (region) ;


--  Before and After Sales Per Platform
select platform,
       12_week_before_sales as `Sales Before`,
       12_week_after_sales as `Sales After`,
       concat(round((12_week_after_sales/12_week_before_sales*100 - 100),2), '%') as `Percentage Change`
from (
	select platform, sum(sales) as 12_week_before_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between 1 and 12
	group by platform) as b
join (
	select platform, sum(sales) as 12_week_after_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between -11 and 0
	group by platform) as a
using (platform) ;


--  Before and After Sales Per Platform Age_band
select age_band,
       12_week_before_sales as `Sales Before`,
       12_week_after_sales as `Sales After`,
       concat(round((12_week_after_sales/12_week_before_sales*100 - 100),2), '%') as `Percentage Change`
from (
	select age_band, sum(sales) as 12_week_before_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between 1 and 12
	group by age_band) as b
join (
	select age_band, sum(sales) as 12_week_after_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between -11 and 0
	group by age_band) as a
using (age_band) ;


--  Before and After Sales Per Platform Demographic
select demographic,
       12_week_before_sales as `Sales Before`,
       12_week_after_sales as `Sales After`,
       concat(round((12_week_after_sales/12_week_before_sales*100 - 100),2), '%') as `Percentage Change`
from (
	select demographic, sum(sales) as 12_week_before_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between 1 and 12
	group by demographic) as b
join (
	select demographic, sum(sales) as 12_week_after_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between -11 and 0
	group by demographic) as a
using (demographic) ;


--  Before and After Sales Per Platform Customer_type
select customer_type,
       12_week_before_sales as `Sales Before`,
       12_week_after_sales as `Sales After`,
       concat(round((12_week_after_sales/12_week_before_sales*100 - 100),2), '%') as `Percentage Change`
from (
	select customer_type, sum(sales) as 12_week_before_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between 1 and 12
	group by customer_type) as b
join (
	select customer_type, sum(sales) as 12_week_after_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between -11 and 0
	group by customer_type) as a
using (customer_type) ;


