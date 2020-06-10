SELECT client.Geo.country_name country, COUNT(*) c 
FROM {{ref('summary_downloads_weekly')}} 
WHERE client.Geo.country_name>''
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 100
