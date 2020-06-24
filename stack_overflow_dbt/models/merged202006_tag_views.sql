{{ config(materialized='incremental', cluster_by='tag' ) }}

SELECT * 
FROM (
  SELECT *, COUNT(DISTINCT tag) OVER() total_distinct_tags
  FROM (
    SELECT *, MAX(quarter_views) OVER(PARTITION BY tag) total_tag_views
      , 10000*quarter_views/SUM(quarter_views) OVER(PARTITION BY quarter) ratio
    FROM (
      SELECT tag, quarter, SUM(quarter_views) quarter_views 
      FROM {{ref('source_merged202006_question_views')}}
      WHERE quarter>'2017-03-01'

{%- if is_incremental() -%}
{%- if execute -%}
{# This minimizes a 5GB query to 50MB. #} 
{%- set last_stamp_sql -%}SELECT MAX(quarter) maxsuffix FROM {{this}} WHERE tag='google-bigquery'{%- endset -%}
{%- set last_stamp_result = run_query(last_stamp_sql) %}

AND quarter > "{{last_stamp_result.rows[0].get('maxsuffix')}}"
{%- endif -%}
{%- endif -%}

      GROUP BY tag, quarter
      HAVING quarter_views > 0
    )
  )
  WHERE total_tag_views>7500
)
