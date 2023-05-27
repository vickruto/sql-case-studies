/*
4. Campaigns Analysis
Generate a table that has 1 single row for every unique visit_id record and has the following columns:
- user_id
- visit_id
- visit_start_time : the earliest event_time for each visit
- page_views : count of page views for each visit
- cart_adds : count of product cart add events for each visit
- purchase : 1/0 flag if a purchase event exists for each visit
- campaign_name : map the visit to a campaign if the visit_start_time falls between the start_date and end_date
- impression : count of ad impressions for each visit
- click : count of ad clicks for each visit
- (Optional column) cart_products : a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number )

Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.
Some ideas you might want to investigate further include:
- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to each other?
*/

drop table if exists campaign_metrics;
create table campaign_metrics as
select user_id, 
       visit_id, 
       min(event_time) as visit_start_time, 
       sum(case when event_name like '%View%' then 1 else 0 end) as page_views,
       sum(case when event_name like '%Cart%' then 1 else 0 end) as cart_adds,
       sum(case when event_name like '%Purchase%' then 1 else 0 end) as purchase,
       campaign_name,
       sum(case when event_name like '%Impression%' then 1 else 0 end) as impression,
       sum(case when event_name like '%Click%' then 1 else 0 end) as click
from events e
join users using (cookie_id) 
join event_identifier using (event_type)
left join campaign_identifier ci on e.event_time between ci.start_date and ci.end_date
group by visit_id, user_id, campaign_name;

