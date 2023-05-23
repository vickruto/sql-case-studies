/*
B. Customer Transactions
1. What is the unique count and total amount for each transaction type?
2. What is the average total historical deposit counts and amounts for all customers?
3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4. What is the closing balance for each customer at the end of the month?
5. What is the percentage of customers who increase their closing balance by more than 5%?
*/

use data_bank;
-- B. Customer Transactions
-- 1. What is the unique count and total amount for each transaction type?

select txn_type as `transaction type`, 
       count(*) as `number of transactions`, 
       sum(txn_amount) as `total transacted amount` 
from customer_transactions 
group by txn_type;

-- 2. What is the average total historical deposit counts and amounts for all customers?

select avg(deposit_count) as `average number of deposits per customer`, 
       round(avg(deposit_amount),2) as `average deposited amount` 
from (select customer_id, 
             count(*) as deposit_count, 
             sum(txn_amount) as deposit_amount 
      from customer_transactions 
      where txn_type='deposit' 
      group by customer_id) as agg_txn
;

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?



-- 4. What is the closing balance for each customer at the end of the month?



-- 5. What is the percentage of customers who increase their closing balance by more than 5%?



