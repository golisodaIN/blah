{{ config(materialized='table') }}
SELECT *
FROM (
    SELECT *, c/SUM(c) OVER(PARTITION BY month) ratio
    FROM (
        SELECT link_flair_text, month, COUNT(*) c
        FROM {{ref('aita_posts')}} 
        WHERE link_flair_text IS NOT null
        GROUP BY 1,2
        HAVING c>130
    )
)
WHERE ratio>0.01