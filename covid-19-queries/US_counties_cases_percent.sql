SELECT
  covid19.state,
  covid19.county_name,
  ROUND(confirmed/total_pop *100000,2) AS confirmed_cases_per_100000,
  ROUND(deaths/total_pop *100000,2) AS deaths_per_100000,
  confirmed AS confirmed_cases,
  deaths, 
  total_pop AS county_population, # why is this a float?
FROM `bigquery-public-data.covid19_usafacts.summary` covid19
JOIN `bigquery-public-data.census_bureau_acs.county_2017_5yr` acs 
ON covid19.county_fips_code = acs.geo_id
WHERE date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 day) # yesterday
AND county_fips_code != "00000"
AND confirmed + deaths > 0
ORDER BY confirmed_cases_per_100000 DESC, deaths_per_100000 DESC

# h/t https://twitter.com/shanecglass
