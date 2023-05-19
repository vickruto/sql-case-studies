/* 
A. Pizza Metrics
1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?
*/

-- A. Pizza Metrics
-- 1. How many pizzas were ordered?

select count(*) as `total number of pizzas ordered` 
from runner_orders_cleaned;     

-- 2. How many unique customer orders were made?

select count(distinct order_id) as `number of unique customer orders` 
from customer_orders_cleaned;

-- 3. How many successful orders were delivered by each runner?

select runner_id, count(*) as `number of successful deliveries` 
from runner_orders_cleaned
where cancellation is null
group by runner_id;

-- 4. How many of each type of pizza was delivered?

select pizza_name, count(*) as `number of deliveries` 
from customer_orders 
join runner_orders_cleaned using (order_id)
join pizza_names using (pizza_id)
where cancellation is null
group by pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

select customer_id, pizza_name, count(*) as `number of deliveries` 
from customer_orders_cleaned 
join pizza_names using (pizza_id) 
group by customer_id, pizza_name 
order by customer_id, pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?

select max(num_pizzas) as `maximum number of pizzas delivered in a single order` 
from (select count(*) as num_pizzas 
      from customer_orders_cleaned 
      group by order_id) as x
;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
with changed_deliveries as (
	select customer_id, count(*) as `number of deliveres with changes` 
	from customer_orders_cleaned 
	where exclusions is not null or extras is not null
	group by customer_id), 
	
      unchanged_deliveries as (
        select customer_id, count(*) as `number of deliveres without changes` 
	from customer_orders_cleaned 
	where exclusions is null and extras is null
	group by customer_id)

select * 
from changed_deliveries 
left join unchanged_deliveries
using (customer_id)
union all
select * 
from changed_deliveries 
right join unchanged_deliveries
using (customer_id)
;

-- 8. How many pizzas were delivered that had both exclusions and extras?

select count(*) as `orders with both extras and exclusions` 
from customer_orders_cleaned 
where exclusions is not null and extras is not null;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
-- As the deliveries are sparse through the hours of the day we only include the hours in which there were orders

select hour as `hour of day`, count(*) as `number of deliveries` 
from (select concat(hour(order_time),':00:00') as hour 
      from customer_orders_cleaned) as x 
group by hour order by hour;

-- 10. What was the volume of orders for each day of the week?
-- Just as in question 9 above, only days with orders are represented

select `day of week`, count(*) as `number of deliveries`
from(
    select dayname(pickup_time) as `day of week` 
    from runner_orders_cleaned 
    where pickup_time is not null) as x
group by `day of week`
;

