/*
Interest Analysis
1. Which interests have been present in all `month_year` dates in our dataset?
2. Using this same `total_months` measure - calculate the cumulative percentage of all records starting at 14 months - which `total_months` value passes the 90% cumulative percentage value?
3. If we were to remove all `interest_id `values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?
4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed `interest` example for your arguments - think about what it means to have less months present from a segment perspective.
5. After removing these interests - how many unique interests are there for each month?
*/

use fresh_segments; 

-- Interest Analysis
-- 1. Which interests have been present in all `month_year` dates in our dataset?

with x (total_months) as (
	select count(distinct month_year) from interest_metrics), 
	
     monthly_counts as (
	 select interest_id, count(distinct month_year) as num_months from interest_metrics group by interest_id order by count(distinct month_year)),

     interests as (
          select interest_id, num_months from monthly_counts join x where num_months=total_months)

select interest_name as "Some interests present in all `month_year` dates" 
from interests i 
join interest_map mp on i.interest_id=mp.id  
limit 10;

/*********************************
  There are 480 interests that have been present in all `month_year` dates in the dataset 
*********************************/

-- 2. Using this same `total_months` measure - calculate the cumulative percentage of all records starting at 14 months - which `total_months` value passes the 90% cumulative percentage value?

with interest_total_months as (
	select interest_id, count(distinct month_year) as total_months 
	from interest_metrics 
	where interest_id is not null 
	group by interest_id order by total_months desc), 

      x as (select *, round(percent_rank() over(order by total_months desc)*100, 2) as cumulative_percentage from interest_total_months)
      
select distinct total_months, cumulative_percentage from x;

/*********************************
 All total_months values above 6 months pass the 90% cumulative percentage value. 90.92% of all records involve interests which are present in more than 6 months 
*********************************/


-- 3. If we were to remove all `interest_id `values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?

select count(*) `Number of records with interests occuring in less than 6 months`
from interest_metrics 
join (select interest_id, 
      count(distinct month_year) as num_months 
      from interest_metrics group by interest_id) as x 
using (interest_id) 
where num_months < 6 ;

/*********************************
 There are 400 records from 110 interests which occur for less than 6 months of the 14 months in the dataset.  These 400 data points would be removed
*********************************/


-- 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed `interest` example for your arguments - think about what it means to have less months present from a segment perspective.



-- 5. After removing these interests - how many unique interests are there for each month?



