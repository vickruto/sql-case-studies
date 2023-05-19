
-- DATA CLEANING
drop table if exists customer_orders_cleaned;

create table customer_orders_cleaned as 
  select order_id, customer_id, pizza_id, 
       case when exclusions in ('', 'null') then NULL else exclusions end as exclusions,
       case when extras in ('', 'null') then NULL else extras end as extras, 
       order_time
  from customer_orders;


drop table if exists runner_orders_cleaned;

create table runner_orders_cleaned as 
  select order_id, runner_id, 
       case when pickup_time in ('', 'null') then NULL else pickup_time end as pickup_time,
       case when distance in ('', 'null') then NULL 
            when distance like '%km%' then trim('km' from distance) 
            else distance end as distance,
       case when duration in ('', 'null') then NULL 
            when duration like '%minutes%' then trim('minutes' from duration)
            when duration like '%mins%' then trim('mins' from duration)
            when duration like '%minute%' then trim('minute' from duration)
            else duration end as duration,
       case when cancellation in ('', 'null') then NULL else cancellation end as cancellation 
     from runner_orders;

alter table runner_orders_cleaned modify pickup_time datetime;
alter table runner_orders_cleaned modify distance float;
alter table runner_orders_cleaned modify duration int;

