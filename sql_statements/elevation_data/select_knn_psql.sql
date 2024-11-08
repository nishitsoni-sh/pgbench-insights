DO $$
DECLARE
start_time TIMESTAMP;
    end_time TIMESTAMP;
    duration NUMERIC;
    latencies NUMERIC[] := ARRAY[]::NUMERIC[]; -- Array to store latencies
    iterations INT := 100000;  -- Number of iterations, can be adjusted
    avg_duration NUMERIC;
    max_duration NUMERIC;
    min_duration NUMERIC;
    stddev_duration NUMERIC;
    p99_duration NUMERIC;
    p90_duration NUMERIC;
BEGIN
FOR i IN 1..iterations LOOP
        -- Record start time
        start_time := clock_timestamp();

        -- Execute the nearest neighbor query without storing the result
        PERFORM
(SELECT 1 FROM (
                   SELECT
                       nearest_point.geom AS nearest_point_geom,
                       ST_Distance(
                               nearest_point.geom,
                               ST_SetSRID(ST_MakePoint(random_point.random_x, random_point.random_y), 4326)
                       ) AS nearest_point_distance,
                       nearest_point.elevation AS nearest_point_elevation
                   FROM (
                            SELECT
                                (125.00000762939453 + RANDOM() * (-65.0 - 125.00000762939453)) AS random_x,
                                (24.0 + RANDOM() * (51.000003814697266 - 24.0)) AS random_y
                        ) AS random_point,
                        LATERAL (
                                 SELECT
                                     geom,
                                     elevation
                                 FROM
                                     public.xyz_elevation_data_large_mv
                                 ORDER BY
                                     geom <-> ST_SetSRID(ST_MakePoint(random_point.random_x, random_point.random_y), 4326)
                                 LIMIT 1
               ) AS nearest_point
    ) AS query_result);

-- Record end time
end_time := clock_timestamp();

        -- Calculate duration in milliseconds and store it in the array
        duration := EXTRACT(MILLISECOND FROM (end_time - start_time));
        latencies := array_append(latencies, duration);
END LOOP;

    -- Calculate statistics from the latencies array
SELECT
    AVG(val), MAX(val), MIN(val), STDDEV(val),
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY val),
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY val)
INTO avg_duration, max_duration, min_duration, stddev_duration, p99_duration, p90_duration
FROM unnest(latencies) AS val;

-- Output results
RAISE NOTICE 'Average Duration: % ms', avg_duration;
    RAISE NOTICE 'Max Duration: % ms', max_duration;
    RAISE NOTICE 'Min Duration: % ms', min_duration;
    RAISE NOTICE 'Std Dev Duration: % ms', stddev_duration;
    RAISE NOTICE '99th Percentile Duration: % ms', p99_duration;
    RAISE NOTICE '90th Percentile Duration: % ms', p90_duration;
END $$;
