/*
C. Ingredient Optimisation
1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format
of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza
order from the customer_orders table and add a 2x in front of any relevant
ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by
most frequent first?
*/

USE pizza_runner;

-- C. Ingredient Optimisation
-- 1. What are the standard ingredients for each pizza?

select pizza_name, group_concat(topping_name separator ', ') as `standard ingredients` 
from pizza_toppings  
join pizza_recipes  
join pizza_names using (pizza_id)
where toppings rlike concat('(.+ |^)',topping_id,'(,+|$)') 
group by pizza_name;

-- 2. What was the most commonly added extra?

select topping_name as `most commonly added extra`
from(
	select topping_name, count(*) as counts
	from 
	   (select extras from customer_orders_cleaned except select NULL) as x
	    join pizza_toppings
	    where extras rlike concat('(.+ |^)',topping_id,'(,+|$)') 
	    group by topping_name) as y
order by counts desc
limit 1;

-- 3. What was the most common exclusion?

select topping_name as `most common exclusion`
from(
	select topping_name, count(*) as counts
	from 
	   (select exclusions from customer_orders_cleaned except select NULL) as x
	    join pizza_toppings
	    where exclusions rlike concat('(.+ |^)',topping_id,'(,+|$)') 
	    group by topping_name) as y
order by counts desc
limit 1;

/*
4. Generate an order item for each record in the customers_orders table in the format
of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
*/

with exclusions_descriptions as (
	select exclusions,
	       concat('Exclude ', group_concat(distinct topping_name order by topping_id separator ', ')) as exclusions_descr
	from customer_orders_cleaned 
	join pizza_toppings 
	where exclusions is not null 
	  and exclusions rlike concat('(.+ |^)',topping_id,'(,+|$)') 
	group by exclusions ),
      
      extras_descriptions as(
	select extras,
	       concat('Extra ', group_concat(distinct topping_name order by topping_id separator ', ')) as extras_descr
	from customer_orders_cleaned 
	join pizza_toppings 
	where extras is not null 
	  and extras rlike concat('(.+ |^)',topping_id,'(,+|$)') 
	group by extras )
	
select order_id, pizza_id, extras, exclusions,
       concat(pizza_name, coalesce(concat(' - ', exclusions_descr),''), coalesce(concat(' - ', extras_descr),'')) as `order item`
from customer_orders_cleaned 
join pizza_names using (pizza_id)
left join extras_descriptions using (extras)	
left join exclusions_descriptions using (exclusions);

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"


with unique_ingredients_combinations as (
	select distinct pizza_id, toppings, exclusions, extras 
	from customer_orders_cleaned 
	join pizza_recipes using (pizza_id)),
	
     ungrouped_ingredients as (
	select *, 
	      case when toppings rlike concat('(.+ |^)',topping_id,'(,+|$)') 
	           and extras rlike concat('(.+ |^)',topping_id,'(,+|$)') 
	       then concat('2x', topping_name) 
	       else topping_name end as ingredient
	from unique_ingredients_combinations
	join pizza_toppings
	where   (toppings rlike concat('(.+ |^)',topping_id,'(,+|$)') 
		 or extras rlike concat('(.+ |^)',topping_id,'(,+|$)'))
	   and  (exclusions not rlike concat('(.+ |^)',topping_id,'(,+|$)')
		 or exclusions is null)),
      
      grouped_ingredients as (
	select pizza_name, toppings, coalesce(extras,'') as extras , coalesce(exclusions,'') as exclusions,
	       group_concat(ingredient order by topping_id separator ', ') as ingredients
	from ungrouped_ingredients
	join pizza_names using (pizza_id)
	group by pizza_name, toppings, extras, exclusions),
      
      customer_toppings_preferences as (
	select order_id, toppings, coalesce(extras,'') as extras, coalesce(exclusions,'') as exclusions
	from customer_orders_cleaned as coc
	join pizza_recipes as pr using (pizza_id))

select order_id, concat(pizza_name, ':', ingredients) as order_description
from customer_toppings_preferences
left join grouped_ingredients using (toppings, extras, exclusions)
;

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

with order_toppings_table as (
	select order_id, exclusions, extras, toppings as standard_toppings
	from runner_orders_cleaned 
	join customer_orders_cleaned using(order_id)
	join pizza_recipes using (pizza_id)
	where cancellation is null),

     standard_toppings_count_table as (
	select topping_id, count(topping_id) as num_standard_toppings
	from order_toppings_table
	join pizza_toppings
	where standard_toppings rlike concat('(.+ |^)',topping_id,'(,+|$)') 
	group by topping_id),
	
     extras_count_table as (
	select topping_id, count(topping_id) as num_extras
	from order_toppings_table
	join pizza_toppings
	where extras rlike concat('(.+ |^)',topping_id,'(,+|$)') 
	group by topping_id),
	
     exclusions_count_table as (
	select topping_id, count(topping_id) as num_exclusions
	from order_toppings_table
	join pizza_toppings
	where exclusions rlike concat('(.+ |^)',topping_id,'(,+|$)') 
	group by topping_id),
	
     result_table as (
	select *, 
	       ( num_standard_toppings + 
		 coalesce(num_extras,0) - 
		 coalesce(num_exclusions,0)
	       ) as quantity_used
	from standard_toppings_count_table
	left join extras_count_table using(topping_id)
	left join exclusions_count_table using(topping_id)
	join pizza_toppings using (topping_id))

select topping_name, quantity_used
from result_table
order by quantity_used desc;

