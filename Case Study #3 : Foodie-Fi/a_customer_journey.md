# **Case Study Questions**

## **A. Customer Journey**

Based off the 8 sample customers provided in the sample from the subscriptions table (`customer_id` `1`, `2`, `11`, `13`, `15`, `16`, `18` and `19`), write a brief description about each customer’s onboarding journey.  
Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

### **Data Selection SQL Query**
````sql
select customer_id, 
       plan_name, 
       start_date, 
       timestampdiff(day, lag(start_date) over (partition by customer_id order by start_date), start_date) as days_after_joining 
from subscriptions 
join plans using (plan_id) 
where customer_id in (1,2,11,13,15,16,18,19);
````

### **The Selected Data :**
| customer_id | plan_name     | start_date | days_after_joining |
|-------------|---------------|------------|--------------------|
|           1 | trial         | 2020-08-01 |               NULL |
|           1 | basic monthly | 2020-08-08 |                  7 |
|           2 | trial         | 2020-09-20 |               NULL |
|           2 | pro annual    | 2020-09-27 |                  7 |
|          11 | trial         | 2020-11-19 |               NULL |
|          11 | churn         | 2020-11-26 |                  7 |
|          13 | trial         | 2020-12-15 |               NULL |
|          13 | basic monthly | 2020-12-22 |                  7 |
|          13 | pro monthly   | 2021-03-29 |                 97 |
|          15 | trial         | 2020-03-17 |               NULL |
|          15 | pro monthly   | 2020-03-24 |                  7 |
|          15 | churn         | 2020-04-29 |                 36 |
|          16 | trial         | 2020-05-31 |               NULL |
|          16 | basic monthly | 2020-06-07 |                  7 |
|          16 | pro annual    | 2020-10-21 |                136 |
|          18 | trial         | 2020-07-06 |               NULL |
|          18 | pro monthly   | 2020-07-13 |                  7 |
|          19 | trial         | 2020-06-22 |               NULL |
|          19 | pro monthly   | 2020-06-29 |                  7 |
|          19 | pro annual    | 2020-08-29 |                 61 |

