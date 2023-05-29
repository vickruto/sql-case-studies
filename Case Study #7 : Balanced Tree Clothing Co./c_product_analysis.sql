/*
Product Analysis
1. What are the top 3 products by total revenue before discount?
2. What is the total quantity, revenue and discount for each segment?
3. What is the top selling product for each segment?
4. What is the total quantity, revenue and discount for each category?
5. What is the top selling product for each category?
6. What is the percentage split of revenue by product for each segment?
7. What is the percentage split of revenue by segment for each category?
8. What is the percentage split of total revenue by category?
9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
10. What is the most common combination of at least 1 quantity of any 3 products in a single transaction?
*/

use balanced_tree;

-- Product Analysis
-- 1. What are the top 3 products by total revenue before discount?

select pd.product_name, 
       concat('$', format(sum(s.qty*s.price), 2)) as `total revenue before discount` 
from sales s 
join product_details pd 
on s.prod_id=pd.product_id 
group by product_name;

--- 2. What is the total quantity, revenue and discount for each segment?

select pd.segment_name as `segment`, 
       sum(qty) as `total quantity`,
       concat('$', format(sum(s.qty*s.price),2)) as `gross revenue`, 
       concat('$', format(sum(s.qty*s.price*discount/100),2)) as `discount`
from product_details pd 
join sales s on pd.product_id=s.prod_id 
group by pd.segment_name ;


-- 3. What is the top selling product for each segment?

select segment_name as `Segment`, 
       product_name as `Top selling product`
from (
select product_name, 
       segment_name, 
       rank() over(partition by segment_name order by sum(qty) desc) as rnk, 
       sum(qty) as product_sales 
from product_details pd 
join sales s 
on pd.product_id=s.prod_id 
group by product_name, segment_name) as x
where rnk=1 ;

-- 4. What is the total quantity, revenue and discount for each category?

select pd.category_name as `Category`, 
       sum(qty) as `total quantity`,
       concat('$', format(sum(s.qty*s.price),2)) as `gross revenue`, 
       concat('$', format(sum(s.qty*s.price*discount/100),2)) as `discount`
from product_details pd 
join sales s on pd.product_id=s.prod_id 
group by pd.category_name;


-- 5. What is the top selling product for each category?

select category_name as `Category`, 
       product_name as `Top selling product`
from (
select product_name, 
       category_name, 
       rank() over(partition by category_name order by sum(qty) desc) as rnk, 
       sum(qty) as product_sales 
from product_details pd 
join sales s 
on pd.product_id=s.prod_id 
group by product_name, category_name) as x
where rnk=1 ;

-- 6. What is the percentage split of revenue by product for each segment?

with product_revenues as (
       select product_name, 
              segment_name, 
              sum(qty*s.price*(100-discount)/100) as revenue 
       from sales s 
       join product_details pd 
       on pd.product_id=s.prod_id 
       group by product_name, segment_name
)
select product_name as `Product`,
       segment_name as `Segment`,
       concat('$', format(revenue,2)) as `Revenue`,
       concat(round(revenue/sum(revenue) over(partition by segment_name)*100, 2), '%') as `segment percentage split` 
from product_revenues;

-- 7. What is the percentage split of revenue by segment for each category?

with segment_revenues as (
       select segment_name, 
              category_name, 
              sum(qty*s.price*(100-discount)/100) as revenue 
       from sales s 
       join product_details pd 
       on pd.product_id=s.prod_id 
       group by category_name, segment_name
)
select segment_name as `Segment`,
       category_name as `Category`,
       concat('$', format(revenue,2)) as `Revenue`,
       concat(round(revenue/sum(revenue) over(partition by category_name)*100, 2), '%') as `category percentage split` 
from segment_revenues;

-- 8. What is the percentage split of total revenue by category?

with category_revenues as ( 
       select category_name, 
              sum(qty*s.price*(100-discount)/100) as revenue 
       from sales s 
       join product_details pd 
       on pd.product_id=s.prod_id 
       group by category_name)

select category_name as `Category`, 
       concat(round(revenue/sum(revenue) over()*100, 2), '%') as `percentage split`
from category_revenues;


-- 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

select product_name, 
       concat(round(count(distinct txn_id)/(select count(distinct txn_id) from sales)*100,2), '%') as `transaction penetration` 
from sales s 
join product_details pd on pd.product_id=s.prod_id 
group by product_name;

-- 10. What is the most common combination of at least 1 quantity of any 3 products in a single transaction?

with product_ids as (
	select a.prod_id as prod_1, b.prod_id as prod_2, c.prod_id as prod_3, count(*) as num_combination
	from sales a 
	join sales b 
	   on a.txn_id=b.txn_id and a.prod_id>b.prod_id 
	join sales c 
	   on b.txn_id=c.txn_id and b.prod_id>c.prod_id 
	group by a.prod_id, b.prod_id, c.prod_id
	order by count(*) desc
	limit 1)

select * 
from (select product_name as `product 1` from product_details where product_id in (select prod_1 from product_ids)) x
join (select product_name as `product 2` from product_details where product_id in (select prod_2 from product_ids)) y
join (select product_name as `product 3` from product_details where product_id in (select prod_3 from product_ids)) z
join (select num_combination as `Number of Times Purchased Together` from product_ids) a;


