DECLARE steps INT64 DEFAULT 1;
DECLARE moon_var ARRAY<STRUCT<id INT64, pos ARRAY<INT64>, vel ARRAY<INT64>>>;

CREATE TEMP FUNCTION velocity_change(x ANY TYPE, y ANY TYPE, v ANY TYPE) AS (
  CASE 
   WHEN x=y THEN 0
   ELSE IF (y>x, 1, -1)
  END 
);
CREATE TEMP FUNCTION new_velocity(x ANY TYPE, y ANY TYPE, v ANY TYPE) AS ((
 SELECT ARRAY_AGG(STRUCT(posx AS pos, velocity_change(posx, posy, vel) AS velocity) ORDER BY i) 
  FROM UNNEST(x) posx WITH OFFSET i
  JOIN UNNEST(y) posy WITH OFFSET j
  JOIN UNNEST(v) vel WITH OFFSET k
  ON i=j AND j=k
));
CREATE TEMP FUNCTION move_moons(moons ANY TYPE) AS ((
  SELECT ARRAY_AGG(a) FROM (
    SELECT AS STRUCT id, ARRAY_AGG(pos ORDER BY i) pos, ARRAY_AGG(vel ORDER BY i) vel
    FROM (
      SELECT a.id, i, ANY_VALUE(old_vel)+SUM(velocity) vel, ANY_VALUE(pos) + (ANY_VALUE(old_vel)+SUM(velocity)) pos
      FROM (
        SELECT a, b, new_velocity(a.pos, b.pos, a.vel) AS new_velocity
        FROM UNNEST(moons) a, UNNEST(moons) b
      ), UNNEST(new_velocity) WITH OFFSET i, UNNEST(a.vel) old_vel WITH OFFSET j
      WHERE i=j
      GROUP BY a.id, i
    )
    GROUP BY id
) a));

SET moon_var = (
  WITH input AS (SELECT 
"""<x=-4, y=-14, z=8>
<x=1, y=-8, z=10>
<x=-15, y=2, z=1>
<x=-17, y=-17, z=16>"""
  )
  , moons AS (
    SELECT id, (SELECT ARRAY_AGG(CAST(x AS INT64)) FROM UNNEST(pos) x) pos, [0,0,0] vel
    FROM (
      SELECT id, REGEXP_EXTRACT_ALL(x,'=([-0-9]*)') pos
      FROM UNNEST(SPLIT((SELECT * FROM input), '\n')) x WITH OFFSET id
    )
  )

    SELECT move_moons(ARRAY_AGG(moons)) x
    FROM moons
);

LOOP 
  SET steps = steps+1;
  SET moon_var = (move_moons(moon_var));
  IF steps=1000 THEN LEAVE; END IF;
END LOOP;

CREATE TABLE `temp.step_1000`
AS (SELECT moon_var)
;
SELECT SUM((SELECT SUM(ABS(p)) FROM UNNEST(pos) p) * (SELECT SUM(ABS(v)) FROM UNNEST(vel) v))
FROM UNNEST(moon_var)
