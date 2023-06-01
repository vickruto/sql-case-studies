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

