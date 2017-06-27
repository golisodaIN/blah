#standardSQL
SELECT Country, c
  , ARRAY(
    SELECT AS STRUCT value, count, ROUND(100*count/SUM(count) OVER(PARTITION BY Country), 2) percent FROM UNNEST(v)
  ) v
FROM (
  SELECT Country, APPROX_TOP_COUNT(IF(Gender NOT IN ('Female', 'Male'), 'Other', Gender), 3) v, COUNT(*) c
  FROM `fh-bigquery.stackoverflow.survey_results_public_2017` 
  WHERE Gender!='NA'
  GROUP BY 1
  HAVING c>70
)
ORDER BY (SELECT percent FROM UNNEST(v) WHERE value='Female')

# https://twitter.com/felipehoffa/status/879806078866776064
