{{ config(materialized='table') }}
  SELECT *, c/total_gender AS perc
  FROM (
    SELECT *, SUM(c) OVER(PARTITION BY to_gender, MONTH ) total_gender, SUM(c) OVER(PARTITION BY judgement, MONTH) total_judgement
    FROM (
      SELECT to_gender, judgement, CONCAT(to_gender, ': ', judgement) to_gender_judgement, month, COUNT(*) c, ARRAY_AGG(STRUCT(title, selftext) ORDER BY RAND() LIMIT 1)[OFFSET(0)] sample_title
      FROM {{ref('aita_posts_gendered')}} 
      WHERE judgement IS NOT null
      AND to_gender != 'neutral'
      GROUP BY 1,2,3,4
    )
  )
  WHERE c/total_gender > 0.01
  AND total_judgement > 10
  ORDER BY to_gender, perc DESC
