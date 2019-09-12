SELECT views, title
   , [(SELECT IFNULL(STRING_AGG(DISTINCT en_label),'') FROM `fh-bigquery.wikidata.subclasses_20190822` JOIN UNNEST(occupation) USING(numeric_id)) 
   , (SELECT STRING_AGG(DISTINCT en_label) FROM `fh-bigquery.wikidata.subclasses_20190822` JOIN UNNEST(instance_of) USING(numeric_id)) 
   , (SELECT IFNULL(STRING_AGG(en_label),'') FROM `fh-bigquery.wikidata.wikidata_latest_20190822` JOIN UNNEST(a.member_of) USING(numeric_id)) 
   , (SELECT IFNULL(STRING_AGG(en_label),'') FROM `fh-bigquery.wikidata.wikidata_latest_20190822` JOIN UNNEST(a.from_fictional_universe) USING(numeric_id))] annotated
FROM (
  SELECT SUM(views) views, title
    , ANY_VALUE(occupation) occupation, ANY_VALUE(instance_of) instance_of
    , ANY_VALUE(member_of) member_of, ANY_VALUE(from_fictional_universe) from_fictional_universe
  FROM `fh-bigquery.wikipedia_v3.pageviews_2018` a
  JOIN (
    SELECT en_wiki, occupation, member_of, from_fictional_universe, instance_of
    FROM `fh-bigquery.wikidata.wikidata_latest_20190822` 
    WHERE EXISTS (SELECT * FROM UNNEST(instance_of) WHERE numeric_id=188784)
    AND en_wiki IS NOT null
  ) b
  ON a.title=b.en_wiki
  AND a.wiki='en'
  AND DATE(a.datehour) BETWEEN '2018-02-01' AND '2018-02-07'  GROUP BY title
  ORDER BY views DESC
  LIMIT 10
) a
ORDER BY views DESC
