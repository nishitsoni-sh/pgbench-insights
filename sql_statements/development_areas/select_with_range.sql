WITH version_window AS (
    SELECT 
        MIN(lower(sys_period)) AS lower_time, 
        MAX(lower(sys_period)) AS upper_time 
    FROM 
        development_areas_versions
    WHERE uuid = '123e4567-e89b-12d3-a456-426614174000'  -- Replace with your UUID
)
SELECT *
FROM 
    development_areas_versions dav
WHERE 
    uuid  = (SELECT uuid 
    FROM public.development_areas
    TABLESAMPLE SYSTEM (1)
    LIMIT 1)
    AND sys_period && tstzrange(
        (SELECT lower_time FROM version_window) , 
        (SELECT upper_time FROM version_window) 
    );
