-- The function measure_elevation_data_join_performance runs a query multiple times
-- (as defined by loop_iterations), capturing each execution time in milliseconds.
-- It then calculates performance metrics: average, maximum, minimum,
-- standard deviation, and percentiles (P90 and P95).

CREATE OR REPLACE FUNCTION measure_elevation_data_join_performance(loop_iterations INT)
RETURNS void AS
$$
DECLARE
start_time TIMESTAMP;
    end_time TIMESTAMP;
    execution_time INT;
    total_time INT := 0;
    max_time INT := 0;
    min_time INT := 99999999;
    p90_time INT;
    p95_time INT;
    mean_time INT;
    stddev_time FLOAT;
    total_count INT := loop_iterations;
    execution_times INT[];
    idx INT := 1;
    random_id INT;
BEGIN
    -- Run the query 'loop_iterations' times and store execution times in an array
FOR i IN 1..total_count LOOP
        -- Select a random id from the development_areas table
SELECT id INTO random_id FROM development_areas ORDER BY random() LIMIT 1;

-- Capture the start time
start_time := clock_timestamp();

        -- Execute the query (but don't select any columns)
        PERFORM
(SELECT 1
 FROM
     development_areas d,
     (SELECT
          elevation,
          geom
      FROM
          xyz_elevation_data_large_mv
      ORDER BY
          ST_Centroid((SELECT geometry FROM development_areas WHERE id = random_id)) <-> geom
          LIMIT 1
     ) AS e
 WHERE
     d.id = random_id
     );

-- Capture the end time
end_time := clock_timestamp();

        -- Calculate the execution time in milliseconds
        execution_time := EXTRACT(MILLISECOND FROM end_time - start_time);

        -- Store execution time in the array
        execution_times[idx] := execution_time;
        idx := idx + 1;

        -- Update the total, max, min values
        total_time := total_time + execution_time;
        IF execution_time > max_time THEN
            max_time := execution_time;
END IF;
        IF execution_time < min_time THEN
            min_time := execution_time;
END IF;
END LOOP;

    -- Calculate average execution time
    mean_time := total_time / total_count;

    -- Calculate standard deviation
SELECT sqrt(sum((exec_time - mean_time) * (exec_time - mean_time)) / total_count)
INTO stddev_time
FROM unnest(execution_times) AS exec_time;

-- Sort the times and calculate p90 and p95 percentiles
WITH sorted_times AS (
    SELECT unnest(execution_times) AS exec_time ORDER BY exec_time
)
SELECT
    (SELECT exec_time FROM sorted_times LIMIT 1 OFFSET (total_count * 90 / 100)) AS p90,
        (SELECT exec_time FROM sorted_times LIMIT 1 OFFSET (total_count * 95 / 100)) AS p95
INTO p90_time, p95_time;

-- Output the results
RAISE NOTICE 'Max: % ms', max_time;
    RAISE NOTICE 'Min: % ms', min_time;
    RAISE NOTICE 'P90: % ms', p90_time;
    RAISE NOTICE 'P95: % ms', p95_time;
    RAISE NOTICE 'StdDev: % ms', stddev_time;
    RAISE NOTICE 'Avg: % ms', mean_time;
    RAISE NOTICE 'Total Time: % ms', total_time;
END;
$$ LANGUAGE plpgsql;

SELECT measure_elevation_data_join_performance(100);  -- Run the query 100 times