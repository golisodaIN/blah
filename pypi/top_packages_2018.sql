#standardSQL
# https://towardsdatascience.com/python-pypi-stats-in-bigquery-reclustered-d80e583e1bfe
# arbitrary algorithm

SELECT project, SUM(c) total
FROM (
  SELECT project, c, month
  FROM (
    SELECT *
      , (months[OFFSET(month_presence-1)]-months[OFFSET(0)])/months[OFFSET(month_presence-1)] growth
    FROM (
      SELECT project
        , ARRAY_AGG(c ORDER BY month) months
        , ARRAY_AGG(month ORDER BY month) monthsmonths
        , SUM(c) year, COUNT(*) month_presence
      FROM (
        SELECT project
          , TIMESTAMP_TRUNC(timestamp, MONTH) month
          , APPROX_COUNT_DISTINCT(FARM_FINGERPRINT(TO_JSON_STRING(details))) c
        FROM `fh-bigquery.pypi.pypi_2018` 
        WHERE timestamp > TIMESTAMP("2018-01-01") 
        AND timestamp < TIMESTAMP("2018-11-01") 
        GROUP BY  1,2
      )
      GROUP BY 1
    )
    WHERE year>5000
    AND months[OFFSET(0)]>500
    ORDER BY growth DESC
    LIMIT 10
  ), UNNEST(months) c WITH OFFSET x  JOIN UNNEST(monthsmonths) month WITH OFFSET x USING(x)
) GROUP BY 1 ORDER BY 2 DESC
