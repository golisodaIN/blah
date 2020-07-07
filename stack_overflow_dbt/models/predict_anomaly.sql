{{ config(materialized='table', cluster_by='tag' ) }}

{% call set_sql_header(config) %}
CREATE OR REPLACE MODEL `temp.arima_anomaly`
OPTIONS(model_type='ARIMA',
        time_series_id_col='tag',
        time_series_data_col='ratio',    
        time_series_timestamp_col='quarter'
        )
AS SELECT tag, ratio
  , DATE_ADD('2020-03-01', INTERVAL DATE_DIFF(quarter, '2017-01-01', QUARTER) DAY) quarter
FROM `stackoverflow_dbt.tag_views`
WHERE tag IN (
  SELECT tag
  FROM `stackoverflow_dbt.stats_tags`
  ORDER BY rank_current
  LIMIT 15000  
)
AND quarter < (SELECT MAX(quarter) FROM `stackoverflow_dbt.tag_views`)
;
{% endcall %}


SELECT tag, 'actual' series
   , ratio, quarter
   , ratio confidence_interval_lower_bound
   , ratio confidence_interval_upper_bound
FROM {{ref('tag_views')}}
WHERE tag IN (
  SELECT tag
  FROM {{ref('stats_tags')}}
  ORDER BY rank_current
  LIMIT 15000 
)
UNION ALL
SELECT tag, 'predicted' series
   , forecast_value ratio
   , DATE_ADD('2017-03-01', INTERVAL DATE_DIFF(DATE(forecast_timestamp), '2020-03-01', DAY) QUARTER) quarter
   , confidence_interval_lower_bound
   , confidence_interval_upper_bound
FROM ML.FORECAST( MODEL `temp.arima_anomaly` , STRUCT(4 AS horizon, 0.5 AS confidence_level))


