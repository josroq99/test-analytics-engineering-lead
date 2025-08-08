-- Macro para monitoreo de calidad de datos
-- Uso: {{ quality_monitoring() }}

{% macro quality_monitoring() %}
    -- Monitoreo de calidad de datos
    WITH quality_metrics AS (
        -- Verificar completitud de datos
        SELECT 
            'completeness' as metric_type,
            COUNT(*) as total_records,
            COUNT(CASE WHEN contact_id IS NOT NULL THEN 1 END) as non_null_contact_id,
            COUNT(CASE WHEN age IS NOT NULL THEN 1 END) as non_null_age,
            COUNT(CASE WHEN subscribed_deposit IS NOT NULL THEN 1 END) as non_null_conversion
        FROM {{ ref('fct_marketing_conversions') }}
    ),
    
    conversion_metrics AS (
        -- Métricas de conversión
        SELECT 
            'conversion' as metric_type,
            COUNT(*) as total_contacts,
            COUNT(CASE WHEN conversion_flag = 1 THEN 1 END) as successful_conversions,
            AVG(conversion_rate) as avg_conversion_rate
        FROM {{ ref('fct_marketing_conversions') }}
    ),
    
    segment_distribution AS (
        -- Distribución de segmentos
        SELECT 
            'segments' as metric_type,
            COUNT(DISTINCT customer_segment) as unique_segments,
            COUNT(*) as total_customers
        FROM {{ ref('int_customer_profiles') }}
    )
    
    SELECT * FROM quality_metrics
    UNION ALL
    SELECT * FROM conversion_metrics
    UNION ALL
    SELECT * FROM segment_distribution
{% endmacro %}

-- Macro para alertas de calidad
-- Uso: {{ quality_alerts() }}

{% macro quality_alerts() %}
    -- Alertas de calidad de datos
    WITH alerts AS (
        -- Alerta por baja tasa de conversión
        SELECT 
            'low_conversion_rate' as alert_type,
            'Tasa de conversión por debajo del 10%' as alert_message,
            CASE 
                WHEN AVG(conversion_rate) < 0.1 THEN TRUE 
                ELSE FALSE 
            END as is_alert
        FROM {{ ref('fct_marketing_conversions') }}
        
        UNION ALL
        
        -- Alerta por datos incompletos
        SELECT 
            'incomplete_data' as alert_type,
            'Más del 5% de contact_id son nulos' as alert_message,
            CASE 
                WHEN COUNT(CASE WHEN contact_id IS NULL THEN 1 END) * 100.0 / COUNT(*) > 5 THEN TRUE 
                ELSE FALSE 
            END as is_alert
        FROM {{ ref('fct_marketing_conversions') }}
        
        UNION ALL
        
        -- Alerta por segmentos desbalanceados
        SELECT 
            'unbalanced_segments' as alert_type,
            'Algún segmento representa más del 50% de los clientes' as alert_message,
            CASE 
                WHEN MAX(segment_count) * 100.0 / SUM(segment_count) > 50 THEN TRUE 
                ELSE FALSE 
            END as is_alert
        FROM (
            SELECT 
                customer_segment,
                COUNT(*) as segment_count
            FROM {{ ref('int_customer_profiles') }}
            GROUP BY customer_segment
        )
    )
    
    SELECT 
        alert_type,
        alert_message
    FROM alerts
    WHERE is_alert = TRUE
{% endmacro %}

-- Macro para métricas de rendimiento
-- Uso: {{ performance_metrics() }}

{% macro performance_metrics() %}
    -- Métricas de rendimiento de campañas
    WITH campaign_performance AS (
        SELECT 
            call_duration_category,
            contact_frequency,
            COUNT(*) as total_contacts,
            AVG(conversion_rate) as avg_conversion_rate,
            SUM(CASE WHEN conversion_flag = 1 THEN 1 ELSE 0 END) as successful_conversions
        FROM {{ ref('int_campaign_performance') }} icp
        JOIN {{ ref('fct_marketing_conversions') }} fmc 
            ON icp.contact_id = fmc.contact_id
        GROUP BY call_duration_category, contact_frequency
    ),
    
    age_group_performance AS (
        SELECT 
            age_group,
            risk_profile,
            COUNT(*) as total_customers,
            AVG(conversion_rate) as avg_conversion_rate
        FROM {{ ref('int_customer_profiles') }} icp
        JOIN {{ ref('fct_marketing_conversions') }} fmc 
            ON icp.contact_id = fmc.contact_id
        GROUP BY age_group, risk_profile
    )
    
    SELECT 
        'campaign_performance' as metric_category,
        call_duration_category,
        contact_frequency,
        total_contacts,
        avg_conversion_rate,
        successful_conversions
    FROM campaign_performance
    
    UNION ALL
    
    SELECT 
        'age_group_performance' as metric_category,
        age_group as call_duration_category,
        risk_profile as contact_frequency,
        total_customers as total_contacts,
        avg_conversion_rate,
        NULL as successful_conversions
    FROM age_group_performance
{% endmacro %}
