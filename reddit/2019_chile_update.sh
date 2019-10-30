bq query  --format=sparse '#standardSQL

SELECT FORMAT(
  """wget "http://dev.pushshift.io/rc/_search/?q=subreddit:chile AND created_utc:>=%i &sort=created_utc&size=10000" -O - | jq -c .hits.hits[]._source > tobq.json
wget "http://dev.pushshift.io/rc/_search/?q=subreddit:chile AND updated_utc:>=%i &sort=created_utc&size=10000" -O - | jq -c .hits.hits[]._source > tobq_updated.json
"""
  , created_utc, updated_utc)
FROM (
  SELECT MAX(created_utc) created_utc, MAX(updated_utc) updated_utc
  FROM `reddit_raw.201910_chile_raw_pushshift`
)
' | tail -n 3 | sh


bq load --source_format=NEWLINE_DELIMITED_JSON fh-bigquery:reddit_raw.201910_chile_raw_pushshift  tobq.json
bq load --source_format=NEWLINE_DELIMITED_JSON fh-bigquery:reddit_raw.201910_chile_raw_pushshift  tobq_updated.json


bq query "#standardSQL

CREATE OR REPLACE TABLE \`reddit_extracts.201910_chile\`
AS
SELECT * 
  EXCEPT(edited_body) 
  REPLACE(COALESCE(edited_body, body) AS body)
FROM (
  SELECT TIMESTAMP_SECONDS(x.created_utc) ts
    , FORMAT(REGEXP_EXTRACT(x.permalink, '^(.*)/[a-z0-9]*/$')) post
    , REGEXP_REPLACE(REGEXP_EXTRACT(x.permalink, '^.*/([^/]*)/[a-z0-9]*/$'), '_', ' ') post_title
    , FORMAT('https://reddit.com%s', REGEXP_EXTRACT(x.permalink, '^(.*)/[a-z0-9]*/')) link
    , x.*
  FROM (
    SELECT id, ARRAY_AGG(a ORDER BY retrieved_on DESC LIMIT 1)[OFFSET(0)] x
    FROM \`reddit_raw.201910_chile_raw_pushshift\` a
    WHERE TIMESTAMP_SECONDS(a.created_utc) > '2019-10-13'
    GROUP BY id
  )
)
;
CREATE OR REPLACE TABLE \`reddit_extracts.201910_chile_hour\`
AS
SELECT * REPLACE(TIMESTAMP(FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S', hour, 'Chile/Continental')) AS hour)
  , REGEXP_REPLACE(REGEXP_EXTRACT(top_post.value, '^.*/([^/]*)$'), '_', ' ') top_post_title
FROM (
  SELECT TIMESTAMP_TRUNC(ts, HOUR) hour, COUNT(*) comments
    , APPROX_TOP_COUNT(post, 1)[SAFE_OFFSET(0)] top_post
    , ARRAY_AGG(IF( body NOT IN ('[deleted]','[removed]') AND score>=1,STRUCT(score,replies,permalink, body),null) IGNORE NULLs ORDER BY replies DESC LIMIT 1)[OFFSET(0)] top_comm
  FROM (
    SELECT *, (SELECT COUNT(*) FROM \`reddit_extracts.201910_chile\` WHERE parent_id=a.id) replies
    FROM \`reddit_extracts.201910_chile\` a
  )
  GROUP BY 1
)

"
