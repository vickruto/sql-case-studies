/*
Transaction Analysis
1. How many unique transactions were there?
2. What is the average unique products purchased in each transaction?
3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
4. What is the average discount value per transaction?
5. What is the percentage split of all transactions for members vs non-members?
6. What is the average revenue for member transactions and non-member transactions?
*/

use balanced_tree;

-- 1. How many unique transactions were there?

 select count(distinct txn_id) as `Number of unique transactions` from sales;

-- 2. What is the average unique products purchased in each transaction?

select avg(num_products) as  `average number of unique products per transaction` 
from (select txn_id, count(distinct prod_id) as num_products
      from sales group by txn_id) as x
;

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

with txn_revenue_tables as (
       select *, percent_rank() over(order by txn_revenue) as pct_rnk
       from (select sum(qty*price*(100-discount)/100) as txn_revenue 
             from sales group by txn_id order by txn_revenue) as x ), 
             
     x as (  
	select '25th percentile' as percentile, concat('$', format(txn_revenue,2)) as `revenue`from txn_revenue_tables where pct_rnk >= 0.25 limit 1), 

     y as (
	select '50th percentile', concat('$', format(txn_revenue,2)) from txn_revenue_tables where pct_rnk >= 0.50 limit 1), 

     z as ( 
	select '75th percentile', concat('$', format(txn_revenue,2)) from txn_revenue_tables where pct_rnk >= 0.75 limit 1)

select * from x 
union select * from y 
union select * from z;

-- 4. What is the average discount value per transaction?

select concat('$', format(avg(txn_discount),2)) as `average discount per transaction` 
from (select avg(qty*price*discount/100) as txn_discount 
      from sales group by txn_id) as x 
;

-- 5. What is the percentage split of all transactions for members vs non-members?

with x as (
        select count(*) as total_transactions from sales),
        
     y as (
        select count(*) as member_transactions from sales where member=1),

     z as (
        select count(*) as non_member_transactions from sales where member=0)

select concat(round(member_transactions/total_transactions*100, 2), '%') as `member transactions`,
       concat(round(non_member_transactions/total_transactions*100, 2), '%') as `non-member transactions`
from x
join y 
join z;

-- 6. What is the average revenue for member transactions and non-member transactions?



