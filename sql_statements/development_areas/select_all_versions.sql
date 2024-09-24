SELECT *
FROM development_areas_versions dav 
WHERE uuid = (
    SELECT uuid 
    FROM public.development_areas
    TABLESAMPLE SYSTEM (1)
    LIMIT 1
);
