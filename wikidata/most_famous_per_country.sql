SELECT label, requests, iso_3166_alpha3.value 
FROM (
  SELECT a.en_wiki, a.en_label label, requests, place, b.en_label, iso_3166_alpha3.value 
  FROM (
    SELECT en_wiki, FIRST(en_label) en_label, FIRST('Q'+STRING(place)) place, SUM(requests) requests, ROW_NUMBER() OVER(PARTITION BY place ORDER BY requests DESC) rank
    FROM ( 
      SELECT en_wiki, en_label, country_of_citizenship.numeric_id place
      FROM [fh-bigquery:wikidata.latest_enesjafrde_v1_a]
      OMIT RECORD IF en_wiki IS null
      OR NOT SOME(instance_of.numeric_id = 5)
      OR NOT SOME(gender.numeric_id = 6581072)  
      HAVING place IS NOT null
    ) a
    JOIN (SELECT title, requests FROM [fh-bigquery:wikipedia.pagecounts_201603] WHERE language='en') b
    ON a.en_wiki=b.title
    GROUP BY 1) a
  JOIN [fh-bigquery:wikidata.latest_enesjafrde_v1_a] b
  ON a.place=b.id
  WHERE rank=1
  ORDER BY requests DESC)
 WHERE iso_3166_alpha3.value IS NOT null
