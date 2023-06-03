/*
Data Exploration and Cleansing
1. Update the `fresh_segments.interest_metrics` table by modifying the `month_year` column to be a date data type with the start of the month
2. What is count of records in the `fresh_segments.interest_metrics` for each `month_year` value sorted in chronological order (earliest to latest) with the null values appearing first?
3. What do you think we should do with these null values in the `fresh_segments.interest_metrics`
4. How many `interest_id` values exist in the `fresh_segments.interest_metrics` table but not in the `fresh_segments.interest_map` table? What about the other way around?
5. Summarise the `id` values in the `fresh_segments.interest_map` by its total record count in this table
6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where `interest_id = 21246` in your joined output and include all columns from `fresh_segments.interest_metrics` and all columns from `fresh_segments.interest_map` except from the `id` column.
7. Are there any records in your joined table where the `month_year` value is before the `created_at` value from the `fresh_segments.interest_map` table? Do you think these values are valid and why?
*/

use fresh_segments;

-- Data Exploration and Cleansing
-- 1. Update the `fresh_segments.interest_metrics` table by modifying the `month_year` column to be a date data type with the start of the month

alter table interest_metrics modify month_year varchar(10);
update interest_metrics set month_year = str_to_date(concat('01-', month_year), '%d-%m-%Y');
alter table interest_metrics modify month_year date;

-- 2. What is count of records in the `fresh_segments.interest_metrics` for each `month_year` value sorted in chronological order (earliest to latest) with the null values appearing first?

select month_year, count(*) as `Number of records` 
from interest_metrics 
group by month_year 
order by month_year;

-- 3. What do you think we should do with these null values in the `fresh_segments.interest_metrics`



-- 4. How many `interest_id` values exist in the `fresh_segments.interest_metrics` table but not in the `fresh_segments.interest_map` table? What about the other way around?

select count(interest_id) as "Number of `interest_id` values in `interest_metrics` missing in `interest_map`"
from (	select distinct interest_id 
	from interest_metrics 
	except select id as interest_id from interest_map) dt; 

select count(id) "Number of `id` values in `interest_map` missing in `interest_metrics`"
from (	select distinct id 
	from interest_map 
	except select interest_id as id from interest_metrics) dt; 

-- 5. Summarise the `id` values in the `fresh_segments.interest_map` by its total record count in this table

select count(distinct id) as "Number of unique `id` values" from interest_map;

-- 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where `interest_id = 21246` in your joined output and include all columns from `fresh_segments.interest_metrics` and all columns from `fresh_segments.interest_map` except from the `id` column.



-- 7. Are there any records in your joined table where the `month_year` value is before the `created_at` value from the `fresh_segments.interest_map` table? Do you think these values are valid and why?

-- This is one of the open ended questions that requires "additional thought and not just a coded solution", in Danny's words. To be able to answer the question, here are three useful queries to dig into the data. 
select count(*) as "Number of records where `month_year` is before `created_at`"
from interest_map mp 
join interest_metrics mt 
on mt.interest_id=mp.id 
where month_year<created_at;

select count(*) as "Number of records where `month_year` value's month is before `created_at` value's month"
from interest_map mp 
join interest_metrics mt 
on mt.interest_id=mp.id 
where month_year<created_at
  and month(month_year)<month(created_at);

select max(dayofmonth(mp.created_at)) as "Maximum day of month value in the `created_at` column where the `month_year` is before the `created_at`"
from interest_map mp 
join interest_metrics mt 
on mt.interest_id=mp.id 
where month_year<created_at;

/************************************************
There are 188 records in which the `month_year` value is before the `created_at` value in the dataset. However, all these `month_year` values are in the same month as the `created_at` values. Thus, these records are not invalid since the `month_year` value only represents the first day of any month in which client data was collected. Incredibly, all the `created_at` values in which the data for the same month was recorded were before the 18th day of the month. This makes sense since there were enough days before the end of the month to collect useful quantifiable data.
************************************************/
