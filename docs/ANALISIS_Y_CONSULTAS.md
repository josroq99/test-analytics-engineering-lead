# Análisis y Consultas del Data Mart de Marketing

## 📊 **Descripción General**

Este documento contiene análisis detallados y consultas de ejemplo para extraer insights valiosos del Data Mart de marketing bancario. Las consultas están optimizadas para BigQuery y utilizan las tablas finales del proyecto.

## 🎯 **Métricas Clave de Negocio**

### 1. **Tasa de Conversión Global**

```sql
-- Tasa de conversión general del proyecto
SELECT 
    COUNT(*) as total_contacts,
    SUM(conversion_flag) as successful_conversions,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent,
    ROUND(SUM(conversion_flag) * 100.0 / COUNT(*), 2) as manual_conversion_rate
FROM `tu-proyecto-id.marts.fct_marketing_conversions`;
```

### 2. **Análisis de Segmentación de Clientes**

```sql
-- Performance por segmento de cliente
SELECT 
    customer_segment,
    COUNT(*) as total_contacts,
    SUM(conversion_flag) as successful_conversions,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent,
    ROUND(AVG(contact_duration_seconds), 2) as avg_call_duration,
    ROUND(AVG(campaign_contacts), 2) as avg_campaign_contacts
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
GROUP BY customer_segment
ORDER BY conversion_rate_percent DESC;
```

### 3. **Análisis por Grupos de Edad**

```sql
-- Performance por grupo de edad
SELECT 
    age_group,
    COUNT(*) as customer_count,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent,
    ROUND(AVG(contact_duration_seconds), 2) as avg_call_duration,
    ROUND(AVG(conversion_probability_score), 3) as avg_probability_score
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
GROUP BY age_group
ORDER BY conversion_rate_percent DESC;
```

## 📈 **Análisis de Campañas**

### 1. **Efectividad por Tipo de Contacto**

```sql
-- Análisis de efectividad por tipo de contacto
SELECT 
    contact_type,
    call_duration_category,
    COUNT(*) as total_calls,
    SUM(conversion_flag) as successful_conversions,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent,
    ROUND(AVG(contact_duration_seconds), 2) as avg_duration
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
WHERE contact_type IS NOT NULL
GROUP BY contact_type, call_duration_category
ORDER BY conversion_rate_percent DESC;
```

### 2. **Análisis de Frecuencia de Contacto**

```sql
-- Impacto de la frecuencia de contacto en conversiones
SELECT 
    contact_frequency,
    COUNT(*) as total_contacts,
    SUM(conversion_flag) as successful_conversions,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent,
    ROUND(AVG(contact_duration_seconds), 2) as avg_call_duration
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
GROUP BY contact_frequency
ORDER BY 
    CASE contact_frequency
        WHEN 'first_contact' THEN 1
        WHEN 'few_contacts' THEN 2
        WHEN 'many_contacts' THEN 3
    END;
```

### 3. **Análisis de Timing de Contacto**

```sql
-- Efectividad según el timing del contacto
SELECT 
    contact_timing,
    COUNT(*) as total_contacts,
    SUM(conversion_flag) as successful_conversions,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent,
    ROUND(AVG(conversion_probability_score), 3) as avg_probability
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
GROUP BY contact_timing
ORDER BY conversion_rate_percent DESC;
```

## 🔍 **Análisis de Riesgo**

### 1. **Performance por Perfil de Riesgo**

```sql
-- Análisis de conversión por perfil de riesgo
SELECT 
    risk_profile,
    COUNT(*) as customer_count,
    SUM(conversion_flag) as successful_conversions,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent,
    ROUND(AVG(conversion_probability_score), 3) as avg_probability_score
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
GROUP BY risk_profile
ORDER BY 
    CASE risk_profile
        WHEN 'no_risk' THEN 1
        WHEN 'low_risk' THEN 2
        WHEN 'medium_risk' THEN 3
        WHEN 'high_risk' THEN 4
    END;
```

### 2. **Análisis de Riesgo por Segmento**

