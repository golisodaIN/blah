SELECT views, title
   , ARRAY(SELECT DISTINCT AS STRUCT en_label, numeric_id FROM `fh-bigquery.wikidata.subclasses_20190822` JOIN UNNEST(occupation) USING(numeric_id)) occupation
   , ARRAY(SELECT DISTINCT AS STRUCT en_label, numeric_id FROM `fh-bigquery.wikidata.subclasses_20190822` JOIN UNNEST(instance_of) USING(numeric_id)) instance_of
   , ARRAY(SELECT AS STRUCT en_label, numeric_id FROM `fh-bigquery.wikidata.wikidata_latest_20190822` JOIN UNNEST(a.gender) USING(numeric_id)) gender
   , date_of_birth
FROM (
  SELECT SUM(views) views, title
    , ANY_VALUE(occupation) occupation, ANY_VALUE(instance_of) instance_of
    , ANY_VALUE(gender) gender, ANY_VALUE(date_of_birth) date_of_birth
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
      WHERE numeric_id=82955
      LIMIT 1
    )
    AND en_wiki IS NOT null
    AND ARRAY_LENGTH(sitelinks)>=40
  ) b
  ON a.title=b.en_wiki
  AND a.wiki='en'
  AND DATE(a.datehour)='2019-08-08'
  GROUP BY title
) a
ORDER BY views DESC
