SELECT views, title
   , ARRAY(SELECT DISTINCT AS STRUCT en_label, numeric_id FROM `fh-bigquery.wikidata.subclasses_20190822_b` a JOIN UNNEST(occupation) b USING(numeric_id)) occupation
   , ARRAY(SELECT DISTINCT AS STRUCT en_label, numeric_id FROM `fh-bigquery.wikidata.subclasses_20190822_b` a JOIN UNNEST(instance_of) b USING(numeric_id)) instance_of
FROM (
  SELECT SUM(views) views, title
    , ANY_VALUE(occupation) occupation, ANY_VALUE(instance_of) instance_of
  FROM `fh-bigquery.wikipedia_v3.pageviews_2019` a
  JOIN (
    SELECT *
    FROM `fh-bigquery.wikidata.wikidata_latest_20190822_b` 
    WHERE EXISTS (
      SELECT * FROM (
        SELECT * FROM UNNEST(occupation)
        UNION ALL
        SELECT * FROM UNNEST(instance_of) 
      )
      WHERE numeric_id=188784
      LIMIT 1
    )
    AND en_wiki IS NOT null
  ) b
  ON a.title=b.en_wiki
  AND a.wiki='en'
  AND DATE(a.datehour)='2019-01-08'
  GROUP BY title
)
ORDER BY views DESC
