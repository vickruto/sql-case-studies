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

select interest_id, 
       month_year,
       interest_name,
       index_value,
       ranking,
       percentile_ranking,
       round(composition/index_value,2) as avg_composition 
from interest_metrics mt
join interest_map mp
on mt.interest_id = mp.id
order by avg_composition desc 
limit 10;

-- 2. For all of these top 10 interests - which interest appears the most often?



-- 3. What is the average of the average composition for the top 10 interests for each month?



-- 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.



--- 5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?



