UPDATE public.development_areas
SET length = random() * 10000,  
    width = random() * 10000,
    updated_at = CURRENT_TIMESTAMP
WHERE id = (
    SELECT id 
    FROM public.development_areas
    TABLESAMPLE SYSTEM (1) 
    LIMIT 1
);
