WITH customer_data AS (
    SELECT * FROM {{ ref('int_customer_profiles') }}
),

campaign_data AS (
    SELECT * FROM {{ ref('int_campaign_performance') }}
),

conversions_fact AS (
    SELECT
        -- Claves primarias
        c.contact_id,
        
        -- Dimensiones del cliente
        c.age,
        c.age_group,
        c.job,
        c.marital_status,
        c.education_level,
        c.risk_profile,
        c.customer_segment,
        
        -- Dimensiones de la campaña
        cp.contact_type,
        cp.contact_month,
        cp.call_duration_category,
        cp.contact_frequency,
        cp.contact_timing,
        
        -- Métricas de conversión
        CASE 
            WHEN c.is_successful_conversion THEN 1
            ELSE 0
        END as conversion_flag,
        
        CASE 
            WHEN c.is_successful_conversion THEN 1.0
            ELSE 0.0
        END as conversion_rate,
        
        -- Métricas de campaña
        cp.campaign_contacts,
        cp.contact_duration_seconds,
        cp.days_since_last_contact,
        cp.previous_campaign_contacts,
        cp.conversion_probability_score,
        
        -- Métricas financieras (solo para dataset principal)
        c.balance_euros,
        c.balance_category,
        
        -- Indicadores de riesgo
        CASE 
            WHEN c.has_default_credit = 'yes' THEN 1
            ELSE 0
        END as has_default_credit_flag,
        
        CASE 
            WHEN c.has_housing_loan = 'yes' THEN 1
            ELSE 0
        END as has_housing_loan_flag,
        
        CASE 
            WHEN c.has_personal_loan = 'yes' THEN 1
            ELSE 0
        END as has_personal_loan_flag,
        
        -- Metadatos
        c._loaded_at as customer_loaded_at,
        cp._loaded_at as campaign_loaded_at,
        CURRENT_TIMESTAMP() as fact_created_at
        
    FROM customer_data c
    INNER JOIN campaign_data cp ON c.contact_id = cp.contact_id
)

SELECT * FROM conversions_fact
