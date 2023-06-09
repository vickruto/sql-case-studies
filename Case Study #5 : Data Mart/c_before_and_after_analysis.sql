/*
3. Before & After Analysis
This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before
Using this analysis approach - answer the following questions:
1. What is the total sales for the 4 weeks before and after 2020-06-15 ? What is the growth or reduction rate in actual values and percentage of sales?
2. What about the entire 12 weeks before and after?
3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
*/

use data_mart;
set @baseline_week_date := '2020-06-15';

-- 1. What is the total sales for the 4 weeks before and after 2020-06-15 ? What is the growth or reduction rate in actual values and percentage of sales?

select 
       4_week_before_sales as `Sales Before`,
       4_week_after_sales as `Sales After`,
       concat(round((4_week_after_sales/4_week_before_sales*100 - 100),2), '%') as `Percentage Change`
from (
	select sum(sales) as 4_week_before_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between 1 and 4) as b
join (
	select sum(sales) as 4_week_after_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between -3 and 0) as a
;

-- 2. What about the entire 12 weeks before and after?

select 
       12_week_before_sales as `Sales Before`,
       12_week_after_sales as `Sales After`,
       concat(round((12_week_after_sales/12_week_before_sales*100 - 100),2), '%') as `Percentage Change`
from (
	select sum(sales) as 12_week_before_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between 1 and 12) as b
join (
	select sum(sales) as 12_week_after_sales
	from clean_weekly_sales
	where timestampdiff(week, week_date, @baseline_week_date) between -11 and 0) as a
;

-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

-- a) Sale metrics for 4 weeks before and after the baseline week_date for all the years
select calendar_year as Year,
       4_week_before_sales as `Sales Before`,
       4_week_after_sales as `Sales After`,
       concat(round((4_week_after_sales/4_week_before_sales*100 - 100),2), '%') as `Percentage Change`
from (
	select calendar_year, sum(sales) as 4_week_before_sales
	from clean_weekly_sales
	where ceil(dayofyear(@baseline_week_date)/7)-week_number between 1 and 4
	group by calendar_year) as b
join (
	select calendar_year, sum(sales) as 4_week_after_sales
	from clean_weekly_sales
	where ceil(dayofyear(@baseline_week_date)/7)-week_number between -3 and 0
	group by calendar_year) as a
using (calendar_year)
;

-- b) Sale metrics for 12 weeks before and after the baseline week_date for all the years
select calendar_year as Year,
       12_week_before_sales as `Sales Before`,
       12_week_after_sales as `Sales After`,
       concat(round((12_week_after_sales/12_week_before_sales*100 - 100),2), '%') as `Percentage Change`
from (
	select calendar_year, sum(sales) as 12_week_before_sales
	from clean_weekly_sales
	where ceil(dayofyear(@baseline_week_date)/7)-week_number between 1 and 12
	group by calendar_year) as b
join (
	select calendar_year, sum(sales) as 12_week_after_sales
	from clean_weekly_sales
	where ceil(dayofyear(@baseline_week_date)/7)-week_number between -11 and 0
	group by calendar_year) as a
using (calendar_year)
;

