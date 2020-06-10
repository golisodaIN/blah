{{ config(materialized='incremental', partition_by={'field':'week'}, cluster_by='ip' ) }}

SELECT week, x.*, ip_tests
FROM (
  SELECT DATE_TRUNC(test_date, week) week, ip
    , ARRAY_AGG(a ORDER BY MeanThroughputMbps DESC LIMIT 1)[OFFSET(0)] x
    , COUNT(*) ip_tests
  FROM  {{ref('source_mlab_downloads')}}  a
  WHERE test_date<DATE_TRUNC(CURRENT_DATE(), WEEK)
  GROUP BY 1,2
)
