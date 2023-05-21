/*
D. Pricing and Ratings
1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
   - Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
 - customer_id
 - order_id
 - runner_id
 - rating
 - order_time
 - pickup_time
 - Time between order and pickup
 - Delivery duration
 - Average speed
 - Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
*/


-- D. Pricing and Ratings
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

select sum(num_delivered*unit_cost) as `total profit made to date ($)`
from
(select pizza_name, count(*) as num_delivered, 
       case when pizza_name like '%meatlovers%' then 12 when pizza_name like '%vegetarian%' then 10 end as unit_cost
from customer_orders_cleaned 
join runner_orders_cleaned using (order_id) 
join pizza_names using (pizza_id) 
where cancellation is null 
group by pizza_name) as x
;

-- 2. What if there was an additional $1 charge for any pizza extras?
--    - Add cheese is $1 extra

with prices_table as ( 
	select pizza_name, exclusions, extras,
	       case when pizza_name like '%meatlovers%' then 12 when pizza_name like '%vegetarian%' then 10 end as base_cost,
	       case when extras is null then 0
		    else char_length(extras) - char_length(replace(extras,',','')) + 1 
		end as num_extras
	from customer_orders_cleaned 
	join runner_orders_cleaned using (order_id) 
	join pizza_names using (pizza_id) 
	where cancellation is null),
	
     adjusted_prices_table as (
       select pizza_name, base_cost, num_extras, base_cost+num_extras*1 as adjusted_price
       from prices_table
     )

select sum(adjusted_price) as `total profit with new pricing model ($)`
from adjusted_prices_table
;

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

-- SCHEMA
drop table if exists ratings;
create table ratings (
  order_id int, 
  customer_id int,
  rating enum('1','2','3','4','5')
);

insert into ratings values 
  (1, 101, 2),
  (2, 101, NULL),
  (3, 102, 5),
  (4, 103, 4),
  (5, 104, NULL),
  (6, 101, NULL),
  (7, 105, 4),
  (8, 102, 3),
  (9, 103, NULL),
  (10, 104, 5);

/*
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
 - customer_id
 - order_id
 - runner_id
 - rating
 - order_time
 - pickup_time
 - Time between order and pickup
 - Delivery duration
 - Average speed
 - Total number of pizzas
*/

select customer_id, 
       order_id, 
       runner_id, 
       rating, 
       time(order_time) as order_time, 
       time(pickup_time) as pickup_time, 
       concat(timestampdiff(minute, order_time, pickup_time), ' minutes') as `Order to pickup time`, 
       duration,
       concat(round(distance/duration*60,1), ' km/h') as `Avg Speed`, 
       num_pizzas
from runner_orders_cleaned
join ratings using (order_id)
join (select order_id, customer_id, order_time, count(*) as num_pizzas from customer_orders_cleaned group by customer_id, order_id, order_time) as x using (order_id, customer_id)
where cancellation is null;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

select concat('$', round(sum(fixed_price-delivery_cost),2)) as `Total Amount left over after deliveries `
from
	(select order_id, 
	        distance*.30 as delivery_cost,
	        case when pizza_name like '%Meatlovers%' then 12 
		     when pizza_name like '%Vegetarian%' then 10 end as fixed_price
	from runner_orders_cleaned 
	join customer_orders_cleaned using (order_id) 
	join pizza_names using (pizza_id) 
	where cancellation is null) as x
;

