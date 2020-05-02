WITH data AS (
  SELECT * 
    , grocery_and_pharmacy_percent_change_from_baseline AS stores 
    , parks_percent_change_from_baseline AS parks
    , transit_stations_percent_change_from_baseline AS transit
    , workplaces_percent_change_from_baseline AS work
    , residential_percent_change_from_baseline AS home
  FROM  `bigquery-public-data.covid19_google_mobility.mobility_report`
  WHERE sub_region_2 IS null AND sub_region_1 IS null
), unpivotted AS (
  SELECT * EXCEPT(x) 
  FROM (
    SELECT *
      , [STRUCT('stores' AS google_type, stores AS google), ('parks', parks), ('transit', transit), ('work', work), ('home', home)] x
    FROM data
  ), UNNEST(x)
), joined AS (
  SELECT country_region, google_type, b.transportation_type apple_type, google, b.value apple, a.date
  FROM unpivotted a 
  JOIN `fh-bigquery.public_dump.applemobilitytrends` b
  ON a.country_region=b.region 
  AND a.date=b.date
--   WHERE country_region_code IN ('JP', 'CL', 'US', 'VN', 'AR', 'BE')
)


SELECT * EXCEPT(x), x.*
FROM (
  SELECT country_region, ARRAY_AGG(STRUCT(google_type , apple_type , corr, avg_goog, avg_appl, days) ORDER BY ABS(corr) DESC LIMIT 1)[OFFSET(0)] x
  FROM (
    SELECT country_region, google_type, apple_type, ROUND(100*CORR(google, apple),2) corr, COUNT(*) days, ROUND(AVG(google),1) avg_goog, ROUND(AVG(apple),1) avg_appl
    FROM joined
    WHERE date > '2020-04-01'
    GROUP BY 1,2,3
  )
  GROUP BY 1
)
ORDER BY ABS(corr) DESC
