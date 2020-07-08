{{ config(materialized='table', cluster_by='tag' ) }}

{% call set_sql_header(config) %}
CREATE OR REPLACE MODEL `temp.arima_dailyquarter`
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
;
{% endcall %}

SELECT *
  , MAX(IF(quarter='2020-06-01',ratio,null)) OVER(PARTITION BY tag) ratio_20200601 
  , MAX(IF(quarter='2023-06-01',ratio,null)) OVER(PARTITION BY tag) ratio_20230601 
FROM (
    SELECT tag, ratio, quarter
    FROM {{ref('tag_views')}}
    WHERE tag IN (
    SELECT tag
    FROM {{ref('stats_tags')}}
    ORDER BY rank_current
    LIMIT 15000 
    )
    UNION ALL
    SELECT tag
    , forecast_value ratio
    , DATE_ADD('2017-03-01', INTERVAL DATE_DIFF(DATE(forecast_timestamp), '2020-03-01', DAY) QUARTER) quarter
    FROM ML.FORECAST( MODEL `temp.arima_dailyquarter` , STRUCT(12 AS horizon, 0.1 AS confidence_level))
)