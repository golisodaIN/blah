SELECT ROUND(ArrDelayMinutes/60,2) HoursDelay, FlightDate, Origin, Dest, Reporting_Airline 
FROM `fh-bigquery.flights.ontime_201903` 
WHERE FlightDate_year >"2000-01-01"
AND Origin = 'SJC' AND Dest = 'SEA'
ORDER BY 1 DESC 
LIMIT 100
