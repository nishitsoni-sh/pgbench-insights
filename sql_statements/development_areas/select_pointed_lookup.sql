WITH version_window AS (
    SELECT 
        MIN(lower(sys_period)) AS lower_time, 
        MAX(lower(sys_period)) AS upper_time 
    FROM 
        development_areas_versions
)
SELECT *
FROM 
    development_areas_versions dav
WHERE 
    sys_period @> (
        SELECT 
            lower_time + ((upper_time - lower_time) / 2) 
        FROM 
            version_window
    ) AND uuid = (
    SELECT uuid 
    FROM public.development_areas
    TABLESAMPLE SYSTEM (1)
    LIMIT 1
);
