SELECT
  a.county_name,
  _4_10_20 as num_cases, -- Change date as needed
  county_geom AS the_geom
FROM `bigquery-public-data.covid19_usafacts.confirmed_cases` a
JOIN `bigquery-public-data.geo_us_boundaries.counties` b
ON a.county_fips_code = b.state_fips_code || b.county_fips_code
# 12.7 sec elapsed, 182.1 MB processed
# (h/t Amir Hormati)
