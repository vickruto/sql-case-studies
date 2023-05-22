/*
B. Data Analysis Questions
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset -
use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the
breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned
rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what
percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at
2020-12-31 ?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the
day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days,
31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in
2020?
*/

USE foodie_fi;

-- B. Data Analysis Questions
-- 1. How many customers has Foodie-Fi ever had?

select count(distinct(customer_id)) from subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

select month_start, count(*) as trial_plan_subscriptions 
from (select concat(substring(start_date,1,char_length(start_date)-2),'01') as month_start 
      from subscriptions) as x 
group by month_start;

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

select plan_name, count(*) as `number of plan activations after 2020` 
from subscriptions 
join plans using (plan_id) 
where start_date >= '2021-01-01'
group by plan_name, plan_id
order by plan_id;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

with churns (total_customer_churns) as (
     select round(count(distinct customer_id),1) from subscriptions where plan_id = 4),
     customers (total_customers) as (
     select count(distinct customer_id) from subscriptions)

select concat(total_customer_churns, ' (', round(total_customer_churns/total_customers*100, 1), '% of all customers)') 
       as `number of customers who have churned`
from churns join customers;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

with customers_churned_after_trial as (
	select customer_id, plan_id, start_date
	from (select *, rank() over(partition by customer_id order by start_date) as rank1 
	      from subscriptions) as x
	where rank1=2 and plan_id=4 ),
	
     x (num_customers_churned_after_trial) as (
	select count(distinct customer_id) from customers_churned_after_trial),
	
     y (total_customers) as (
	select count(distinct customer_id) from subscriptions)

select concat(num_customers_churned_after_trial, ' ( ~', round(num_customers_churned_after_trial/total_customers*100, 0), '% of all customers)') 
       as `number of customers who churned after initial trial plan`
from x join y
;

-- 6. What is the number and percentage of customer plans after their initial free trial?

with customer_plans_after_trial as (
	select customer_id, plan_id, start_date
	from (select *, rank() over(partition by customer_id order by start_date) as rank1 
	      from subscriptions) as x
	where rank1=2 ),
	
     plans_after_trial_breakdown as (
	select plan_name, count(plan_name) as num_subscriptions
	from customer_plans_after_trial 
	join plans using (plan_id)
	group by plan_name ),
	
     x (count_subscriptions_after_trial) as (
	select sum(num_subscriptions) from plans_after_trial_breakdown)
select plan_name as `plan`,
       num_subscriptions as `number of subscriptions following trial`,
       concat(round(num_subscriptions/count_subscriptions_after_trial*100,1), '% ') as `percentage `
from plans_after_trial_breakdown
join x
;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31 ?

with enhanced_subs as (
	select *,
	       lag(plan_id, 1, NULL) over(partition by customer_id) as prev_plan, 
	       lag(start_date, 1, NULL) over(partition by customer_id) as prev_plan_start,
	       case when plan_id=0 then 'WEEK' 
	            when plan_id in (1,2) then 'MONTH' 
	            when plan_id=3 then 'YEAR' 
	            else NULL end as time_unit
	from subscriptions join plans using (plan_id)),

    subscriptions_actual_start_date as (
	select customer_id, plan_name, plan_id, start_date,
	       case when plan_id = 0 or (plan_id <> 4 and plan_id > prev_plan) then start_date -- upgrading or new customer
		    when (plan_id in (1,4) and prev_plan = 2) or (plan_id=4 and prev_plan=1) -- downgrading a monthly subscription (2->1, 2->4 or 1->4)
		       then date_add(prev_plan_start, interval (timestampdiff(month, prev_plan_start, start_date)+1) month)
		    when plan_id in (1,2,4) and prev_plan = 3 -- downgrading an annual plan (3->2, 3->1 or 3->4)
		       then date_add(prev_plan_start, interval (timestampdiff(year, prev_plan_start, start_date)+1) year)
		    when plan_id=4 and prev_plan=0 -- churning out after trial (0->4)
		       then date_add(prev_plan_start, interval timestampdiff(week, prev_plan_start, start_date) week)
		    end as actual_start_date
	from enhanced_subs),
	
    end_2020_subscriptions as (
	select *,
	       dense_rank() over(partition by customer_id order by actual_start_date desc) as rnk
	from
	(select * from subscriptions_actual_start_date where actual_start_date <= '2020-12-31') as x),
	
    end_2020_active_subscriptions_breakdown as (
	select plan_name, count(*) as active_subscriptions
	from end_2020_subscriptions
	where rnk =1 
	group by plan_name)

select *, 
     concat(round(active_subscriptions/(select sum(active_subscriptions) from end_2020_active_subscriptions_breakdown)*100,2), '%') as percentage
from end_2020_active_subscriptions_breakdown
;

-- 8. How many customers have upgraded to an annual plan in 2020?

select count(distinct customer_id) `Number of customers who upgraded to pro annual in 2020`
from subscriptions 
where plan_id = 3 and start_date < '2021-01-01';

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

select round(avg(timestampdiff(day, s.start_date, s2.start_date)),0) as `average number of days taken to get an annual plan after joining` 
from subscriptions s
join subscriptions s2
using (customer_id)
where s.plan_id=0 and s2.plan_id=3;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

select period, count(*) as `number of customer subscriptions`
from 
(select *, concat(floor(days/30.001)*30+1, '-', ceil(days/30.001)*30, ' days') as period
from
(select s.customer_id, timestampdiff(day, s.start_date, s2.start_date) as days
from subscriptions s
join subscriptions s2
using (customer_id)
where s.plan_id=0 and s2.plan_id=3) as x) as y
group by period
;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

select count(distinct s.customer_id) as `number of customers who downgraded from pro monthly to basic monthly`
from subscriptions s
join subscriptions s2
using (customer_id)
where s.plan_id=2 and s2.plan_id=1
and s.start_date between '2020-01-01' and '2020-12-31';


