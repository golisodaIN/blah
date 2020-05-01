CREATE OR REPLACE TABLE 
  `fh-bigquery.public_dump.applemobilitytrends`
OPTIONS (
  description="https://www.apple.com/covid19/mobility"
) AS
WITH data AS (
  SELECT geo_type, region, transportation_type, unpivotted.*
    , LEAST(-1 + value/100, 0.2) percent
  FROM `fh-bigquery.temp.latestAppleCovidData` a
    , UNNEST(fhoffa.x.cast_kv_array_to_date_float(
      fhoffa.x.unpivot(a, '_2020'), '_%Y_%m_%d')) unpivotted
  WHERE a._2020_04_27 IS NOT NULL
), annotated_data AS (
  SELECT *
    , -1+EXP(AVG(LOG(1+percent)) OVER(PARTITION BY geo_type, region, transportation_type ORDER BY date DESC
      rows between 6 preceding and current row)) avg7day 
    , geo_type||transportation_type||region series_id
  FROM data
), lat_lons AS  (
  SELECT region, latlon || ROW_NUMBER() OVER(PARTITION BY latlon ORDER BY region) latlon
  FROM (
    SELECT region, ROUND(ST_Y(centroid),7)||','||ROUND(ST_X(centroid),7) latlon
    FROM (
      SELECT geoid region, ST_CENTROID(geom) centroid
      FROM `carto-do-public-data.glo_covid19_apple.geography_glo_locations_v1`
    )
  )
)

SELECT *, ROW_NUMBER() OVER(ORDER BY current_percent) rank 
FROM (
  SELECT *
    , (SELECT percent 
       FROM annotated_data 
       WHERE a.series_id=series_id 
       AND date=(SELECT MAX(date) FROM annotated_data)
       ) current_percent
    , (SELECT MIN(date) FROM annotated_data WHERE a.series_id=series_id AND avg7day<-.25) first_drop_date 
  FROM annotated_data a
  LEFT JOIN lat_lons b
  USING(region)
)

