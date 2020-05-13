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
    , -1+
      CASE 
        WHEN DATE_DIFF(CURRENT_DATE(), date,  DAY) < 4
        THEN EXP(AVG(LOG(1+percent)) OVER(PARTITION BY geo_type, region, transportation_type ORDER BY date DESC
          rows between 0 preceding and current row)) 
        WHEN DATE_DIFF(CURRENT_DATE(), date,  DAY) < 11
        THEN EXP(AVG(LOG(1+percent)) OVER(PARTITION BY geo_type, region, transportation_type ORDER BY date DESC
          rows between 2 preceding and current row)) 
        WHEN DATE_DIFF(CURRENT_DATE(), date,  DAY) < 18
        THEN EXP(AVG(LOG(1+percent)) OVER(PARTITION BY geo_type, region, transportation_type ORDER BY date DESC
          rows between 3 preceding and current row)) 
        WHEN DATE_DIFF(CURRENT_DATE(), date,  DAY) < 25
        THEN EXP(AVG(LOG(1+percent)) OVER(PARTITION BY geo_type, region, transportation_type ORDER BY date DESC
          rows between 4 preceding and current row)) 
        WHEN DATE_DIFF(CURRENT_DATE(), date,  DAY) < 32
        THEN EXP(AVG(LOG(1+percent)) OVER(PARTITION BY geo_type, region, transportation_type ORDER BY date DESC
          rows between 5 preceding and current row))       
        ELSE EXP(AVG(LOG(1+percent)) OVER(PARTITION BY geo_type, region, transportation_type ORDER BY date DESC
          rows between 6 preceding and current row)) 
      END avg7day  
    , EXP(AVG(LOG(1+percent)) OVER(PARTITION BY geo_type, region, transportation_type ORDER BY date DESC
        rows between 6 preceding and current row)) strict_avg7day
    , geo_type||transportation_type||region series_id
  FROM data
), lat_lons AS  (
  SELECT * EXCEPT(latlon), latlon || ROW_NUMBER() OVER(PARTITION BY latlon ORDER BY region) latlon, SUBSTR(geohash, 0, 2) gh2
  FROM (
    SELECT *, ROUND(ST_Y(centroid),7)||','||ROUND(ST_X(centroid),7) latlon, ST_GEOHASH(centroid) geohash
    FROM (
      SELECT geoid region, ST_CENTROID(geom) centroid, country, geo_type carto_geotype, region carto_region
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

