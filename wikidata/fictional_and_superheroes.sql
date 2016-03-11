SELECT en_wiki, SUM(requests) requests,
  FIRST(superhero) superhero, FIRST(fictional_character) fictional_character, FIRST(occupation_superhero) occupation_superhero,
  VARIANCE(LOG(requests)) varlog
FROM [fh-bigquery:wikipedia.pagecounts_201602_en_top365k] a
JOIN (
  SELECT en_wiki, 
    NOT EVERY(instance_of.numeric_id!=188784) WITHIN RECORD superhero,
    NOT EVERY(instance_of.numeric_id!=95074) WITHIN RECORD fictional_character,
    NOT EVERY(occupation.numeric_id!=188784) WITHIN RECORD occupation_superhero,
  FROM [wikidata.latest_en_v1] 
  OMIT RECORD IF (EVERY(instance_of.numeric_id!=188784)
  AND EVERY(instance_of.numeric_id!=95074)
  AND EVERY(occupation.numeric_id!=188784))
) b
ON a.title=b.en_wiki
GROUP BY 1
HAVING varlog<0.5
ORDER BY 2 DESC
LIMIT 100
