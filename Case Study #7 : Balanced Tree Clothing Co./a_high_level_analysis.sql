/*
Case Study Questions
The following questions can be considered key business questions and metrics that the Balanced Tree team requires for their monthly reports.
Each question can be answered using a single query - but as you are writing the SQL to solve each individual problem, keep in mind how you would generate all of these metrics in a single SQL script which the Balanced Tree team can run each month.

High Level Sales Analysis
1. What was the total quantity sold for all products?
2. What is the total generated revenue for all products before discounts?
3. What was the total discount amount for all products?
*/

-- 1. What was the total quantity sold for all products?

select sum(qty) as `total quantity sold`
from sales;

-- 2. What is the total generated revenue for all products before discounts?

select concat('$ ', format(sum(qty*price),0)) as `total generated revenue before discounts` 
from sales;

-- 3. What was the total discount amount for all products?

select concat('$ ', format(sum(qty*price*discount/100),2)) as `total discount amount for all products` 
from sales;

