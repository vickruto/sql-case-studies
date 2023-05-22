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



-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?



