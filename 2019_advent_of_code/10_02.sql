CREATE TEMP FUNCTION distance(x ANY TYPE, y ANY TYPE, x2 ANY TYPE, y2 ANY TYPE) AS (
 (x-x2) * (x-x2) + (y-y2)*(y-y2)
);
CREATE TEMP FUNCTION angle(x ANY TYPE, y ANY TYPE, x2 ANY TYPE, y2 ANY TYPE) AS (
 ACOS(-1) + ATAN2((x-x2),(y-y2))
);
CREATE TEMP FUNCTION rotated(x ANY TYPE) AS ( 
  IF(x<=ACOS(-1), ACOS(-1)-x, 4*ACOS(-1)- x)
);

WITH data AS (SELECT 
-- """.#..##.###...#######
-- ##.############..##.
-- .#.######.########.#
-- .###.#######.####.#.
-- #####.##.#.##.###.##
-- ..#####..#.#########
-- ####################
-- #.####....###.#.#.##
-- ##.#################
-- #####.##.###..####..
-- ..######..##.#######
-- ####.##.####...##..#
-- .#####..#.######.###
-- ##...#.##########...
-- #.##########.#######
-- .####.#.###.###.#.##
-- ....##.##.###..#####
-- .#.#.###########.###
-- #.#.#.#####.####.###
-- ###.##.####.##.#..##"""
"""#.#.###.#.#....#..##.#....
.....#..#..#..#.#..#.....#
.##.##.##.##.##..#...#...#
#.#...#.#####...###.#.#.#.
.#####.###.#.#.####.#####.
#.#.#.##.#.##...####.#.##.
##....###..#.#..#..#..###.
..##....#.#...##.#.#...###
#.....#.#######..##.##.#..
#.###.#..###.#.#..##.....#
##.#.#.##.#......#####..##
#..##.#.##..###.##.###..##
#..#.###...#.#...#..#.##.#
.#..#.#....###.#.#..##.#.#
#.##.#####..###...#.###.##
#...##..#..##.##.#.##..###
#.#.###.###.....####.##..#
######....#.##....###.#..#
..##.#.####.....###..##.#.
#..#..#...#.####..######..
#####.##...#.#....#....#.#
.#####.##.#.#####..##.#...
#..##..##.#.##.##.####..##
.##..####..#..####.#######
#.#..#.##.#.######....##..
.#.##.##.####......#.##.##""" 
input
), parsed AS (
  SELECT x,y, element
  FROM UNNEST(SPLIT((SELECT * FROM data), '\n')) line WITH offset y, UNNEST(SPLIT(line, '')) element WITH offset x
), asteroids AS (
  SELECT x,y
  FROM parsed
  WHERE element='#'
), calculations AS (
    SELECT spaces, asteroids
      , distance(spaces.x, spaces.y, asteroids.x, asteroids.y) distance
      , angle(spaces.x, spaces.y, asteroids.x, asteroids.y) angle
    FROM asteroids AS spaces, asteroids
    WHERE (spaces.x!=asteroids.x OR spaces.y!=asteroids.y)
), bestxy AS (
  SELECT x, y, COUNT(*) c
  FROM (
    SELECT spaces.x, spaces.y, angle, ARRAY_AGG(STRUCT(distance,angle, asteroids.x, asteroids.y, spaces.x!=asteroids.x AND spaces.y!=asteroids.y))
    FROM calculations
    GROUP BY 1,2,3  
  )
  GROUP BY x,y
  ORDER BY c DESC
  LIMIT 1
)


SELECT x*100 + y xy, rotated, layer, ROW_NUMBER() OVER(ORDER BY layer, rotated) rn
FROM (
  SELECT rotated(angle) rotated, ARRAY_AGG(STRUCT(asteroids.x, asteroids.y, distance) ORDER BY distance) layers
  FROM calculations
  JOIN bestxy
  ON calculations.spaces.x = bestxy.x
  AND calculations.spaces.y = bestxy.y
  GROUP BY 1
), UNNEST(layers) WITH OFFSET layer
