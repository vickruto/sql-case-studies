/*
B. Runner and Customer Experience
1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01 )
2. What was the average time in minutes it took for each runner to arrive at the Pizza
Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order
takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all
orders?
6. What was the average speed for each runner for each delivery and do you notice
any trend for these values?
7. What is the successful delivery percentage for each runner?
*/


-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01 )
select week, count(*) as `number of signups` 
from (
      select ceil((datediff(registration_date, '2021-01-01')+1)/7) as week
      from runners) as x
group by week
;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select runner_id, round(avg(timestampdiff(minute, order_time, pickup_time)),1) as `avg time(in min) to arrive at HQ`
from 
(select distinct order_id, order_time from customer_orders_cleaned) as x
right join 
(select order_id, runner_id, pickup_time from runner_orders_cleaned where pickup_time is not null) as y
using (order_id)
group by runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- We can assume that preparation time is the same as or proportional to the difference between the order time and the pickup time. We thus need to compare the time interval between order and pickup and the number of pizzas ordered to check the kind of relationship, if any.

with prep_time_comparison_table (order_id, num_pizzas, prep_time) as (
	select distinct order_id, num_pizzas, timestampdiff(minute, order_time, pickup_time) as `preparation time` 
	from (select order_id,count(*) as num_pizzas 
	      from customer_orders_cleaned 
	      group by order_id) as x
	join customer_orders_cleaned using (order_id)
	join (select order_id, pickup_time 
	      from runner_orders_cleaned 
	      where pickup_time is not null) as y
	 using (order_id)
	order by num_pizzas )
select num_pizzas as `number of pizzas`, avg(prep_time) as `average preparation time(mins)` 
from prep_time_comparison_table
group by num_pizzas
;

-- 4. What was the average distance travelled for each customer?

select customer_id, round(avg(distance),1) as `average distance to customer(km)` 
from (select distinct order_id, customer_id, distance 
      from runner_orders_cleaned 
      join customer_orders_cleaned using (order_id) 
      where distance is not null) as x
group by customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

select max(duration)-min(duration) as `difference between shortest and longest delivery times (mins)` from runner_orders_cleaned;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

select runner_id, 
       round(distance/duration*60,2) as `speed(km/h)`, 
       rank() over(partition by runner_id order by pickup_time) - 1 as `how many deliveries to date?` 
from runner_orders_cleaned 
where cancellation is null 
order by runner_id, pickup_time
;
-- There is a general upward trend of the delivery speeds with increasing number of deliveries ie the more pizzas a runner delivered the faster the consequent deliveries


-- 7. What is the successful delivery percentage for each runner?

select *, concat(round(successful_deliveries/total_deliveries*100,1), '% ') as `percentage successful deliveries` 
from 
    (select runner_id, count(*) as successful_deliveries 
    from runner_orders_cleaned 
    where cancellation is null 
    group by runner_id) as x
join 
   (select runner_id, count(*) as total_deliveries 
   from runner_orders_cleaned 
   group by runner_id) as y
using (runner_id)
;







