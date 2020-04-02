# https://medium.com/@hoffa/covid-19-arima-predictions-are-worthless-f34e52139769

CREATE OR REPLACE MODEL temp.numreports_forecast
OPTIONS(model_type='ARIMA',
       time_series_data_col='num_reports',
       time_series_timestamp_col='date') AS
SELECT
   date, SUM(confirmed) num_reports
FROM `bigquery-public-data.covid19_jhu_csse.summary`
WHERE country_region = 'Japan'
AND date < '2020-03-25'
GROUP BY date
ORDER BY date ASC
;
 
SELECT date, forecast
  , TO_JSON_STRING([fhoffa.x.int(confidence_interval_lower_bound), fhoffa.x.int(confidence_interval_upper_bound)]) bounds
  , confirmed actual_confirmed, ROUND((confirmed-forecast)/confirmed * 100,1) error
FROM (
  SELECT DATE(forecast_timestamp) date, fhoffa.x.int((forecast_value)) AS forecast
      , confidence_interval_lower_bound, confidence_interval_upper_bound
  FROM ML.FORECAST(MODEL temp.numreports_forecast,
  STRUCT(14 AS horizon, 0.9 AS confidence_level))
) JOIN (
  SELECT date, SUM(confirmed) confirmed
  FROM `bigquery-public-data.covid19_jhu_csse.summary`
  WHERE country_region = 'Japan'
  GROUP BY 1
)
USING(date)
ORDER BY date
