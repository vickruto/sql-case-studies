-- QUERY SQL 

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
select customer_id, sum(price) as total_amount_spent
from sales  
join menu using (product_id)
group by customer_id;

-- 2. How many days has each customer visited the restaurant?
select customer_id, count(distinct(order_date)) as number_of_days_visited
from sales
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
select customer_id, group_concat(distinct(product_name)) as `first menu item(s) purchased`
from
	(select *,
	       rank() over(partition by customer_id order by order_date asc) as rank1
	from sales 
	join menu using (product_id)) as x
where rank1 = 1
group by customer_id
;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name, num_purchases 
from menu 
join (select product_id, count(*) as num_purchases
      from sales
      group by product_id
      order by num_purchases desc limit 1) as x 
using (product_id);

-- 5. Which item was the most popular for each customer?
select customer_id, 
       group_concat(product_name separator ', ') as `most popular item(s)`, 
       num_purchases as `number of purchases`
from 
(select customer_id, product_name, count(*) as num_purchases, 
       rank() over(partition by customer_id order by count(*) desc) as rank1
from sales 
join menu using (product_id)
group by customer_id, product_name) as x
where rank1 = 1
group by customer_id, num_purchases
;

-- 6. Which item was purchased first by the customer after they became a member?
select customer_id, product_name as `first product purchased after becoming a member`
from menu 
join (select *,
         rank() over(partition by customer_id order by order_date) as rank1 
      from members 
      left join sales using (customer_id) 
      where order_date > join_date) as x 
using (product_id)
where rank1 = 1
order by customer_id
; 

-- 7. Which item was purchased just before the customer became a member?
select customer_id, 
       group_concat(distinct(product_name) separator ', ') 
         as `last product(s) purchased just before becoming a member`
from menu 
join (select *,
         rank() over(partition by customer_id order by order_date desc) as rank1 
      from members 
      left join sales using (customer_id) 
      where order_date < join_date ) as x
using (product_id)
where rank1 = 1
group by customer_id
;

-- 8. What is the total items and amount spent for each member before they became a member?
-- --- ASSUMPTION :: Query requires the total items and amount spent for members who did not become members within the data timeframe as well
select customer_id, count(*) as `total items`, sum(price) as `total amount spent` 
from menu 
join (select customer_id, product_id 
      from sales 
      left join members using (customer_id) 
      where order_date < join_date or join_date is null) as x 
using(product_id) 
group by customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select customer_id, 
       sum(case when product_name like 'sushi' then 20 else 10 end) as `total points` 
from sales 
join menu using (product_id) 
group by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select customer_id, 
       sum(
       case when datediff(order_date, join_date) between 0 and 7 then 20
       when product_name = 'sushi' then 20 
       else 10 end) as `total points`
from sales 
join members using (customer_id) 
join menu using(product_id)
where order_date < '2021-02-01'
group by customer_id
order by customer_id
;

