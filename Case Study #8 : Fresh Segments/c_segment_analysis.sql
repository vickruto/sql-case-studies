/*
Segment Analysis
1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year ? Only use the maximum composition value for each interest but you must keep the corresponding month_year
2. Which 5 interests had the lowest average ranking value?
3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?
*/

use fresh_segments;

-- Segment Analysis
-- 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year ? Only use the maximum composition value for each interest but you must keep the corresponding month_year

-- TOP 10 INTERESTS BY COMPOSITION
with filtered_interest_metrics as (
	select im.*
	from interest_metrics im
	join (select interest_id, 
	      count(distinct month_year) as num_months 
	      from interest_metrics group by interest_id) as x 
	using (interest_id) 
	where num_months >= 6 and month_year is not null),

      max_composition_filtered_interest_metrics as (
	select * from (select *, rank() over(partition by interest_id order by composition desc) as rnk from filtered_interest_metrics) as x where rnk=1), 
      
      top_10_compositions_table as (
	select interest_id, month_year, interest_name, composition
	from max_composition_filtered_interest_metrics c
	join interest_map m 
	on m.id = c.interest_id
	order by composition desc
	limit 10)

select * from top_10_compositions_table; 

-- BOTTOM 10 INTERESTS BY COMPOSITION
with filtered_interest_metrics as (
	select im.*
	from interest_metrics im
	join (select interest_id, 
	      count(distinct month_year) as num_months 
	      from interest_metrics group by interest_id) as x 
	using (interest_id) 
	where num_months >= 6 and month_year is not null),

      min_composition_filtered_interest_metrics as (
	select * from (select *, rank() over(partition by interest_id order by composition asc) as rnk from filtered_interest_metrics) as x where rnk=1), 
      
      bottom_10_compositions_table as (
	select interest_id, month_year, interest_name, composition
	from min_composition_filtered_interest_metrics c
	join interest_map m 
	on m.id = c.interest_id
	order by composition asc
	limit 10)

select * from bottom_10_compositions_table; 

-- 2. Which 5 interests had the lowest average ranking value?

with filtered_interest_metrics as (
	select im.*
	from interest_metrics im
	join (select interest_id, 
	      count(distinct month_year) as num_months 
	      from interest_metrics group by interest_id) as x 
	using (interest_id) 
	where num_months >= 6 and month_year is not null)
	
select interest_name, round(avg(ranking),2) as avg_ranking
from filtered_interest_metrics f 
join interest_map m on m.id = f.interest_id 
group by interest_name 
order by avg_ranking
limit 5;

-- 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

with filtered_interest_metrics as (
	select im.*
	from interest_metrics im
	join (select interest_id, 
	      count(distinct month_year) as num_months 
	      from interest_metrics group by interest_id) as x 
	using (interest_id) 
	where num_months >= 6 and month_year is not null)

select distinct interest_id, interest_name , stddev(percentile_ranking) over(partition by interest_id) as std_deviation 
from filtered_interest_metrics f 
join interest_map m on m.id = f.interest_id  
order by std_deviation desc
limit 5;

-- 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?



-- 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?
