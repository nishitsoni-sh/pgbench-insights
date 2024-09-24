UPDATE public.type_curve_headers
SET lateral_length_ft = random() * 10000,
    horizontal_well_spacing_ft = random() * 10000,
    updated_at = CURRENT_TIMESTAMP
WHERE id = (
    SELECT id
    FROM public.type_curve_headers
             TABLESAMPLE SYSTEM (1)
    LIMIT 1
    );