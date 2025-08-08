WITH source AS (
    SELECT * FROM {{ source('raw', 'bank_marketing') }}
),

cleaned AS (
    SELECT
        -- Identificadores únicos
        ROW_NUMBER() OVER (ORDER BY age, job, marital, education) as contact_id,
        
        -- Datos del cliente
        CAST(age AS INT64) as age,
        LOWER(TRIM(job)) as job,
        LOWER(TRIM(marital)) as marital_status,
        LOWER(TRIM(education)) as education_level,
        `default` as has_default_credit,
        CAST(balance AS FLOAT64) as balance_euros,
        housing as has_housing_loan,
        loan as has_personal_loan,
        
        -- Datos del contacto
        LOWER(TRIM(contact)) as contact_type,
        CAST(day AS INT64) as contact_day,
        LOWER(TRIM(month)) as contact_month,
        CAST(duration AS INT64) as contact_duration_seconds,
        
        -- Datos de la campaña
        CAST(campaign AS INT64) as campaign_contacts,
        CAST(pdays AS INT64) as days_since_last_contact,
        CAST(previous AS INT64) as previous_campaign_contacts,
        LOWER(TRIM(poutcome)) as previous_campaign_outcome,
        
        -- Variable objetivo
        y as subscribed_deposit,
        
        -- Metadatos
        CURRENT_TIMESTAMP() as _loaded_at,
        'stg_bank_marketing' as _source_model
        
    FROM source
    WHERE age IS NOT NULL  -- Filtrar registros con edad nula
),

final AS (
    SELECT
        *,
        -- Crear categorías de edad
        CASE 
            WHEN age < 25 THEN 'young'
            WHEN age BETWEEN 25 AND 45 THEN 'adult'
            WHEN age BETWEEN 46 AND 65 THEN 'middle_age'
            ELSE 'senior'
        END as age_group,
        
        -- Crear categorías de balance
        CASE 
            WHEN balance_euros < 0 THEN 'negative'
            WHEN balance_euros = 0 THEN 'zero'
            WHEN balance_euros BETWEEN 1 AND 1000 THEN 'low'
            WHEN balance_euros BETWEEN 1001 AND 5000 THEN 'medium'
            ELSE 'high'
        END as balance_category,
        
        -- Crear indicador de éxito de campaña anterior
        CASE 
            WHEN previous_campaign_outcome = 'success' THEN TRUE
            ELSE FALSE
        END as had_successful_previous_campaign
        
    FROM cleaned
)

SELECT * FROM final