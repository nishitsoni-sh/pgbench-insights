WITH version_window AS (
    SELECT
        MIN(lower(sys_period)) AS lower_time,
        MAX(lower(sys_period)) AS upper_time
    FROM
        type_curve_headers_versions
)
SELECT *
FROM
    type_curve_headers_versions tcv
WHERE
    sys_period @> (
        SELECT
            lower_time + ((upper_time - lower_time) / 2)
        FROM
            version_window
    ) AND uuid = (
    SELECT uuid
    FROM type_curve_headers
             TABLESAMPLE SYSTEM (1)
    LIMIT 1
    );
