-- Test para verificar que la distribución de grupos de edad es razonable
-- No debe haber grupos de edad con menos del 5% de los registros

WITH age_distribution AS (
    SELECT 
        age_group,
        COUNT(*) as count,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () as percentage
    FROM {{ ref('int_customer_profiles') }}
    GROUP BY age_group
),

validation AS (
    SELECT 
        *,
        CASE 
            WHEN percentage >= 5.0 THEN TRUE
            ELSE FALSE
        END as is_acceptable_distribution
    FROM age_distribution
)

SELECT * FROM validation WHERE NOT is_acceptable_distribution
