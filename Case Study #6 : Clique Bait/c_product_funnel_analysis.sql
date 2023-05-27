/*3. Product Funnel Analysis
Using a single SQL query - create a new output table which has the following details:
 - How many times was each product viewed?
 - How many times was each product added to cart?
 - How many times was each product added to a cart but not purchased (abandoned)?
 - How many times was each product purchased?
Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
Use your 2 new output tables - answer the following questions:
1. Which product had the most views, cart adds and purchases?
2. Which product was most likely to be abandoned?
3. Which product had the highest view to purchase percentage?
4. What is the average conversion rate from view to cart add?
5. What is the average conversion rate from cart add to purchase?
*/

use clique_bait;

/*
Using a single SQL query - create a new output table which has the following details:
 - How many times was each product viewed?  
 - How many times was each product added to cart?
 - How many times was each product added to a cart but not purchased (abandoned)?
 - How many times was each product purchased?
*/

drop table if exists individual_products_statistics_table;
create table individual_products_statistics_table as 
with joined_tables as (
	select visit_id, sequence_number, page_name as product, event_name 
	from events 
	join page_hierarchy using (page_id) 
	join event_identifier using (event_type)),

     num_views_ as (
	select product, count(*) as views
	from joined_tables 
	where event_name like '%Page View%'
	group by product), 

     cart_adds_ as (
	select product, count(*) as cart_adds
	from joined_tables 
	where event_name like '%Cart%'
	group by product),

     purchases_ as (
	select product, count(*) as purchases
	from joined_tables 
	where event_name like '%Cart%' and visit_id in (select visit_id from joined_tables where event_name like '%Purchase%')
	group by product),

     abandonments_ as (
	select product, count(*) as abandonments
	from joined_tables 
	where event_name like '%Cart%' and visit_id not in (select visit_id from joined_tables where event_name like '%Purchase%')
	group by product)

select *
from num_views_ 
join cart_adds_ using (product)
join purchases_ using (product)
join abandonments_ using (product);


-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

drop table if exists product_categories_statistics_table;
create table product_categories_statistics_table as 
with joined_tables as (
	select visit_id, sequence_number, product_category, event_name 
	from events 
	join page_hierarchy using (page_id) 
	join event_identifier using (event_type)),

     num_views_ as (
	select product_category, count(*) as views
	from joined_tables 
	where event_name like '%Page View%'
	group by product_category), 

     cart_adds_ as (
	select product_category, count(*) as cart_adds
	from joined_tables 
	where event_name like '%Cart%'
	group by product_category),

     purchases_ as (
	select product_category, count(*) as purchases
	from joined_tables 
	where event_name like '%Cart%' and visit_id in (select visit_id from joined_tables where event_name like '%Purchase%')
	group by product_category),

     abandonments_ as (
	select product_category, count(*) as abandonments
	from joined_tables 
	where event_name like '%Cart%' and visit_id not in (select visit_id from joined_tables where event_name like '%Purchase%')
	group by product_category)

select *
from num_views_ 
join cart_adds_ using (product_category)
join purchases_ using (product_category)
join abandonments_ using (product_category);

-- Use your 2 new output tables - answer the following questions:
-- 1. Which product had the most views, cart adds and purchases?

select * 
from 
 (select product as `most views` from individual_products_statistics_table order by views desc limit 1) v
join 
 (select product as `most cart adds` from individual_products_statistics_table order by cart_adds desc limit 1) c
join 
 (select product as `most purchases` from individual_products_statistics_table order by purchases desc limit 1) p ;

-- 2. Which product was most likely to be abandoned?

select product `product most likely to be abandoned`, 
       concat(round(abandonments/cart_adds*100,2), '%') as abandonment_rate  
from individual_products_statistics_table 
order by abandonment_rate desc 
limit 1;

-- 3. Which product had the highest view to purchase percentage?



-- 4. What is the average conversion rate from view to cart add?



-- 5. What is the average conversion rate from cart add to purchase?



