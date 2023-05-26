/*
2. Digital Analysis
Using the available datasets - answer the following questions using a single query for each one:
1. How many users are there?
2. How many cookies does each user have on average?
3. What is the unique number of visits by all users per month?
4. What is the number of events for each event type?
5. What is the percentage of visits which have a purchase event?
6. What is the percentage of visits which view the checkout page but do not have a purchase event?
7. What are the top 3 pages by number of views?
8. What is the number of views and cart adds for each product category?
9. What are the top 3 products by purchases?
*/

use clique_bait;

-- 1. How many users are there?

select count(distinct user_id) from users;

-- 2. How many cookies does each user have on average?

select count(*)/count(distinct user_id) as `average number of cookies per user` from users ;

-- 3. What is the unique number of visits by all users per month?

select monthname(start_date) as month, 
       count(distinct cookie_id) as `number of visits` 
from users 
group by monthname(start_date), month(start_date)
order by month(start_date);

-- 4. What is the number of events for each event type?

select event_type, event_name, count(*) as `event counts` 
from events 
join event_identifier using (event_type) 
group by event_name, event_type;

-- 5. What is the percentage of visits which have a purchase event?

select concat(round(num_purchase_events/total_unique_events*100, 2), '%') as `percentage of visits leading to purchase`
from (
	select count(distinct visit_id) as num_purchase_events
	from events 
	join event_identifier using (event_type) 
	where event_name like '%Purchase%') a
join (  select count(distinct visit_id) as total_unique_events from events) b;

