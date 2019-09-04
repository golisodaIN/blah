CREATE OR REPLACE TABLE `wikidata.subclasses_20190822`
AS

SELECT a.*, b.en_label subclass_of_label, 1 level
FROM (
  SELECT a.numeric_id, en_label, b.numeric_id subclass_of_numeric_id
  FROM `fh-bigquery.wikidata.wikidata_latest_20190822` a, UNNEST(a.subclass_of) b
) a
JOIN `fh-bigquery.wikidata.wikidata_latest_20190822` b
ON a.subclass_of_numeric_id=b.numeric_id
;

LOOP
  BEGIN
    DECLARE row_count INT64;
    DECLARE row_diff INT64;
    SET row_count = (SELECT COUNT(*) FROM `wikidata.subclasses_20190822`) 
    ;


    INSERT INTO `wikidata.subclasses_20190822`

    SELECT a.numeric_id, a.en_label, b.subclass_of_numeric_id, b.subclass_of_label, MIN(b.level+1) level
    FROM `wikidata.subclasses_20190822` a
    JOIN `wikidata.subclasses_20190822` b
    ON a.subclass_of_numeric_id = b.numeric_id
    WHERE STRUCT(a.numeric_id,b.subclass_of_numeric_id) NOT IN (SELECT STRUCT(numeric_id,subclass_of_numeric_id) FROM `wikidata.subclasses_20190822`)
    GROUP BY 1,2,3,4
    ;

    SET row_diff = (SELECT COUNT(*) FROM `wikidata.subclasses_20190822`) - row_count;
    IF row_diff = 0 THEN
        LEAVE;
    END IF;
  END;
END LOOP;
