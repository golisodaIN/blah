Top artists and songs:

SELECT COUNT(*) c,
       JSON_EXTRACT_SCALAR(item, '$.metadata.tags.artist[0]') artist,
       JSON_EXTRACT_SCALAR(item, '$.metadata.tags.title[0]') song,
FROM [fh-bigquery:test_acousticbrainz.lowlevel] 
GROUP BY 2,3
ORDER BY 1 DESC
LIMIT 100


Top genders:

SELECT COUNT(*) c,
       JSON_EXTRACT_SCALAR(item, '$.highlevel.gender.value') gender,
FROM [fh-bigquery:test_acousticbrainz.highlevel] 
GROUP BY 2
ORDER BY 1 DESC
LIMIT 100

Correlation between loudness and bpm, by genre:

SELECT 
  COUNT(*) c,
  CORR(
    JSON_EXTRACT_SCALAR(item, '$.lowlevel.average_loudness'),
    JSON_EXTRACT_SCALAR(item, '$.rhythm.bpm')
  ),
  JSON_EXTRACT_SCALAR(item, '$.metadata.tags.genre[0]')
FROM [fh-bigquery:test_acousticbrainz.lowlevel] 
GROUP BY 3
HAVING c>30
ORDER BY 2 DESC
LIMIT 100


