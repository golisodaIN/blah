SELECT * 
FROM (
  SELECT CAST(FORMAT('%i%i%i%i%i%i',n0, n1, n2, n3, n4, n5) AS INT64) number
  FROM (
    SELECT n0, n1, n2, n3, n4, n5
    FROM UNNEST(GENERATE_ARRAY(1, 5)) n0
    , UNNEST(GENERATE_ARRAY(1, 9)) n1
    , UNNEST(GENERATE_ARRAY(1, 9)) n2
    , UNNEST(GENERATE_ARRAY(1, 9)) n3
    , UNNEST(GENERATE_ARRAY(1, 9)) n4
    , UNNEST(GENERATE_ARRAY(1, 9)) n5
    WHERE n1>=n0
    AND n2>=n1
    AND n3>=n2
    AND n4>=n3
    AND n5>=n4
    AND (
    (n1=n0 AND n1!=n2)
    OR (n2=n1 AND n1!=n0 AND n2!=n3)
    OR (n3=n2 AND n2!=n1 AND n3!=n4)
    OR (n4=n3 AND n3!=n2 AND n4!=n5)
    OR (n5=n4 AND n4!=n3)
    )
  )
)
WHERE number BETWEEN 109165 AND 576723
