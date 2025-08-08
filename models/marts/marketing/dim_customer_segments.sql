WITH customer_segments AS (
    SELECT DISTINCT
        customer_segment,
        age_group,
        job,
        education_level,
        risk_profile,
        
        -- Descripciones de segmentos
        CASE customer_segment
            WHEN 'young_professional' THEN 'Profesionales jóvenes con educación superior'
            WHEN 'retired' THEN 'Personas jubiladas'
            WHEN 'white_collar' THEN 'Empleados de oficina y gestión'
            WHEN 'blue_collar' THEN 'Trabajadores manuales y servicios'
            ELSE 'Otros segmentos'
        END as segment_description,
        
        -- Prioridad de contacto
        CASE customer_segment
            WHEN 'young_professional' THEN 'high'
            WHEN 'white_collar' THEN 'high'
            WHEN 'retired' THEN 'medium'
            WHEN 'blue_collar' THEN 'medium'
            ELSE 'low'
        END as contact_priority,
        
        -- Producto recomendado
        CASE customer_segment
            WHEN 'young_professional' THEN 'investment_products'
            WHEN 'retired' THEN 'retirement_products'
            WHEN 'white_collar' THEN 'premium_services'
            WHEN 'blue_collar' THEN 'basic_products'
            ELSE 'general_products'
        END as recommended_product,
        
        CURRENT_TIMESTAMP() as created_at
        
    FROM {{ ref('int_customer_profiles') }}
    WHERE customer_segment IS NOT NULL
)

SELECT * FROM customer_segments
