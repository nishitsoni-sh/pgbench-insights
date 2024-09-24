INSERT INTO public.type_curve_headers (
    type_curve_id, uuid, unique_tc_id, status, basin, formation, 
    lateral_length_ft, horizontal_well_spacing_ft, oil_eur_mbbl_30yr, 
    oil_eur_mbbl_50yr, gas_eur_mmcf_30yr, gas_eur_mmcf_50yr, wtr_eur_mbbl_30yr, 
    wtr_eur_mbbl_50yr, approved_on, liquid_volumes, gas_volumes, water_volumes, 
    deleted_at, created_at, updated_at
) VALUES (
    2, 
    gen_random_uuid(), 
    concat('LoadTest_', gen_random_uuid()), 
    'Active_Eval', 
    'Delaware', 
    'BoneSpring 3rd Sand', 
    10000, 
    1320, 
    1031, 
    NULL, 
    1645, 
    NULL, 
    2275, 
    NULL, 
    '2021-05-21', 
    '{"25262.0", "40311.8", "34364.6", "29971.5", "26590.8"}'::float8[], 
    '{"24883.0", "45373.2", "40780.7"}'::float8[], 
    '{"58540.0", "68412.0", "61909.9"}'::float8[], 
    NULL, 
    '2023-04-06 22:52:56.675', 
    '2023-04-06 22:52:56.675'
);
