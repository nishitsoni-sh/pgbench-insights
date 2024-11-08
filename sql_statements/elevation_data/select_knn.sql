-- This query finds the nearest point in `public.xyz_elevation_data_large_mv` to a random coordinate within the bounding box covering the entire elevation-data set.
-- 1. A subquery (`random_point`) generates random `x` and `y` coordinates within this bounding box.
-- 2. Using a `LATERAL` join, the main query (`nearest_point`) finds the closest point in the table based on these random coordinates.
-- 3. The final result includes the geometry (`geom`), the distance to the random point (`nearest_point_distance`), and the elevation.

SELECT
    nearest_point.geom AS nearest_point_geom,
    ST_Distance(
            nearest_point.geom,
            ST_SetSRID(ST_MakePoint(random_point.random_x, random_point.random_y), 4326)
    ) AS nearest_point_distance,
    nearest_point.elevation AS nearest_point_elevation
FROM (
         -- Subquery to calculate the random point only once
         SELECT
             (125.00000762939453 + RANDOM() * (-65.0 - 125.00000762939453)) AS random_x,
             (24.0 + RANDOM() * (51.000003814697266 - 24.0)) AS random_y
     ) AS random_point,
     LATERAL (
         -- Main query that references the random point from the subquery
              SELECT
                  geom,
                  elevation
              FROM
                  public.xyz_elevation_data_large_mv
              ORDER BY
                  geom <-> ST_SetSRID(ST_MakePoint(random_point.random_x, random_point.random_y), 4326)
              LIMIT 1
) AS nearest_point;