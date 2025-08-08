# Documentación de Modelos - Bank Marketing Data Model

## Visión General

Este proyecto implementa un data model para análisis de marketing bancario, transformando datos de campañas de marketing en insights accionables para el negocio.

## Arquitectura del Data Model

```
Raw Data (BigQuery)
    ↓
Staging Layer (stg_*)
    ↓
Intermediate Layer (int_*)
    ↓
Marts Layer (fct_*, dim_*)
```

## Capa de Staging

### stg_bank_marketing
**Propósito**: Limpia y estandariza los datos principales de marketing bancario.

**Transformaciones principales**:
- Normalización de campos booleanos (`subscribed_deposit`, `has_default_credit`, etc.)
- Limpieza de strings (trim, lowercase)
- Escape de palabras reservadas (`default`)

**Campos clave**:
- `contact_id`: Identificador único del contacto
- `age`: Edad del cliente
- `job`: Tipo de trabajo
- `subscribed_deposit`: Variable objetivo (conversión)

### stg_bank_additional
**Propósito**: Procesa datos adicionales con contexto socio-económico.

**Diferencias con stg_bank_marketing**:
- Incluye variables adicionales de contexto
- Misma estructura de limpieza que stg_bank_marketing

## Capa Intermedia

### int_customer_profiles
**Propósito**: Crea perfiles de clientes y segmentación demográfica.

**Lógica de negocio**:
- **Age Groups**: 
  - `young`: 17-25 años
  - `adult`: 26-35 años  
  - `middle_age`: 36-50 años
  - `senior`: 51+ años

- **Risk Profile**:
  - `high_risk`: Clientes con múltiples préstamos
  - `medium_risk`: Clientes con algunos préstamos
  - `low_risk`: Clientes sin préstamos
  - `no_risk`: Clientes con buen historial

- **Customer Segments**:
  - `young_professional`: Jóvenes con educación superior
  - `white_collar`: Empleados de oficina
  - `retired`: Personas jubiladas
  - `blue_collar`: Trabajadores manuales
  - `other`: Otros segmentos

### int_campaign_performance
**Propósito**: Analiza el rendimiento de las campañas de marketing.

**Métricas calculadas**:
- **Call Duration Categories**:
  - `short`: < 300 segundos
  - `medium`: 300-600 segundos
  - `long`: > 600 segundos

- **Contact Frequency**:
  - `first_contact`: Primer contacto
  - `few_contacts`: 2-5 contactos
  - `many_contacts`: 6+ contactos

- **Conversion Probability Score**: Score simulado de probabilidad de conversión

## Capa de Marts

### fct_marketing_conversions
**Propósito**: Tabla de hechos con métricas de conversión de marketing.

**Métricas clave**:
- `conversion_flag`: Flag binario de conversión exitosa
- `conversion_rate`: Tasa de conversión (0.0 o 1.0)
- `campaign_contacts`: Número de contactos en la campaña
- `contact_duration_seconds`: Duración del contacto

**Uso típico**: Análisis de efectividad de campañas, cálculo de ROI, optimización de estrategias.

### dim_customer_segments
**Propósito**: Tabla de dimensiones para segmentos de clientes.

**Atributos**:
- `segment_description`: Descripción detallada del segmento
- `contact_priority`: Prioridad de contacto (`high`, `medium`, `low`)
- `recommended_product`: Producto recomendado para el segmento

**Productos por segmento**:
- `young_professional` → `investment_products`
- `retired` → `retirement_products`
- `white_collar` → `premium_services`
- `blue_collar` → `basic_products`
- `other` → `general_products`

## Relaciones entre Modelos

```
stg_bank_marketing ─┐
                    ├─→ int_customer_profiles ──→ dim_customer_segments
stg_bank_additional ─┘
                           ↓
                    int_campaign_performance ──→ fct_marketing_conversions
```

## Casos de Uso

### 1. Análisis de Conversión por Segmento
```sql
SELECT 
    cs.customer_segment,
    cs.segment_description,
    AVG(fmc.conversion_rate) as avg_conversion_rate,
    COUNT(*) as total_contacts
FROM fct_marketing_conversions fmc
JOIN int_customer_profiles icp ON fmc.contact_id = icp.contact_id
JOIN dim_customer_segments cs ON icp.customer_segment = cs.customer_segment
GROUP BY cs.customer_segment, cs.segment_description
ORDER BY avg_conversion_rate DESC;
```

### 2. Rendimiento de Campañas por Duración
```sql
SELECT 
    icp.call_duration_category,
    AVG(fmc.conversion_rate) as conversion_rate,
    COUNT(*) as total_calls
FROM fct_marketing_conversions fmc
JOIN int_campaign_performance icp ON fmc.contact_id = icp.contact_id
GROUP BY icp.call_duration_category
ORDER BY conversion_rate DESC;
```

### 3. Análisis de Riesgo por Edad
```sql
SELECT 
    icp.age_group,
    icp.risk_profile,
    COUNT(*) as customer_count,
    AVG(fmc.conversion_rate) as avg_conversion
FROM fct_marketing_conversions fmc
JOIN int_customer_profiles icp ON fmc.contact_id = icp.contact_id
GROUP BY icp.age_group, icp.risk_profile
ORDER BY icp.age_group, avg_conversion DESC;
```

## Consideraciones de Calidad

### Tests Implementados
- **Unicidad**: `contact_id` en todas las tablas
- **Completitud**: Campos obligatorios con `not_null`
- **Valores válidos**: `accepted_values` para categorías
- **Distribución**: Test personalizado para grupos de edad

### Monitoreo
- Tests ejecutados diariamente
- Alertas automáticas en caso de fallos
- Documentación actualizada semanalmente

## Próximas Mejoras

1. **Métricas de Negocio**: Agregar KPIs específicos del banco
2. **Análisis Temporal**: Incluir tendencias y seasonality
3. **Machine Learning**: Integrar modelos predictivos
4. **Real-time**: Implementar streaming para datos en tiempo real