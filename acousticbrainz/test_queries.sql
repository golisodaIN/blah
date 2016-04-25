SELECT COUNT(*) c,
       JSON_EXTRACT_SCALAR(item, '$.metadata.tags.artist[0]') artist,
       JSON_EXTRACT_SCALAR(item, '$.metadata.tags.title[0]') song,
FROM [test_acousticbrainz.lowlevel] 
GROUP BY 2,3
ORDER BY 1 DESC
LIMIT 100