```sql
-- Matriz de riesgo vs segmento
SELECT 
    customer_segment,
    risk_profile,
    COUNT(*) as customer_count,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
GROUP BY customer_segment, risk_profile
ORDER BY customer_segment, 
    CASE risk_profile
        WHEN 'no_risk' THEN 1
        WHEN 'low_risk' THEN 2
        WHEN 'medium_risk' THEN 3
        WHEN 'high_risk' THEN 4
    END;
```

## 📅 **Análisis Temporal**

### 1. **Performance por Mes**

```sql
-- Análisis de conversiones por mes
SELECT 
    contact_month,
    COUNT(*) as total_contacts,
    SUM(conversion_flag) as successful_conversions,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
WHERE contact_month IS NOT NULL
GROUP BY contact_month
ORDER BY 
    CASE contact_month
        WHEN 'jan' THEN 1
        WHEN 'feb' THEN 2
        WHEN 'mar' THEN 3
        WHEN 'apr' THEN 4
        WHEN 'may' THEN 5
        WHEN 'jun' THEN 6
        WHEN 'jul' THEN 7
        WHEN 'aug' THEN 8
        WHEN 'sep' THEN 9
        WHEN 'oct' THEN 10
        WHEN 'nov' THEN 11
        WHEN 'dec' THEN 12
    END;
```

### 2. **Tendencias de Duración de Llamadas**

```sql
-- Análisis de duración de llamadas por mes
SELECT 
    contact_month,
    call_duration_category,
    COUNT(*) as total_calls,
    ROUND(AVG(contact_duration_seconds), 2) as avg_duration,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
WHERE contact_month IS NOT NULL
GROUP BY contact_month, call_duration_category
ORDER BY contact_month, 
    CASE call_duration_category
        WHEN 'short' THEN 1
        WHEN 'medium' THEN 2
        WHEN 'long' THEN 3
    END;
```

## 💰 **Análisis Financiero**

### 1. **Performance por Categoría de Balance**

```sql
-- Análisis de conversión por categoría de balance
SELECT 
    balance_category,
    COUNT(*) as customer_count,
    SUM(conversion_flag) as successful_conversions,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent,
    ROUND(AVG(balance_euros), 2) as avg_balance
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
WHERE balance_category IS NOT NULL
GROUP BY balance_category
ORDER BY 
    CASE balance_category
        WHEN 'negative' THEN 1
        WHEN 'zero' THEN 2
        WHEN 'low' THEN 3
        WHEN 'medium' THEN 4
        WHEN 'high' THEN 5
    END;
```

### 2. **Análisis de Productos por Segmento**

```sql
-- Consulta a la dimensión de segmentos
SELECT 
    cs.customer_segment,
    cs.segment_description,
    cs.contact_priority,
    cs.recommended_product,
    COUNT(fmc.contact_id) as total_contacts,
    SUM(fmc.conversion_flag) as successful_conversions,
    ROUND(AVG(fmc.conversion_rate) * 100, 2) as conversion_rate_percent
FROM `tu-proyecto-id.marts.fct_marketing_conversions` fmc
JOIN `tu-proyecto-id.marts.dim_customer_segments` cs
    ON fmc.customer_segment = cs.customer_segment
GROUP BY 
    cs.customer_segment,
    cs.segment_description,
    cs.contact_priority,
    cs.recommended_product
ORDER BY conversion_rate_percent DESC;
```

## 🎯 **Análisis Predictivo**

### 1. **Distribución de Scores de Probabilidad**

```sql
-- Análisis de distribución de scores de conversión
SELECT 
    CASE 
        WHEN conversion_probability_score < 0.3 THEN 'Low Probability'
        WHEN conversion_probability_score < 0.6 THEN 'Medium Probability'
        ELSE 'High Probability'
    END as probability_category,
    COUNT(*) as total_contacts,
    SUM(conversion_flag) as actual_conversions,
    ROUND(AVG(conversion_rate) * 100, 2) as actual_conversion_rate,
    ROUND(AVG(conversion_probability_score) * 100, 2) as avg_predicted_rate
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
GROUP BY 
    CASE 
        WHEN conversion_probability_score < 0.3 THEN 'Low Probability'
        WHEN conversion_probability_score < 0.6 THEN 'Medium Probability'
        ELSE 'High Probability'
    END
ORDER BY avg_predicted_rate DESC;
```

### 2. **Validación de Predicciones**

