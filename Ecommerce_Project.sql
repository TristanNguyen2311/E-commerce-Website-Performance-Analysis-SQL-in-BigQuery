--query1
SELECT 
   format_date("%Y%m", parse_date("%Y%m%d", date)) as month
  ,SUM(totals.visits) as visits
  ,SUM(totals.pageviews) as pageviews
  ,SUM(totals.transactions) as transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _table_suffix BETWEEN "0101" AND '0331'
GROUP BY month
ORDER BY month;

--query2
SELECT   
  trafficSource.source
  ,SUM(totals.visits) as totals_visits
  ,SUM(totals.bounces) as total_no_of_bounces
  ,ROUND(100*SUM(totals.bounces)/SUM(totals.visits),2) as bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` 
GROUP BY trafficSource.source
ORDER BY  trafficSource.source;

--query3
WITH week_revenue as(
  SELECT 
    'Week'as time_type
    ,FORMAT_DATE('%Y%W',PARSE_DATE('%Y%m%d', date)) as time
    ,trafficSource.source 
    ,SUM(productRevenue)/1000000.0 as revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
  UNNEST (hits) hits,
  UNNEST (hits.product) product
  WHERE productRevenue is not null
  GROUP BY time, trafficSource.source
  ORDER BY time, trafficSource.source
)

,month_revenue as(
  SELECT 
    'Month'as time_type
    ,FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d', date)) as time
    ,trafficSource.source
    ,SUM(productRevenue)/1000000.0 as revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
  UNNEST (hits) hits,
  UNNEST (hits.product) product
  WHERE productRevenue is not null
  GROUP BY time, trafficSource.source
  ORDER BY time, trafficSource.source
)

SELECT *
FROM week_revenue
UNION ALL
SELECT *
FROM month_revenue
ORDER BY source,revenue;

--query4
WITH avg_pageview_purchaser as(
  SELECT  
    FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d', date)) as month
    ,ROUND(SUM(totals.pageviews)/COUNT(DISTINCT fullVisitorId),2) as avg_pageviews_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST (hits) hits,
  UNNEST (hits.product) product
  WHERE _table_suffix BETWEEN "0601" AND '0731'
    AND totals.transactions >=1
    AND productRevenue is not null
  GROUP BY month
  ORDER BY month
)

,avg_pageviews_non_purchaser as(
  SELECT  
    FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d', date)) as month
    ,ROUND(SUM(totals.pageviews)/COUNT(DISTINCT fullVisitorId),2) as avg_pageviews_non_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST (hits) hits,
  UNNEST (hits.product) product
  WHERE _table_suffix BETWEEN "0601" AND '0731'
    AND totals.transactions is null
    AND productRevenue is null
  GROUP BY month
  ORDER BY month
)

SELECT 
  pur.month
  ,pur.avg_pageviews_purchase
  ,non_pur.avg_pageviews_non_purchase
FROM  avg_pageview_purchaser as pur
LEFT JOIN avg_pageviews_non_purchaser as non_pur
ON pur.month = non_pur.month;

--query5
SELECT 
  FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d', date)) as month
  ,ROUND(SUM(totals.transactions)/COUNT(DISTINCT fullVisitorId),2) as Avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST (hits) hits,
UNNEST (hits.product) product
WHERE totals.transactions >=1
  AND productRevenue is not null
GROUP BY month
ORDER BY month;

--query6
SELECT 
  FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d', date)) as month
  ,ROUND(SUM(productRevenue)/(SUM(totals.visits)*1000000),2) as avg_spend_per_session
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST (hits) hits,
UNNEST (hits.product) product
WHERE totals.transactions >=1
  AND productRevenue is not null
GROUP BY month;

--query7
WITH buyer_list as(
    SELECT
        DISTINCT fullVisitorId  
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    , UNNEST(hits) as hits
    , UNNEST(hits.product) as product
    WHERE product.v2ProductName = "YouTube Men's Vintage Henley"
    AND totals.transactions>=1
    AND product.productRevenue is not null
)

SELECT
  product.v2ProductName as other_purchased_products,
  SUM(product.productQuantity) as quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
, UNNEST(hits) as hits
, UNNEST(hits.product) as product
INNER JOIN buyer_list USING(fullVisitorId)
WHERE product.v2ProductName != "YouTube Men's Vintage Henley"
 AND product.productRevenue is not null
GROUP BY other_purchased_products
ORDER BY quantity DESC;

--query8
WITH product_data as(
SELECT
  format_date('%Y%m', parse_date('%Y%m%d',date)) as month
  ,count(CASE WHEN eCommerceAction.action_type = '2' THEN product.v2ProductName END) as num_product_view
  ,count(CASE WHEN eCommerceAction.action_type = '3' THEN product.v2ProductName END) as num_add_to_cart
  ,count(CASE WHEN eCommerceAction.action_type = '6' and product.productRevenue is not null THEN product.v2ProductName END) as num_purchase
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
,UNNEST(hits) as hits
,UNNEST (hits.product) as product
WHERE _table_suffix BETWEEN '20170101' AND '20170331'
  AND eCommerceAction.action_type in ('2','3','6')
GROUP BY month
ORDER BY  month
)

SELECT
    *,
    ROUND(num_add_to_cart/num_product_view * 100, 2) as add_to_cart_rate,
    ROUND(num_purchase/num_product_view * 100, 2) as purchase_rate
FROM product_data;

