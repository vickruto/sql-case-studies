-- BONUS QUESTIONS :::
-- Join All The Things
-- Recreate specified table using sql joins 
select customer_id, 
       order_date, 
       product_name, 
       price, 
       case when join_date is NULL or order_date<join_date then 'N' else 'Y' end as member 
from sales 
join menu 
   using (product_id) 
left join members 
   using (customer_id) 
order by customer_id, order_date, product_name;

-- Rank All The Things
-- add product rank column only for members
select *,
       case when member='Y' then rank() over(partition by customer_id, member order by order_date, product_name) else NULL end as ranking
from 
	(select customer_id, 
	       order_date, 
	       product_name, 
	       price, 
	       case when join_date is NULL or order_date<join_date then 'N' else 'Y' end as member 
	from sales 
	join menu 
	   using (product_id) 
	left join members 
	   using (customer_id) 
	order by customer_id, order_date, product_name) as x
;

