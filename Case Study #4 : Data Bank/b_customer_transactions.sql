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


with monthly_deposit_counts_table as (
	select customer_id, 
	       month(txn_date) as month_,
	       monthname(txn_date) as monthname_, 
	       count(*) as num_deposits
	from customer_transactions
	where txn_type='deposit'
	group by customer_id, monthname(txn_date), month(txn_date)),

     monthly_purchases_and_withdrawals_counts_table as (
	select customer_id, 
	       month(txn_date) as month_,
	       monthname(txn_date) as monthname_, 
	       count(*) as num_purchases_and_withdrawals
	from customer_transactions
	where txn_type <> 'deposit'
	group by customer_id, monthname(txn_date), month(txn_date))
	
select d.monthname_, count(distinct d.customer_id) as `Number of customers` -- with more than 1 deposit and either 1 purchase or 1 withdrawal`
from monthly_deposit_counts_table d
join monthly_purchases_and_withdrawals_counts_table pw
using (customer_id, month_, monthname_)
where d.num_deposits>1 and pw.num_purchases_and_withdrawals>1
group by d.monthname_, d.month_
order by d.month_;

-- 4. What is the closing balance for each customer at the end of the month?

with monthly_transactions_skeleton as (
        select * 
        from (select distinct month(txn_date) as txn_month, monthname(txn_date) as txn_monthname
              from customer_transactions) x 
       join (select distinct customer_id 
             from customer_transactions) y 
             ),
     
     monthly_transactions as (
        select customer_id,
               month(txn_date) as txn_month, 
               sum(case when txn_type='deposit' then txn_amount else -txn_amount end) as monthly_addition 
        from customer_transactions 
        group by customer_id, txn_month),

     monthly_closing_balances as (
	select customer_id, 
	       txn_monthname as month, 
	       sum(coalesce(monthly_addition, 0)) over(partition by customer_id order by txn_month rows unbounded preceding) as `closing balance`
	from monthly_transactions_skeleton
	left join monthly_transactions 
	  using(txn_month, customer_id)
	order by customer_id, txn_month)

select * 
from monthly_closing_balances
limit 20;

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?



