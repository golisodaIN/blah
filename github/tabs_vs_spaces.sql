SELECT ext, c, best, countext
FROM (
  SELECT COUNT(*) c, best, REGEXP_EXTRACT(sample_path, r'\.([^\.]*)$') ext, SUM(c) OVER(PARTITION BY ext) countext
  FROM (
    SELECT sample_path, sample_repo_name, IF(SUM(line=' ')>SUM(line='\t'), 'space', 'tab') WITHIN RECORD best
    FROM (
      SELECT LEFT(SPLIT(content, '\n'), 1) line, sample_path, sample_repo_name 
      FROM [bigquery-public-data:github_repos.sample_contents]
      HAVING REGEXP_MATCH(line, r'[ \t]')
    )
  )
  GROUP BY 2,3
)
WHERE countext>500
ORDER BY countext DESC, c DESC
LIMIT 100
