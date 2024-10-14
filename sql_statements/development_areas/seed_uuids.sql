INSERT INTO public.development_areas_load_test_uuids (uuid)
SELECT uuid
FROM public.development_areas
WHERE name LIKE '%LoadTest%'
    LIMIT 100;
