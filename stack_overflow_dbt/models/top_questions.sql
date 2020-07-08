{{ config(materialized='table'
  , partition_by={'field': 'quarter', 'data_type': 'date'}
  , cluster_by='tag' ) }}


WITH stats AS (
  SELECT tag, id
    , SUM(IF(quarter='2020-06-01', quarter_views, null)) last_quarter
    , SUM(quarter_views) total_views
    , ARRAY_AGG(STRUCT(quarter, quarter_views) ORDER BY quarter DESC) views
    , ARRAY_AGG(title ORDER BY quarter DESC LIMIT 1)[OFFSET(0)] title
  FROM {{ref('source_question_views')}} a
  GROUP BY 1,2
)

SELECT x.* EXCEPT(views), quarter, quarter_views
FROM (
  SELECT ARRAY_AGG(a ORDER BY last_quarter DESC LIMIT 30) arr
  FROM stats a
  WHERE tag IN (SELECT tag FROM {{ref('stats_tags')}})
  GROUP BY tag
), UNNEST(arr) x, UNNEST(x.views)
WHERE quarter > '2017-03-01'