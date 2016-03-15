SELECT en_wiki, SUM(requests) requests, FIRST(instance_of) instance_of, VARIANCE(LOG(requests)) logvar
FROM [fh-bigquery:wikipedia.pagecounts_201602_en_top365k] a 
JOIN (
  SELECT en_wiki, GROUP_CONCAT(b.en_label) instance_of
  FROM FLATTEN([wikidata.latest_en_v1], instance_of) a
  JOIN (
    SELECT numeric_id, GROUP_CONCAT(en_label) en_label
    FROM [fh-bigquery:wikidata.subclasses] b
    WHERE subclass_of_numeric_id=95074 # fictional character
    GROUP BY 1
  ) b
  ON a.instance_of.numeric_id=b.numeric_id
  GROUP BY 1
) b
ON a.title=b.en_wiki
#WHERE language='en'
GROUP BY 1
HAVING logvar<2
ORDER BY 2 DESC
LIMIT 8000

