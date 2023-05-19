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

