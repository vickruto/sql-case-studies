/*
Index Analysis
The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.
Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.
1. What is the top 10 interests by the average composition for each month?
2. For all of these top 10 interests - which interest appears the most often?
3. What is the average of the average composition for the top 10 interests for each month?
4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?
*/

use fresh_segments; 

-- 1. What is the top 10 interests by the average composition for each month?

with avg_comp_table as (
	select *, 
	       round(composition/index_value,2) as avg_composition, 
	       rank() over(partition by month_year order by composition/index_value desc) as rnk
	from interest_metrics mt
	join interest_map mp
	on mt.interest_id = mp.id
	where month_year is not null)

select interest_id, 
       month_year,
       interest_name,
       index_value,
       ranking,
       percentile_ranking,
       round(composition/index_value,2) as avg_composition
from avg_comp_table 
where rnk <= 10
order by month_year, rnk;

-- 2. For all of these top 10 interests - which interest appears the most often?

with avg_comp_table as (
	select *, 
	       round(composition/index_value,2) as avg_composition, 
	       rank() over(partition by month_year order by composition/index_value desc) as rnk
	from interest_metrics mt
	join interest_map mp
	on mt.interest_id = mp.id
	where month_year is not null),

     top_10_avg_comp_by_month_table as (
	select interest_id, 
	       month_year,
	       interest_name,
	       index_value,
	       ranking,
	       percentile_ranking,
	       round(composition/index_value,2) as avg_composition
	from avg_comp_table 
	where rnk <= 10
	order by month_year, rnk)

select interest_name as `Interests with most occurence in top 10`, 
       interest_id,
       count(*) as `Number of occurences`
from top_10_avg_comp_by_month_table 
group by interest_name, interest_id
order by count(*) desc
limit 10;

/***************************************************************************
Three interests appear in the monthly top 10 interests in 10 of the 14 months in the dataset. These interests are :
     - Solar Energy Researchers
     - Alabama Trip Planners 
     - Luxury Bedding Shoppers
****************************************************************************/

-- 3. What is the average of the average composition for the top 10 interests for each month?



-- 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.



--- 5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?



