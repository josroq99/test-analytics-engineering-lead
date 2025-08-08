-- Script para integración con Dataplex
-- Ejecutar en BigQuery Console después de configurar Dataplex

-- 1. Crear entidades de Dataplex para los datasets
-- Nota: Esto requiere permisos de Dataplex Admin

-- Entidad para staging
CREATE OR REPLACE ENTITY `dusa-prj-sandbox.bank_marketing_dev_dusa_prj_sandbox_staging.stg_bank_marketing`
OPTIONS(
  description="Staging table for bank marketing data",
  display_name="Bank Marketing Staging",
  schema={
    fields=[
      {name="contact_id", type="STRING", mode="REQUIRED", description="Unique contact identifier"},
      {name="age", type="INT64", mode="REQUIRED", description="Customer age"},
      {name="job", type="STRING", mode="REQUIRED", description="Job type"},
      {name="subscribed_deposit", type="BOOL", mode="REQUIRED", description="Conversion flag"}
    ]
  }
);

-- Entidad para intermediate
CREATE OR REPLACE ENTITY `dusa-prj-sandbox.bank_marketing_dev_dusa_prj_sandbox_intermediate.int_customer_profiles`
OPTIONS(
  description="Intermediate table for customer profiles",
  display_name="Customer Profiles Intermediate",
  schema={
    fields=[
      {name="contact_id", type="STRING", mode="REQUIRED", description="Unique contact identifier"},
      {name="age_group", type="STRING", mode="REQUIRED", description="Age group category"},
      {name="risk_profile", type="STRING", mode="REQUIRED", description="Risk assessment"},
      {name="customer_segment", type="STRING", mode="REQUIRED", description="Customer segment"}
    ]
  }
);

-- Entidad para marts
CREATE OR REPLACE ENTITY `dusa-prj-sandbox.bank_marketing_dev_dusa_prj_sandbox_marts.fct_marketing_conversions`
OPTIONS(
  description="Fact table for marketing conversions",
  display_name="Marketing Conversions Fact",
  schema={
    fields=[
      {name="contact_id", type="STRING", mode="REQUIRED", description="Unique contact identifier"},
      {name="conversion_flag", type="INT64", mode="REQUIRED", description="Conversion success flag"},
      {name="conversion_rate", type="FLOAT64", mode="REQUIRED", description="Conversion rate"},
      {name="campaign_contacts", type="INT64", mode="REQUIRED", description="Number of campaign contacts"},
      {name="contact_duration_seconds", type="INT64", mode="REQUIRED", description="Contact duration"}
    ]
  }
);

-- 2. Crear políticas de calidad de datos
-- Política para completitud de datos
CREATE OR REPLACE DATA_QUALITY_RULE `dusa-prj-sandbox.bank_marketing_dev_dusa_prj_sandbox_staging.completeness_rule`
OPTIONS(
  rule_type="NOT_NULL",
  column="contact_id",
  description="Ensure contact_id is never null"
);

-- Política para rangos de edad
CREATE OR REPLACE DATA_QUALITY_RULE `dusa-prj-sandbox.bank_marketing_dev_dusa_prj_sandbox_staging.age_range_rule`
OPTIONS(
  rule_type="RANGE",
  column="age",
  min_value=17,
  max_value=95,
  description="Age must be between 17 and 95"
);

-- 3. Crear etiquetas de clasificación
-- Etiqueta para datos personales
CREATE OR REPLACE TAG `dusa-prj-sandbox.personal_data`
OPTIONS(
  description="Contains personal identifiable information",
  display_name="Personal Data"
);

-- Etiqueta para datos financieros
CREATE OR REPLACE TAG `dusa-prj-sandbox.financial_data`
OPTIONS(
  description="Contains financial information",
  display_name="Financial Data"
);

-- 4. Aplicar etiquetas a las entidades
-- Etiquetar datos personales
CREATE OR REPLACE ENTITY_TAG `dusa-prj-sandbox.bank_marketing_dev_dusa_prj_sandbox_staging.stg_bank_marketing`
OPTIONS(
  tag="dusa-prj-sandbox.personal_data"
);

-- Etiquetar datos financieros
CREATE OR REPLACE ENTITY_TAG `dusa-prj-sandbox.bank_marketing_dev_dusa_prj_sandbox_marts.fct_marketing_conversions`
OPTIONS(
  tag="dusa-prj-sandbox.financial_data"
);

-- 5. Crear vistas de gobernanza
-- Vista para auditoría de datos
CREATE OR REPLACE VIEW `dusa-prj-sandbox.bank_marketing_dev_dusa_prj_sandbox_marts.data_governance_audit`
AS
SELECT 
    'staging' as data_layer,
    'stg_bank_marketing' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN contact_id IS NOT NULL THEN 1 END) as non_null_contact_id,
    COUNT(CASE WHEN age IS NOT NULL THEN 1 END) as non_null_age,
    COUNT(CASE WHEN age BETWEEN 17 AND 95 THEN 1 END) as valid_age_range,
    CURRENT_TIMESTAMP() as audit_timestamp
FROM `dusa-prj-sandbox.bank_marketing_dev_dusa_prj_sandbox_staging.stg_bank_marketing`

UNION ALL

SELECT 
    'marts' as data_layer,
    'fct_marketing_conversions' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN contact_id IS NOT NULL THEN 1 END) as non_null_contact_id,
    COUNT(CASE WHEN conversion_rate BETWEEN 0 AND 1 THEN 1 END) as valid_conversion_rate,
    COUNT(CASE WHEN conversion_flag IN (0, 1) THEN 1 END) as valid_conversion_flag,
    CURRENT_TIMESTAMP() as audit_timestamp
FROM `dusa-prj-sandbox.bank_marketing_dev_dusa_prj_sandbox_marts.fct_marketing_conversions`;

-- 6. Crear alertas de Dataplex
-- Alerta para datos incompletos
CREATE OR REPLACE ALERT `dusa-prj-sandbox.data_quality_alert`
OPTIONS(
  description="Alert for data quality issues",
  condition="completeness_score < 0.95",
  notification_channels=["email", "slack"]
);

-- Comentarios sobre la configuración
/*
INSTRUCCIONES DE USO:

1. Ejecutar este script en BigQuery Console
2. Configurar permisos de Dataplex en Google Cloud Console
3. Verificar que las entidades se crearon correctamente
4. Configurar notificaciones para las alertas
5. Revisar la vista de auditoría regularmente

NOTAS:
- Requiere permisos de Dataplex Admin
- Las etiquetas ayudan con la clasificación de datos
- Las políticas de calidad se ejecutan automáticamente
- La vista de auditoría proporciona métricas de gobernanza
*/
