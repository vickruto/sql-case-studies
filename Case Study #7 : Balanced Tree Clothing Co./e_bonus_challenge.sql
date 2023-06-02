/*
Bonus Challenge
Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.
Hint: you may want to consider using a recursive CTE to solve this problem!
*/

use balanced_tree;

-- Non-recursive solution 
select product_id, 
       price,
       concat(ph_stl.level_text, ' ', ph_seg.level_text, ' - ', ph_cat.level_text) as product_name,
       ph_cat.id as category_id,
       ph_seg.id as segment_id, 
       ph_stl.id as style_id, 
       ph_cat.level_text as category_name,
       ph_seg.level_text as segment_name, 
       ph_stl.level_text as style_name
from product_prices 
join product_hierarchy ph_stl using (id)
join product_hierarchy ph_seg on ph_stl.parent_id = ph_seg.id
join product_hierarchy ph_cat on ph_seg.parent_id = ph_cat.id
order by style_id;


-- RECURSIVE SOLUTION
with recursive cte as (
        select id,  
               id as category_id,
               cast(level_text as char(20)) as category_name,
               0 as segment_id, 
               cast(null as char(20)) as segment_name,
               0 as style_id, 
               cast(null as char(20)) as style_name, 
               1 as lvl
        from product_hierarchy 
        where parent_id is null
        union all
        select ph.id,
               cte.category_id,
               cte.category_name,
               case when ph.level_name='Segment' then ph.id else cte.segment_id end as segment_id,
               case when ph.level_name='Segment' then ph.level_text else cte.segment_name end as segment_name,
               case when ph.level_name='Style' then ph.id else cte.style_id end as style_id,
               case when ph.level_name='Style' then ph.level_text else cte.style_name end as style_name,
               lvl + 1 as lvl
        from cte
        join product_hierarchy ph
        on cte.id = ph.parent_id 
        where lvl < 4
        )
select product_id,
       price,
       concat(style_name, ' ', segment_name, ' - ', category_name) as product_name,
       category_id,
       segment_id,
       style_id,
       category_name,
       segment_name,
       style_name
from cte
join product_prices using (id);
