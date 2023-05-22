/*
    C. Challenge Payment Question
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
 - monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
 - upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
 - upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period 
 - once a customer churns they will no longer make payments
*/

use foodie-fi; 

with recursive cte1 as ( 
	select 0 as nth_payment 
	union all
	select nth_payment+1 
	from cte1
	where nth_payment < 11),
	
     paid_plans_start_end_dates as (     
	select subscriptions.*,
	       least(coalesce(lead(start_date) over(partition by customer_id), '2020-12-31') ,
	       coalesce(churn_date, '2020-12-31')) as end_date
	from subscriptions 
	left join (select customer_id, start_date as churn_date from subscriptions where plan_id=4) c
	using (customer_id)
	where plan_id not in (0,4)),

     2020_paid_plans_counts as (
	select *, 
	       case when plan_id=3 then timestampdiff(year, start_date, end_date)+1 
		    when plan_id in (1,2) then timestampdiff(month, date_add(start_date, interval 1 day), end_date)+1 
		   end as num_plan_payments 
	from paid_plans_start_end_dates),

    payments_table as (
	select *,
	       date_add(start_date, interval nth_payment month) as payment_date,
	       lag(plan_id) over(partition by customer_id order by start_date, nth_payment) as prev_plan 
	from 2020_paid_plans_counts
	join cte1 on nth_payment<num_plan_payments
	order by customer_id, payment_date),

    payments_table2 as (
	select *,
	       case when prev_plan is not null 
	             and prev_plan <> plan_id 
	             and timestampdiff(month, lag(payment_date) over(), payment_date)=0 
	         then prev_plan 
	         else 'None' 
	         end as ongoing_plan
	from payments_table),

   plan_payments as (
	select p.plan_id, p.plan_name, p.price-p2.price as amount, p2.plan_id as ongoing_plan 
	from plans p join plans p2 where p.plan_id<>4 and p2.plan_id<>0 and p.plan_id>p2.plan_id
	union 
	select *, 'None' as ongoing_plan from plans 
	where plan_id in (1,2,3))

select customer_id, 
       plan_id, 
       plan_name, 
       payment_date, 
       amount, 
       rank() over(partition by customer_id order by payment_date) as payment_order
from payments_table2
join plan_payments using (plan_id, ongoing_plan)
where customer_id in (1, 2, 13, 15, 16, 18, 19)
order by customer_id, payment_date;

