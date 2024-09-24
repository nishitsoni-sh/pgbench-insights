INSERT INTO public.development_areas (
    name, created_at, updated_at, uuid, bespoke, length, width, geometry 
) VALUES (
    concat('LoadTest1_U-', gen_random_uuid()),
    '2024-09-23 10:38:39.92411+05:30', 
    '2024-09-23 10:38:39.92411+05:30', 
    gen_random_uuid(), 
    true, 10588.0, 5282.0,
    'POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'::geometry
);
