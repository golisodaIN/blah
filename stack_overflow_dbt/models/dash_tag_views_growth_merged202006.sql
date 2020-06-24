{{ config(materialized='table', cluster_by='tag' ) }}

SELECT * 
FROM {{ref('merged202006_tag_views')}}
JOIN {{ref('stats_tag_merged202006')}}
USING(tag)
