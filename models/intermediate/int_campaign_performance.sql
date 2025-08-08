WITH campaign_data AS (
    SELECT
        contact_id,
        contact_type,
        contact_day,
        contact_month,
        contact_duration_seconds,
        campaign_contacts,
        days_since_last_contact,
        previous_campaign_contacts,
        previous_campaign_outcome,
        had_successful_previous_campaign,
        subscribed_deposit,
        _loaded_at
    FROM {{ ref('stg_bank_marketing') }}
    
    UNION ALL
    
    SELECT
        contact_id, 
        contact_type,
        NULL as contact_day,  -- No disponible en dataset adicional
        contact_month,
        contact_duration_seconds,
        campaign_contacts,
        days_since_last_contact,
        previous_campaign_contacts,
        previous_campaign_outcome,
        had_successful_previous_campaign,
        subscribed_deposit,
        _loaded_at
    FROM {{ ref('stg_bank_additional') }}
),

campaign_metrics AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY contact_id, _loaded_at) as contact_id,
        contact_type,
        contact_day,
        contact_month,
        contact_duration_seconds,
        campaign_contacts,
        days_since_last_contact,
        previous_campaign_contacts,
        previous_campaign_outcome,
        had_successful_previous_campaign,
        subscribed_deposit,
        
        -- Métricas de duración
        CASE 
            WHEN contact_duration_seconds < 60 THEN 'short'
            WHEN contact_duration_seconds BETWEEN 60 AND 300 THEN 'medium'
            ELSE 'long'
        END as call_duration_category,
        
        -- Métricas de campaña
        CASE 
            WHEN campaign_contacts = 1 THEN 'first_contact'
            WHEN campaign_contacts BETWEEN 2 AND 3 THEN 'few_contacts'
            ELSE 'many_contacts'
        END as contact_frequency,
        
        -- Métricas de timing
        CASE 
            WHEN days_since_last_contact = -1 OR days_since_last_contact = 999 THEN 'new_customer'
            WHEN days_since_last_contact < 30 THEN 'recent_contact'
            WHEN days_since_last_contact < 90 THEN 'medium_gap'
            ELSE 'long_gap'
        END as contact_timing,
        
        -- Indicador de éxito (subscribed_deposit ya es BOOLEAN)
        subscribed_deposit as is_successful_conversion,
        
        -- Score de probabilidad (simulado)
        CASE 
            WHEN had_successful_previous_campaign THEN 0.8
            WHEN previous_campaign_contacts > 0 THEN 0.6
            WHEN contact_duration_seconds > 300 THEN 0.7
            ELSE 0.3
        END as conversion_probability_score,
        
        _loaded_at
        
    FROM campaign_data
)

SELECT * FROM campaign_metrics