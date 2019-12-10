CREATE TEMP FUNCTION distance(x ANY TYPE, y ANY TYPE, x2 ANY TYPE, y2 ANY TYPE) AS (
 (x-x2) * (x-x2) + (y-y2)*(y-y2)
);
CREATE TEMP FUNCTION angle(x ANY TYPE, y ANY TYPE, x2 ANY TYPE, y2 ANY TYPE) AS (
 ATAN2((y-y2),(x-x2))
);


WITH data AS (SELECT 
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
.#.##.##.####......#.##.##""" input
), parsed AS (
  SELECT x,y, element
  FROM UNNEST(SPLIT((SELECT * FROM data), '\n')) line WITH offset y, UNNEST(SPLIT(line, '')) element WITH offset x
), asteroids AS (
  SELECT x,y
  FROM parsed
  WHERE element='#'
)

SELECT x, y, COUNT(*) c
FROM (
  SELECT spaces.x, spaces.y, angle, ARRAY_AGG(STRUCT(distance,angle, asteroids.x, asteroids.y, spaces.x!=asteroids.x AND spaces.y!=asteroids.y))
  FROM (
    SELECT spaces, asteroids
      , distance(spaces.x, spaces.y, asteroids.x, asteroids.y) distance
      , angle(spaces.x, spaces.y, asteroids.x, asteroids.y) angle
    FROM asteroids AS spaces, asteroids
     WHERE (spaces.x!=asteroids.x OR spaces.y!=asteroids.y)
  )
  GROUP BY 1,2,3  
)
GROUP BY x,y
ORDER BY c DESC
LIMIT 1
