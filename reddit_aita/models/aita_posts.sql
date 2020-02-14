{{ config(materialized='incremental', unique_key='id', partition_by='fake_date', cluster_by='id' ) }}
{# clustering helps a lot with MERGE costs #}

SELECT created_utc, subreddit, author, domain, url, num_comments, score, title, selftext, id, gilded, over_18
  , link_flair_css_class, author_flair_css_class, permalink, author_flair_text, LOWER(link_flair_text) link_flair_text, distinguished
  , TIMESTAMP_SECONDS(created_utc) ts
  , DATE('2000-01-01') fake_date
  , DATE(TIMESTAMP_TRUNC(TIMESTAMP_SECONDS(created_utc), MONTH)) month
FROM {{ source('reddit_posts', '20*') }}
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

