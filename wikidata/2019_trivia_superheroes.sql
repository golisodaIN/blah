SELECT views, title
   , ARRAY(SELECT DISTINCT AS STRUCT en_label, numeric_id FROM `fh-bigquery.wikidata.subclasses_20190822` JOIN UNNEST(occupation) USING(numeric_id)) occupation
   , ARRAY(SELECT DISTINCT AS STRUCT en_label, numeric_id FROM `fh-bigquery.wikidata.subclasses_20190822` JOIN UNNEST(instance_of) USING(numeric_id)) instance_of
   , ARRAY(SELECT AS STRUCT en_label, numeric_id FROM `fh-bigquery.wikidata.wikidata_latest_20190822` JOIN UNNEST(a.member_of) USING(numeric_id)) member_of
   , ARRAY(SELECT AS STRUCT en_label, numeric_id FROM `fh-bigquery.wikidata.wikidata_latest_20190822` JOIN UNNEST(a.from_fictional_universe) USING(numeric_id)) from_fictional_universe
FROM (
  SELECT SUM(views) views, title
    , ANY_VALUE(occupation) occupation, ANY_VALUE(instance_of) instance_of
    , ANY_VALUE(member_of) member_of, ANY_VALUE(from_fictional_universe) from_fictional_universe
  FROM `fh-bigquery.wikipedia_v3.pageviews_2019` a
  JOIN (
    SELECT *
    FROM `fh-bigquery.wikidata.wikidata_latest_20190822` 
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
) a
ORDER BY views DESC