```sql
-- Comparación entre predicciones y resultados reales
SELECT 
    ROUND(conversion_probability_score, 1) as predicted_probability,
    COUNT(*) as total_contacts,
    SUM(conversion_flag) as actual_conversions,
    ROUND(AVG(conversion_rate) * 100, 2) as actual_conversion_rate,
    ROUND(AVG(conversion_probability_score) * 100, 2) as avg_predicted_rate,
    ROUND(ABS(AVG(conversion_rate) - AVG(conversion_probability_score)) * 100, 2) as prediction_error
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
GROUP BY ROUND(conversion_probability_score, 1)
ORDER BY predicted_probability;
```

## 📊 **KPIs y Dashboards**

### 1. **Dashboard Principal de Marketing**

```sql
-- KPIs principales para dashboard
WITH kpis AS (
    SELECT 
        COUNT(*) as total_contacts,
        SUM(conversion_flag) as successful_conversions,
        AVG(conversion_rate) as conversion_rate,
        AVG(contact_duration_seconds) as avg_call_duration,
        AVG(campaign_contacts) as avg_campaign_contacts,
        COUNT(DISTINCT customer_segment) as total_segments
    FROM `tu-proyecto-id.marts.fct_marketing_conversions`
)
SELECT 
    total_contacts,
    successful_conversions,
    ROUND(conversion_rate * 100, 2) as conversion_rate_percent,
    ROUND(avg_call_duration, 2) as avg_call_duration_seconds,
    ROUND(avg_campaign_contacts, 2) as avg_campaign_contacts,
    total_segments,
    ROUND(successful_conversions * 100.0 / total_contacts, 2) as manual_conversion_rate
FROM kpis;
```

### 2. **Top Performers por Segmento**

```sql
-- Top 3 segmentos con mejor performance
SELECT 
    customer_segment,
    COUNT(*) as total_contacts,
    SUM(conversion_flag) as successful_conversions,
    ROUND(AVG(conversion_rate) * 100, 2) as conversion_rate_percent
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
GROUP BY customer_segment
ORDER BY conversion_rate_percent DESC
LIMIT 3;
```

## 🔧 **Consultas de Mantenimiento**

### 1. **Verificación de Calidad de Datos**

```sql
-- Verificar completitud de datos
SELECT 
    'Total Records' as metric,
    COUNT(*) as value
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
UNION ALL
SELECT 
    'Records with Age' as metric,
    COUNT(*) as value
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
WHERE age IS NOT NULL
UNION ALL
SELECT 
    'Records with Contact Type' as metric,
    COUNT(*) as value
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
WHERE contact_type IS NOT NULL
UNION ALL
SELECT 
    'Records with Conversion Flag' as metric,
    COUNT(*) as value
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
WHERE conversion_flag IS NOT NULL;
```

### 2. **Análisis de Distribución de Datos**

```sql
-- Verificar distribución de datos por segmento
SELECT 
    customer_segment,
    COUNT(*) as record_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM `tu-proyecto-id.marts.fct_marketing_conversions`
GROUP BY customer_segment
ORDER BY record_count DESC;
```

## 📈 **Insights y Recomendaciones**

### Insights Principales:

1. **Segmentación Efectiva**: Los segmentos `young_professional` y `white_collar` muestran las tasas de conversión más altas.

2. **Duración de Llamadas**: Las llamadas de duración media (60-300 segundos) tienen mejor tasa de conversión.

3. **Frecuencia de Contacto**: El primer contacto tiene una tasa de conversión significativa, pero múltiples contactos pueden mejorar los resultados.

4. **Perfil de Riesgo**: Los clientes sin riesgo tienen tasas de conversión más altas, pero los clientes de riesgo medio pueden ser un segmento valioso.

### Recomendaciones de Marketing:

1. **Priorizar Segmentos**: Enfocar esfuerzos en `young_professional` y `white_collar`.
2. **Optimizar Duración**: Mantener llamadas entre 60-300 segundos para mejor efectividad.
3. **Estrategia de Contacto**: Implementar campañas de seguimiento para clientes de riesgo medio.
4. **Timing**: Analizar los meses con mejor performance para optimizar timing de campañas.

---

**Nota**: Reemplaza `tu-proyecto-id` con el ID real de tu proyecto GCP en todas las consultas.
