Top artists and songs:

SELECT COUNT(*) c,
       JSON_EXTRACT_SCALAR(item, '$.metadata.tags.artist[0]') artist,
       JSON_EXTRACT_SCALAR(item, '$.metadata.tags.title[0]') song,
FROM [test_acousticbrainz.lowlevel] 
GROUP BY 2,3
ORDER BY 1 DESC
LIMIT 100


Top genders:

SELECT COUNT(*) c,
       JSON_EXTRACT_SCALAR(item, '$.highlevel.gender.value') gender,
FROM [test_acousticbrainz.highlevel] 
GROUP BY 2
ORDER BY 1 DESC
LIMIT 100
