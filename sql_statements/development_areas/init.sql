CREATE TABLE IF NOT EXISTS development_areas_load_test_uuids (uuid UUID PRIMARY KEY);
TRUNCATE TABLE public.development_areas_load_test_uuids;
DELETE FROM development_areas WHERE name LIKE '%Load%';