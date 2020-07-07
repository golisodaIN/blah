{{ config(materialized='table', cluster_by='tag' ) }}

SELECT * 
FROM {{ref('tag_views')}}
JOIN {{ref('stats_tags')}}
USING(tag)
