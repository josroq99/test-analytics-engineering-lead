WITH base_customers AS (
    SELECT
        contact_id,
        age,
        age_group,
        job,
        marital_status,
        education_level,
        has_default_credit,
        balance_euros,
        balance_category,
        has_housing_loan,
        has_personal_loan,
        subscribed_deposit,
        _loaded_at
    FROM {{ ref('stg_bank_marketing') }}
    
    UNION ALL
    
    SELECT
        contact_id,
        age,
        age_group,
        job,
        marital_status,
        education_level,
        has_default_credit,
        NULL as balance_euros,  -- No disponible en dataset adicional
        NULL as balance_category,
        has_housing_loan,
        has_personal_loan,
        subscribed_deposit,
        _loaded_at
    FROM {{ ref('stg_bank_additional') }}
),

customer_metrics AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY contact_id, _loaded_at) as contact_id,
        age,
        age_group,
        job,
        marital_status,
        education_level,
        has_default_credit,
        balance_euros,
        balance_category,
        has_housing_loan,
        has_personal_loan,
        subscribed_deposit,
        
        -- Métricas de riesgo del cliente
        CASE 
            WHEN has_default_credit = TRUE THEN 'high_risk'
            WHEN has_housing_loan = TRUE AND has_personal_loan = TRUE THEN 'medium_risk'
            WHEN has_housing_loan = TRUE OR has_personal_loan = TRUE THEN 'low_risk'
            ELSE 'no_risk'
        END as risk_profile,
        
        -- Segmentación por edad y educación
        CASE 
            WHEN age_group = 'young' AND education_level IN ('tertiary', 'university.degree') THEN 'young_professional'
            WHEN age_group = 'senior' AND job = 'retired' THEN 'retired'
            WHEN age_group = 'adult' AND job IN ('management', 'admin.') THEN 'white_collar'
            WHEN job IN ('blue-collar', 'services') THEN 'blue_collar'
            ELSE 'other'
        END as customer_segment,
        
        -- Indicador de éxito
        CASE 
            WHEN subscribed_deposit = TRUE THEN TRUE
            ELSE FALSE
        END as is_successful_conversion,
        
        _loaded_at
        
    FROM base_customers
)

SELECT * FROM customer_metrics
