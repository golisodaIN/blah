{{ config(materialized='incremental' ) }}

SELECT week
, ROUND(AVG( MeanThroughputMbps ),2) download_avg
, ROUND(APPROX_QUANTILES(MeanThroughputMbps, 100)[OFFSET(50)],2) download_median
, COUNT(*) ips
FROM {{ref('summary_downloads_weekly')}}
GROUP BY 1