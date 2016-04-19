SELECT SUM(requests) reqs, FIRST(en_label), title
FROM [fh-bigquery:wikipedia.pagecounts_201509] a
JOIN (
  SELECT es_wiki, en_label, en_wiki, fr_wiki, ja_wiki
  FROM FLATTEN([fh-bigquery:wikidata.latest_enesjafrde_v1], subclass_of) a
  JOIN (
    SELECT numeric_id
    FROM [fh-bigquery:wikidata.subclasses] b
    WHERE subclass_of_numeric_id=349 # sports
    GROUP BY 1
  ) b
  ON a.subclass_of.numeric_id=b.numeric_id
) b
ON a.title=b.es_wiki
WHERE language='es'
GROUP BY title 
ORDER BY 1 DESC
LIMIT 100


SELECT SUM(requests) reqs, FIRST(en_label)
FROM [fh-bigquery:wikipedia.pagecounts_201511] a
JOIN (
  SELECT es_wiki, en_label, en_wiki, fr_wiki, ja_wiki
  FROM [fh-bigquery:wikidata.latest_enesjafrde_v1] 
  WHERE instance_of.numeric_id=31629
) b
ON a.title=b.es_wiki
WHERE language='es'
GROUP BY title 
ORDER BY 1 DESC
LIMIT 100

