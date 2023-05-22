/*
A. Customer Nodes Exploration
1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th and 95th percentile for this same reallocation days metric
for each region?
*/

-- A. Customer Nodes Exploration
-- 1. How many unique nodes are there on the Data Bank system?

select count(distinct region_id, node_id) as `Total number of unique nodes in the Data Bank System` from customer_nodes;

-- 2. What is the number of nodes per region?

select region_name as Region, 
       count(distinct node_id) as `Number of nodes` 
from customer_nodes 
join regions using (region_id) 
group by region_name;

-- 3. How many customers are allocated to each region?

select region_name as Region, 
       count(distinct customer_id) as `Number of customers allocated` 
from customer_nodes 
join regions using (region_id) 
group by region_name;

-- 4. How many days on average are customers reallocated to a different node?
-- with only 5 nodes and about 100 customers per region, there are bound to be instances where a customer is reallocated to the node they are currently allocated. 
-- we first break the data to determine start and end dates when the customers are actually allocated to a different node and average the number of days the customers are allocated to the nodes

set @a := 0;
with t1 as (
	select *, case when timestampdiff(day, lag(end_date) over(partition by customer_id,node_id), start_date)=1 then 0 else 1 end as is_different_node
	from customer_nodes
	order by customer_id, start_date),
     
     t2 as (
	select *, (@a := @a +is_different_node) as row_i
	from t1),
	
     t3 as (
	select customer_id, 
	       min(start_date) as start_d,
	       max(end_date) as end_d
	from t2
	group by customer_id, row_i)

select round(avg(timestampdiff(day, start_d, end_d)),1) as `Avg no. of days before reallocation to a different node`
from t3 
where end_d <> '9999-12-31';

-- previous solutions ::
with node_allocations_table as ( 
	select *, 
	   case when end_date='9999-12-31' then 0 else timestampdiff(day, start_date, end_date) end as days,
	   case when customer_id = lag(customer_id) over()
		and region_id = lag(region_id) over() 
		and node_id = lag(node_id) over()
	   then 0 else 1 end as allocated_different_node
	from customer_nodes
	order by customer_id, start_date)

select round(sum(days)/(sum(allocated_different_node)-count(distinct customer_id)),1) as `Average number of days before reallocation to a different node`
from node_allocations_table
;

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?



