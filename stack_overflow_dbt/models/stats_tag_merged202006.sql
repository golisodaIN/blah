{{ config(materialized='table' ) }}

WITH data AS (
  SELECT tag, SUM(quarter_views) total_views
    , ARRAY_AGG(STRUCT(quarter, quarter_views, ratio) ORDER BY quarter DESC) stats_arr
  FROM {{ref('merged202006_tag_views')}}
  GROUP BY 1
), stats AS (
  SELECT *
    , CASE
      WHEN growth_ratio > 0.095 THEN '1 super_growth'
      WHEN growth_ratio > 0.043 THEN '2 growth'
      WHEN growth_ratio > 0.012 THEN '3 slow_growth'
      WHEN growth_ratio > -0.05 THEN '4 stable'
      WHEN growth_ratio > -0.11 THEN '5 losing'
      WHEN growth_ratio > -0.16 THEN '6 losing_fast'
      ELSE '7 losing_extra_fast'
      END growth_group
    , ROW_NUMBER() OVER(ORDER BY total_views DESC) rank_total
    , ROW_NUMBER() OVER(ORDER BY ratio_current DESC) rank_current
    , ROW_NUMBER() OVER(ORDER BY ratio_year_ago DESC) rank_year_ago
    , ROW_NUMBER() OVER(ORDER BY ratio_2year_ago DESC) rank_2year_ago
  FROM (
    SELECT *
      , (ratio_current-ratio_year_ago)/(ratio_current+ratio_year_ago) growth_ratio
    FROM (
      SELECT * EXCEPT(stats_arr)
        , stats_arr[OFFSET(0)].ratio ratio_current
        , IFNULL(stats_arr[SAFE_OFFSET(4)].ratio, 0) ratio_year_ago
        , IFNULL(stats_arr[SAFE_OFFSET(8)].ratio, 0) ratio_2year_ago
      FROM data
    )
  )
)


SELECT *
FROM stats