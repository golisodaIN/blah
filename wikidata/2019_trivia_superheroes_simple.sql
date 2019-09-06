# who were the top superheros on Wikipedia the first days of 2018-02?

SELECT SUM(views) views, title
-- , ARRAY_AGG(STRUCT(datehour, views) ORDER BY datehour) timeline
FROM `fh-bigquery.wikipedia_v2.pageviews_2018` a
JOIN (
  SELECT DISTINCT en_wiki 
  FROM `fh-bigquery.wikidata.wikidata_latest_20190822` 
  WHERE EXISTS (SELECT * FROM UNNEST(instance_of) WHERE numeric_id=188784)
  AND en_wiki IS NOT null 
) b
ON a.title=b.en_wiki
AND a.wiki='en'
AND DATE(a.datehour) BETWEEN '2018-02-01' AND '2018-02-04'
GROUP BY title
ORDER BY views DESC
LIMIT 10
