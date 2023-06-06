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

create view filtered_interest_metrics 
as 
	select im.*
	from interest_metrics im
	join (select interest_id, 
	      count(distinct month_year) as num_months 
	      from interest_metrics group by interest_id) as x 
	using (interest_id) 
	where num_months >= 6 and month_year is not null
;

-- TOP 10 INTERESTS BY COMPOSITION
with max_composition_filtered_interest_metrics as (
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
with min_composition_filtered_interest_metrics as (
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
	
select interest_name, round(avg(ranking),2) as avg_ranking
from filtered_interest_metrics f 
join interest_map m on m.id = f.interest_id 
group by interest_name 
order by avg_ranking desc
limit 5;

-- 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

select distinct interest_id, interest_name , stddev(percentile_ranking) over(partition by interest_id) as std_deviation 
from filtered_interest_metrics f 
join interest_map m on m.id = f.interest_id  
order by std_deviation desc
limit 5;

-- 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?

with largest_std_dev_table as (
	select distinct interest_id, interest_name , stddev(percentile_ranking) over(partition by interest_id) as std_deviation 
	from filtered_interest_metrics f 
	join interest_map m on m.id = f.interest_id  
	order by std_deviation desc
	limit 5),

     min_max_perc_rnk as (
        select interest_id, interest_name, min(percentile_ranking) as min_perc, max(percentile_ranking) as max_perc
	from largest_std_dev_table 
	join interest_metrics using (interest_id)
	group by interest_id, interest_name)

select perc.interest_id, 
       perc.interest_name, 
       concat(perc.min_perc, '   (', immin.month_year, ')') as `min percentile_ranking (month_year)`, 
       concat(perc.max_perc, '   (', immax.month_year, ')') as `max percentile_ranking (month_year)`
from min_max_perc_rnk perc
join interest_metrics immin
 on immin.interest_id = perc.interest_id and immin.percentile_ranking = perc.min_perc
join interest_metrics immax
 on immax.interest_id = perc.interest_id and immax.percentile_ranking = perc.max_perc;

/*************************************************************************************************

*************************************************************************************************/

-- 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?
