SELECT Country
  , c_2017, (SELECT AS STRUCT * FROM UNNEST (v_2017) WHERE value='Female') v_2017
  , c_2016, (SELECT AS STRUCT * FROM UNNEST (v_2016) WHERE value='Female') v_2016
FROM (

  SELECT a.Country, a.c c_2017
    , ARRAY(
      SELECT AS STRUCT value, count, ROUND(100*count/SUM(count) OVER(PARTITION BY a.Country), 2) percent FROM UNNEST(a.v)
    ) v_2017, b.c c_2016
    , ARRAY(
      SELECT AS STRUCT value, count, ROUND(100*count/SUM(count) OVER(PARTITION BY a.Country), 2) percent FROM UNNEST(b.v)
    ) v_2016
  FROM (
    SELECT Country, APPROX_TOP_COUNT(IF(Gender NOT IN ('Female', 'Male'), 'Other', Gender), 3) v, COUNT(*) c
    FROM `fh-bigquery.stackoverflow.survey_results_public_2017` 
    WHERE Gender!='NA'
    GROUP BY 1
    HAVING c>70
  ) a
  JOIN (
   SELECT Country, c
    , ARRAY(
      SELECT AS STRUCT value, count, ROUND(100*count/SUM(count) OVER(PARTITION BY Country), 2) percent FROM UNNEST(v)
    ) v
  FROM (
    SELECT Country, APPROX_TOP_COUNT(IF(Gender NOT IN ('Female', 'Male'), 'Other', Gender), 3) v, COUNT(*) c
    FROM `fh-bigquery.stackoverflow.survey_results_2016`  
    WHERE Gender!='NA'
    GROUP BY 1
    HAVING c>70
  ) ) b

  ON a.country=b.country
)
ORDER BY v_2017.percent 
