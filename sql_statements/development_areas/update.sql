UPDATE public.development_areas
SET length = random() * 10000,
    width = random() * 10000,
    updated_at = CURRENT_TIMESTAMP
WHERE uuid = (
    SELECT uuid
    FROM development_areas_load_test_uuids
    ORDER BY RANDOM()
    LIMIT 1
);
