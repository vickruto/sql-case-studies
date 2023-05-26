/*
2. Digital Analysis
Using the available datasets - answer the following questions using a single query for each one:
1. How many users are there?
2. How many cookies does each user have on average?
3. What is the unique number of visits by all users per month?
4. What is the number of events for each event type?
5. What is the percentage of visits which have a purchase event?
6. What is the percentage of visits which view the checkout page but do not have a purchase event?
7. What are the top 3 pages by number of views?
8. What is the number of views and cart adds for each product category?
9. What are the top 3 products by purchases?
*/

use clique_bait;

-- 1. How many users are there?

select count(distinct user_id) from users;

-- 2. How many cookies does each user have on average?

select count(*)/count(distinct user_id) as `average number of cookies per user` from users ;

