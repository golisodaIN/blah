CREATE OR REPLACE TABLE `wikidata.subclasses_20190822`
AS

SELECT a.*, b.en_label subclass_of_label, 1 level
FROM (
  SELECT a.*, b.en_label, c.numeric_id subclass_of_numeric_id, FORMAT('Q%i', c.numeric_id) subclass_of_id
  FROM (
    SELECT FORMAT('Q%i', b.numeric_id) id, ANY_VALUE(b.numeric_id) numeric_id, COUNT(DISTINCT id) c
    FROM `fh-bigquery.wikidata.wikidata_latest_20190822` a, UNNEST(subclass_of)b
    GROUP BY 1 
  ) a
  JOIN `fh-bigquery.wikidata.wikidata_latest_20190822` b
  USING(numeric_id)
  , UNNEST(subclass_of) c
) a
LEFT JOIN `fh-bigquery.wikidata.wikidata_latest_20190822` b
ON subclass_of_numeric_id = b.numeric_id
ORDER BY c DESC
;

LOOP
  BEGIN
    DECLARE row_count INT64;
    DECLARE row_diff INT64;
    SET row_count = (SELECT COUNT(*) FROM `wikidata.subclasses_20190822`) 
    ;


    INSERT INTO `wikidata.subclasses_20190822`

    SELECT a.id, a.numeric_id, a.c, a.en_label, b.subclass_of_numeric_id, b.subclass_of_id, b.subclass_of_label, MIN(b.level+1) level
    FROM `wikidata.subclasses_20190822` a
    JOIN `wikidata.subclasses_20190822` b
    ON a.subclass_of_id = b.id
    WHERE CONCAT(a.id,b.subclass_of_id) NOT IN (SELECT CONCAT(id,subclass_of_id) FROM `wikidata.subclasses_20190822`)
    GROUP BY 1,2,3,4,5,6,7
    ;

    SET row_diff = (SELECT COUNT(*) FROM `wikidata.subclasses_20190822`) - row_count;
    IF row_diff = 0 THEN
        LEAVE;
    END IF;
  END;
END LOOP;
