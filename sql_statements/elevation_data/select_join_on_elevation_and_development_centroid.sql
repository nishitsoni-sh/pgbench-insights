-- This query needs enhancement to randomise the id for development_areas,
-- hardcoded it to 37614 for a quick test
SELECT
    d.id AS development_id,
    e.elevation,
    e.geom AS elevation_point,
    ST_Distance(ST_Centroid(d.geometry), e.geom) AS distance
FROM
    development_areas d,
    (SELECT
         elevation,
         geom
     FROM
         xyz_elevation_data_large_mv
     ORDER BY
         ST_Centroid((SELECT geometry FROM development_areas WHERE id = 37614)) <-> geom
         LIMIT 1
    ) AS e
WHERE
    d.id = 37614;