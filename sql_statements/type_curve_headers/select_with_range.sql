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
    uuid = (
        SELECT uuid
        FROM type_curve_headers
                 TABLESAMPLE SYSTEM (1)
    LIMIT 1
    )
  AND sys_period && tstzrange(
    (SELECT lower_time + (upper_time - lower_time) * random() * 0.5 FROM version_window),
    (SELECT upper_time - (upper_time - lower_time) * random() * 0.5 FROM version_window)
    );
