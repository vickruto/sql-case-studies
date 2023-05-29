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
limit 4;


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
group by pd.category_name
limit 4;

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



-- 7. What is the percentage split of revenue by segment for each category?



-- 8. What is the percentage split of total revenue by category?



-- 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)



-- 10. What is the most common combination of at least 1 quantity of any 3 products in a single transaction?




