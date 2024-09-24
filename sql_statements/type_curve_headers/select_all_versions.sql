SELECT *
FROM type_curve_headers_versions tchv
WHERE uuid = (
    SELECT uuid 
    FROM public.type_curve_headers tch
    TABLESAMPLE SYSTEM (1)
    LIMIT 1
);
