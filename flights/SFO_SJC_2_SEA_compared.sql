SELECT year
  , ARRAY_AGG(STRUCT(Origin, AvgElapsedTime, AvgDelay, MaxDelay, Reporting_Airline) ORDER BY AvgElapsedTime) best_to_worse
FROM (
  SELECT ROUND(AVG(ActualElapsedTime)/60,2) AvgElapsedTime
    , ROUND(AVG(ArrDelayMinutes)/60,2) AvgDelay
    , ROUND(MAX(ArrDelayMinutes)/60,2) MaxDelay
    , EXTRACT(YEAR FROM FlightDate) year, Origin, Dest, Reporting_Airline, COUNT(*) flights
  FROM `fh-bigquery.flights.ontime_201903` 
  WHERE FlightDate_year >"2000-01-01"
  AND Origin IN ('SJC', 'SFO')  AND Dest = 'SEA'
  GROUP BY  Origin , Dest, Reporting_Airline , year
  HAVING flights > 100
)
GROUP BY 1,Dest
ORDER BY year DESC

# https://twitter.com/felipehoffa/status/1153469344799547392
