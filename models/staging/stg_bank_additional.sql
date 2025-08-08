WITH source AS (
    SELECT * FROM {{ source('raw', 'bank_additional') }}
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
        cast(CASE 
            WHEN LOWER(TRIM(`default`)) = 'yes' THEN TRUE
            ELSE FALSE
        END as BOOLEAN) as has_default_credit,
        cast(CASE 
            WHEN LOWER(TRIM(housing)) = 'yes' THEN TRUE
            ELSE FALSE
        END as BOOLEAN) as has_housing_loan,
        cast(CASE 
            WHEN LOWER(TRIM(loan)) = 'yes' THEN TRUE
            ELSE FALSE
        END as BOOLEAN) as has_personal_loan,
        
        -- Datos del contacto
        LOWER(TRIM(contact)) as contact_type,
        LOWER(TRIM(month)) as contact_month,
        LOWER(TRIM(day_of_week)) as contact_day_of_week,
        CAST(duration AS INT64) as contact_duration_seconds,
        
        -- Datos de la campaña
        CAST(campaign AS INT64) as campaign_contacts,
        CAST(pdays AS INT64) as days_since_last_contact,
        CAST(previous AS INT64) as previous_campaign_contacts,
        LOWER(TRIM(poutcome)) as previous_campaign_outcome,
        
        -- Contexto socioeconómico
        CAST(emp_var_rate AS FLOAT64) as employment_variation_rate,
        CAST(cons_price_idx AS FLOAT64) as consumer_price_index,
        CAST(cons_conf_idx AS FLOAT64) as consumer_confidence_index,
        CAST(euribor3m AS FLOAT64) as euribor_3m_rate,
        CAST(nr_employed AS FLOAT64) as number_employed,
        
        -- Variable objetivo
        y as subscribed_deposit,
        
        -- Metadatos
        CURRENT_TIMESTAMP() as _loaded_at,
        'stg_bank_additional' as _source_model
        
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
        
        -- Crear indicador de éxito de campaña anterior
        CASE 
            WHEN previous_campaign_outcome = 'success' THEN TRUE
            ELSE FALSE
        END as had_successful_previous_campaign,
        
        -- Crear categorías de contexto económico
        CASE 
            WHEN employment_variation_rate < -2 THEN 'declining'
            WHEN employment_variation_rate BETWEEN -2 AND 2 THEN 'stable'
            ELSE 'growing'
        END as employment_trend,
        
        CASE 
            WHEN consumer_confidence_index < -40 THEN 'low_confidence'
            WHEN consumer_confidence_index BETWEEN -40 AND -20 THEN 'moderate_confidence'
            ELSE 'high_confidence'
        END as consumer_confidence_level
        
    FROM cleaned
)

SELECT * FROM final

