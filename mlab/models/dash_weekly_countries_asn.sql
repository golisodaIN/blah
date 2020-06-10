{{ config(materialized='incremental' ) }}

SELECT week, client.Geo.country_name country, client.Network.ASNumber
, ROUND(AVG( MeanThroughputMbps ),2) download_avg
, ROUND(APPROX_QUANTILES(MeanThroughputMbps, 100)[OFFSET(50)],2) download_median
, COUNT(*) ips
FROM {{ref('summary_downloads_weekly')}}
WHERE client.Geo.country_name IN (SELECT country FROM {{ref('aux_top_countries')}})
GROUP BY 1,2,3
HAVING ips > 100