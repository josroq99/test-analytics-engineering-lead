-- Test para verificar que todos los grupos de edad esperados están presentes
-- Debe tener al menos un registro en cada grupo de edad

WITH age_distribution AS (
    SELECT 
        age_group,
        COUNT(*) as count
    FROM {{ ref('int_customer_profiles') }}
    GROUP BY age_group
),

expected_age_groups AS (
    SELECT 'young' as expected_group
    UNION ALL SELECT 'adult'
    UNION ALL SELECT 'middle_age'
    UNION ALL SELECT 'senior'
),

validation AS (
    SELECT 
        e.expected_group,
        COALESCE(a.count, 0) as actual_count,
        CASE 
            WHEN a.count > 0 THEN TRUE
            ELSE FALSE
        END as is_present
    FROM expected_age_groups e
    LEFT JOIN age_distribution a ON e.expected_group = a.age_group
)

SELECT 
    expected_group,
    actual_count,
    is_present
FROM validation 
WHERE NOT is_present
