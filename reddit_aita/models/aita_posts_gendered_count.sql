SELECT judgement
  , to_gender
  , SUM(c) c, SUM(perc) perc
  , ARRAY_AGG(sample_title ORDER BY RAND() LIMIT 1)[OFFSET(0)] sample_title
FROM (
  SELECT *, c/total_gender AS perc
  FROM (
    SELECT *, SUM(c) OVER(PARTITION BY to_gender ) total_gender, SUM(c) OVER(PARTITION BY judgement) total_judgement
    FROM (
      SELECT to_gender, judgement, COUNT(*) c, ARRAY_AGG(STRUCT(title, selftext) ORDER BY RAND() LIMIT 1)[OFFSET(0)] sample_title
      FROM {{ref('aita_posts_gendered')}} 
      GROUP BY 1,2
    )
  )
  WHERE c/total_gender > 0.01
  AND total_judgement > 10
  ORDER BY to_gender, perc DESC
)
GROUP BY 1,2
HAVING judgement IS NOT null