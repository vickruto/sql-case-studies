/*
Transaction Analysis
1. How many unique transactions were there?
2. What is the average unique products purchased in each transaction?
3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
4. What is the average discount value per transaction?
5. What is the percentage split of all transactions for members vs non-members?
6. What is the average revenue for member transactions and non-member transactions?
*/

use balanced_tree

-- 1. How many unique transactions were there?

 select count(distinct txn_id) as `Number of unique transactions` from sales;

-- 2. What is the average unique products purchased in each transaction?

select avg(num_products) as  `average number of unique products per transaction` 
from (select txn_id, count(distinct prod_id) as num_products
      from sales group by txn_id) as x
;

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?



-- 4. What is the average discount value per transaction?

select concat('$', format(avg(txn_discount),2)) as `average discount per transaction` 
from (select avg(qty*price*discount/100) as txn_discount 
      from sales group by txn_id) as x 
;

-- 5. What is the percentage split of all transactions for members vs non-members?



-- 6. What is the average revenue for member transactions and non-member transactions?



