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

