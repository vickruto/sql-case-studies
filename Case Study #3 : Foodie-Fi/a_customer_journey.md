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


### **Customer Journey Descriptions**
| customer_id | Foodie-Fi Journey |
|---------------|-----------|
| 1 | The customer signed up on 1st of August 2020 and downgraded to a basic monthly plan during the trial period and continued with the basic monthly plan until the end of recorded the data window.  |
| 2 | The customer started the trial plan on 20th of September 2020 and upgraded to a pro annual plan during trial period and continued with the plan until the end of the data window.  |
| 11 | The customer signed up on 19th of November 2020 and unfortunately canceled their subscription before the end of the trial period |
| 13 | The customer signed up on 15th of December 2020 and downgraded to a basic monthly plan during the trial period. On the 29th of March 2021, the customer upgraded to a pro monthly plan |
| 16 | The customer signed up to Foodie-Fi on May, 31st 2020 and downgraded to a basic monthly plan during before the end of the trial period. After 4 months and a few days, the customer upgraded to a pro annual plan which continued to the end of the recorded data window. |
| 18 | The customer signed up to Foodie-Fi on 6th of July 2020 and continued with the default pro monthly plan at the end of their trial plan |
| 19 | The customer signed up on 22nd June 2020 and continued with the default pro monthly plan at the end of the trial plan. Two months later on 29th of August, the customer upgraded to a pro annual plan   |
