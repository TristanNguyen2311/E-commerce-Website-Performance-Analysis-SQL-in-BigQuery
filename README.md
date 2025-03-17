



---
![96-967411_ecommerce-png-ecommerce-website-vector-png-clipart](https://github.com/user-attachments/assets/5441bb3d-3cba-4e6d-a6e9-23a00f56e7ae)



# 📊 Project Title: E-commerce Behavioral & Performance Analysis (SQL in BigQuery)
Author: Nguyễn Văn Trí   
Date: 2024-10-14   
Tools Used: SQL  

---

## 📑 Table of Contents  
1. [📌 Background & Overview](#-background--overview)  
2. [📂 Dataset Description](#-dataset-description)  
3. [🔎 Final Conclusion & Recommendations](#-final-conclusion--recommendations)

---

## 📌 Background & Overview  

### Objective:
### 📖 What is this project about? What Business Question will it solve?
This project uses SQL to query and analyze user interactions, shopping patterns, and product performance to:   
✔️ Identify customer behavior  
✔️ Enhance user experience  
✔️ Improve conversion rates  
✔️ Optimize marketing strategies
  
### 👤 Who is this project for?  
✔️ Data Analysts & Business Analysts  
✔️ Decision-makers & Stakeholders  



---

## 📂 Dataset Description 

### 📌 Data Source  
- Source: Google Analytics Public Dataset
  
### 📌 Data Dictionary
![Sql 1](https://github.com/user-attachments/assets/5eaf6db7-04df-4443-9397-5671c93dfd55)



## ⚒️ Main Process

<details>
  <summary> 1. Traffic & Engagement Analysis</summary>
Measured total visits, page views, and transactions in Q1 2017 to identify key traffic trends and seasonal patterns.

```sql
--q1 calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
select
  format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
  sum(totals.visits) as visits,
  sum(totals.pageviews) as pageviews,
  sum(totals.transactions) as transactions,
from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
where _TABLE_SUFFIX between '0101' and '0331'
group by 1
order by 1;
```

Query Result:

| Month  | Visits | Pageviews | Transactions |
|--------|--------|-----------|--------------|
| 201701 | 64,694 | 257,708   | 713          |
| 201702 | 62,192 | 233,373   | 733          |
| 201703 | 69,931 | 259,522   | 993          |

</details>


<details>
  <summary> 2. Marketing Effectiveness</summary>
Evaluated bounce rates across traffic sources in July 2017 to pinpoint ineffective channels and optimize landing pages.

```sql
--q2 Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)
select
    trafficSource.source as source,
    sum(totals.visits) as total_visits,
    sum(totals.Bounces) as total_no_of_bounces,
    (sum(totals.Bounces)/sum(totals.visits))* 100.00 as bounce_rate
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
group by source
order by total_visits DESC;
```

Query Result:

| Source | Total Visits | Total Bounces | Bounce Rate (%) |
|--------|-------------|--------------|---------------|
| google | 38,400 | 19,798 | 51.56% |
| (direct) | 19,891 | 8,606 | 43.27% |
| youtube.com | 6,351 | 4,238 | 66.73% |
| analytics.google.com | 1,972 | 1,064 | 53.96% |
| Partners | 1,788 | 936 | 52.35% |
| m.facebook.com | 669 | 430 | 64.28% |
| google.com | 368 | 183 | 49.73% |
| dfa | 302 | 124 | 41.06% |
| sites.google.com | 230 | 97 | 42.17% |
| facebook.com | 191 | 102 | 53.40% |
| reddit.com | 189 | 54 | 28.57% |
| ... | ... | ... | ... |

</details>


<details>
  <summary> 3. Revenue Breakdown</summary>
 Analyzed revenue by traffic source on a weekly and monthly basis in June 2017 to assess the best-performing acquisition channels.

```sql
--q3 Revenue by traffic source by week, by month in June 2017
with 
month_data as(
  select
    "Month" as time_type,
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    trafficSource.source as source,
    sum(p.productRevenue)/1000000 as revenue
  from `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
    unnest(hits) hits,
    unnest(product) p
  where p.productRevenue is not null
  group by 1,2,3
  order by revenue DESC
),

week_data as(
  select
    "Week" as time_type,
    format_date("%Y%W", parse_date("%Y%m%d", date)) as week,
    trafficSource.source as source,
    sum(p.productRevenue)/1000000 as revenue
  from `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
    unnest(hits) hits,
    unnest(product) p
  where p.productRevenue is not null
  group by 1,2,3
  order by revenue DESC
)

select * from month_data
union all
select * from week_data;
order by time_type
```

Query Result:

| Time Type | Time   | Source  | Revenue ($) |
|-----------|--------|---------|-------------|
| Month     | 201706 | (direct) | 97,333.62  |
| Week      | 201724 | (direct) | 30,908.91  |
| Week      | 201725 | (direct) | 27,295.32  |
| Month     | 201706 | google   | 18,757.18  |
| Week      | 201723 | (direct) | 17,325.68  |
| Week      | 201726 | (direct) | 14,914.81  |
| Week      | 201724 | google   | 9,217.17   |
| Week      | 201722 | (direct) | 6,888.90   |
| Week      | 201726 | google   | 5,330.57   |
| Week      | 201722 | google   | 2,119.39   |
| Week      | 201723 | google   | 1,083.95   |
| Week      | 201725 | google   | 1,006.10   |
</details>


<details>
  <summary> 4. Traffic & Engagement Analysis</summary>
Compared the browsing patterns of purchasers vs. non-purchasers in June & July 2017 to identify key engagement drivers.
  
```sql
--q4 Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.
with 
purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      (sum(totals.pageviews)/count(distinct fullvisitorid)) as avg_pageviews_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions>=1
  and product.productRevenue is not null
  group by month
),

non_purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      sum(totals.pageviews)/count(distinct fullvisitorid) as avg_pageviews_non_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
      ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions is null
  and product.productRevenue is null
  group by month
)

select
    pd.*,
    avg_pageviews_non_purchase
from purchaser_data pd
full join non_purchaser_data using(month)
order by pd.month;
```

Query Result:

| Month  | Avg Pageviews (Purchase) | Avg Pageviews (Non-Purchase) |
|--------|-------------------------:|-----------------------------:|
| 201706 | 94.02                    | 316.87                      |
| 201707 | 124.24                   | 334.06                      |

</details>



<details>
  <summary> 5. Traffic & Engagement Analysis</summary>
Measured transaction frequency per user and average spending per session in July 2017 to gauge purchase consistency and spending habits.
  
```sql
--q5 Average number of transactions per user that made a purchase in July 2017
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    sum(totals.transactions)/count(distinct fullvisitorid) as Avg_total_transactions_per_user
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,unnest (hits) hits,
    unnest(product) product
where  totals.transactions>=1
and product.productRevenue is not null
group by month;
```
Query Result:

| Month  | Avg Total Transactions per User |
|--------|--------------------------------:|
| 201707 | 4.16                            |

```sql
--q6 Average amount of money spent per session. Only include purchaser data in July 2017
with Raw_data as(
  select
    FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d',date)) as month
    ,totals.visits as visits
    ,product.productRevenue as Revenue
  from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` 
    ,unnest(hits) as hits
    ,unnest(hits.product) as product
  where totals.transactions is not null and product.productRevenue is not null
)

,Avg_per_visit as(
select 
  month
  ,sum(Revenue) as total_revenue
  ,sum(visits) as total_visit
  ,ROUND((sum(Revenue)/1000000)/sum(visits),2) as avg_revenue_by_user_per_visit
from Raw_data
group by month
)

select month, avg_revenue_by_user_per_visit
from Avg_per_visit;

select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    ((sum(product.productRevenue)/sum(totals.visits))/power(10,6)) as avg_revenue_by_user_per_visit
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,unnest(hits) hits
  ,unnest(product) product
where product.productRevenue is not null
and totals.transactions>=1
group by month;
```

Query Result:

| Month  | Avg Revenue Per Visit (USD) |
|--------|----------------------------:|
| 201707 | 43.86                       |

</details>


<details>
  <summary>6. Product Affinity & Cross-Selling</summary>
  Measured total visits, page views, and transactions in Q1 2017 to identify key traffic trends and seasonal patterns

Query Result:

| Month  | Visits | Pageviews | Transactions |
|--------|--------|-----------|--------------|
| 201701 | 64,694 | 257,708   | 713          |
| 201702 | 62,192 | 233,373   | 733          |
| 201703 | 69,931 | 259,522   | 993          |

</details>


<details>
  <summary> 5. Traffic & Engagement Analysis</summary>
  Measured total visits, page views, and transactions in Q1 2017 to identify key traffic trends and seasonal patterns

Query Result:

| Month  | Visits | Pageviews | Transactions |
|--------|--------|-----------|--------------|
| 201701 | 64,694 | 257,708   | 713          |
| 201702 | 62,192 | 233,373   | 733          |
| 201703 | 69,931 | 259,522   | 993          |

</details>

## 🔎 Final Conclusion & Recommendations  

👉🏻 Based on the insights and findings above, we would recommend the [stakeholder team] to consider the following:  

📌 Key Takeaways:  
✔️ Recommendation 1  
✔️ Recommendation 2  
✔️ Recommendation 3
