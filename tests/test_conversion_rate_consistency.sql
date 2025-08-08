-- Test para verificar que la tasa de conversión es consistente
-- La suma de conversion_flag debe ser igual a la suma de conversiones exitosas

WITH conversion_summary AS (
    SELECT 
        COUNT(*) as total_contacts,
        SUM(conversion_flag) as successful_conversions,
        AVG(conversion_rate) as avg_conversion_rate
    FROM {{ ref('fct_marketing_conversions') }}
),

validation AS (
    SELECT 
        *,
        CASE 
            WHEN successful_conversions = 0 AND avg_conversion_rate = 0 THEN TRUE
            WHEN successful_conversions > 0 AND avg_conversion_rate > 0 THEN TRUE
            ELSE FALSE
        END as is_consistent
    FROM conversion_summary
)

SELECT * FROM validation WHERE NOT is_consistent
