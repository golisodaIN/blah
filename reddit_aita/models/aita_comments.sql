{{ config(materialized='incremental', unique_key='id', partition_by='fake_date', cluster_by='id' ) }}
{# clustering helps a lot with MERGE costs #}

SELECT author, score, TIMESTAMP_SECONDS(created_utc) ts, parent_id, link_id, controversiality, id, body, DATE('2000-01-01') fake_date
FROM {{ source('reddit_comments', '20*') }}
WHERE subreddit = 'AmItheAsshole'
AND _table_suffix > '19_'

{%- if is_incremental() -%}
{%- if execute -%}
{%- set last_stamp_sql -%}SELECT FORMAT_TIMESTAMP('%y_%mX', MAX(ts)) maxsuffix FROM {{this}}{%- endset -%}
{%- set last_stamp_result = run_query(last_stamp_sql) -%}
AND _table_suffix > "{{last_stamp_result.rows[0].get('maxsuffix')[:-1]}}"
{# Somewhere '19_01' gets transformed to '1901', unless I add an 'X' to FORMAT_TIMESTAMP() and [:-1] later. #} 
{%- endif -%}
{%- endif -%}

