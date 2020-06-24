{{ config(materialized='incremental', cluster_by='tag' ) }}

WITH data AS (
  SELECT *, PARSE_DATE('%Y%m%d', _table_suffix||'01') quarter
  FROM `fh-bigquery.stackoverflow_archive_questions.q*`


{%- if is_incremental() -%}
{%- if execute -%}
{# This minimizes a 5GB query to 50MB. #} 
{%- set last_stamp_sql -%}SELECT FORMAT_DATE('%Y%m', MAX(quarter)) maxsuffix FROM {{this}} WHERE tag='google-bigquery'{%- endset -%}
{%- set last_stamp_result = run_query(last_stamp_sql) %}
WHERE _table_suffix > "{{last_stamp_result.rows[0].get('maxsuffix')}}"
{%- endif -%}
{%- endif -%}

), last_data AS (
  SELECT id, ARRAY_AGG(STRUCT(tags, title) ORDER BY quarter DESC LIMIT 1)[OFFSET(0)] info, 
  FROM data
  GROUP BY id
), quarter_and_last AS (
  SELECT id
    , quarter
    , view_count - IFNULL(LAG(view_count) OVER(PARTITION BY id ORDER BY quarter),0) quarter_views
    , (SELECT info FROM last_data WHERE id=a.id) info
  FROM data a
)

SELECT * EXCEPT(info), info.title
FROM quarter_and_last, UNNEST(SPLIT(info.tags,'|')) tag

