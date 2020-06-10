{{ config(materialized='incremental', partition_by={'field':'test_date'}, cluster_by='ip' ) }}

SELECT client.IP ip, a.*, * EXCEPT(a)
FROM `measurement-lab.ndt.unified_downloads` 
WHERE test_date >= '2019-11-17'
