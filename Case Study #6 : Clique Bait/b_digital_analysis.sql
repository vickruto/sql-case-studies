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

-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

with joined_tables as (
        select page_id, visit_id, event_type, page_name, event_name from events join page_hierarchy using (page_id) join event_identifier using (event_type)), 
        
      x as (
         select count(distinct visit_id) as num_checkout_events from joined_tables where page_name like '%Checkout%'), 
         
      y as (
         select count(distinct visit_id) as num_purchase_events_without_checkout from joined_tables 
         where page_name like '%Checkout%' 
         and visit_id not in (select distinct visit_id as num_checkout_events from joined_tables where event_name like '%Purchase%'))

select concat(round(num_purchase_events_without_checkout/num_checkout_events*100,2), '%') 
       as `percentage of events with checkout page view and no purchase`
from x join y;


-- 7. What are the top 3 pages by number of views?

select page_name 
from page_hierarchy 
join (select page_id, count(*) as num_views from events group by page_id ) as x 
using (page_id)
order by num_views desc 
limit 3;

-- 8. What is the number of views and cart adds for each product category?

with joined_tables as (
	select visit_id, sequence_number, product_category, event_name 
	from events 
	join page_hierarchy using (page_id) 
	join event_identifier using (event_type) 
	where product_category is not null),

     num_views as (	
	select product_category, count(*) as `Page Views`
	from joined_tables 
	where event_name like '%Page View%'
	group by product_category), 

     cart_adds as (	
	select product_category, count(*) as `Cart Adds`
	from joined_tables 
	where event_name like '%Cart%'
	group by product_category)

select *
from num_views
join cart_adds
using (product_category);

-- 9. What are the top 3 products by purchases?

select page_name as product, 
       count(*) as `number of purchases`
from events 
join event_identifier using (event_type) 
join page_hierarchy using (page_id) 
where visit_id in (select visit_id from events join event_identifier using (event_type) where event_name like '%Purchase%') 
and product_category is not null
group by page_name;

