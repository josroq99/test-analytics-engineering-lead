# Recursos Utilizados - Data Mart de Marketing Bancario

## 🛠️ Herramientas y Tecnologías

### Core Technologies
- **dbt (data build tool)**: Framework principal para transformaciones de datos
  - Versión: 1.10.7
  - Propósito: ETL/ELT, testing, documentación
  - Archivo: `dbt_project.yml`

- **dbt Cloud**: Plataforma cloud para desarrollo y deployment
  - Propósito: CI/CD, scheduling, documentación
  - Configuración: Jobs automáticos, notificaciones

- **BigQuery**: Data warehouse serverless
  - Propósito: Almacenamiento y procesamiento de datos
  - Location: US
  - Project: dusa-prj-sandbox

### Dependencias de dbt
```yaml
# packages.yml
packages:
  - package: calogica/dbt_utils
    version: 1.1.1
```

### Herramientas de Desarrollo
- **Git**: Control de versiones
- **GitHub/GitLab**: Repositorio remoto
- **Python**: Scripts de utilidad
- **SQL**: Transformaciones de datos

## 📊 Datasets y Fuentes de Datos

### Datasets Originales
1. **bank-full.csv** (4,521 registros)
   - Fuente: UCI Machine Learning Repository
   - Descripción: Dataset principal de marketing bancario
   - Campos: 17 variables demográficas y de campaña

2. **bank-additional-full.csv** (4,119 registros)
   - Fuente: UCI Machine Learning Repository
   - Descripción: Dataset con contexto socioeconómico
   - Campos: 21 variables (incluye 4 variables económicas adicionales)

### Datasets Transformados
1. **Raw Layer** (`raw.bank_marketing`, `raw.bank_additional`)
   - Propósito: Datos originales sin transformar
   - Ubicación: BigQuery

2. **Staging Layer** (`stg_bank_marketing`, `stg_bank_additional`)
   - Propósito: Limpieza y estandarización
   - Tipo: Views en BigQuery

3. **Intermediate Layer** (`int_customer_profiles`, `int_campaign_performance`)
   - Propósito: Transformaciones de negocio
   - Tipo: Tables en BigQuery

4. **Marts Layer** (`fct_marketing_conversions`, `dim_customer_segments`)
   - Propósito: Datos finales para análisis
   - Tipo: Tables en BigQuery

## 🔧 Scripts y Automatización

### Scripts de Configuración
1. **`scripts/dataplex_integration.sql`**
   - Propósito: Configuración de gobernanza de datos
   - Funcionalidad: Entidades, políticas, etiquetas

### Scripts de Carga de Datos
```bash
# Comandos bq load para cargar datos raw
bq load --location=US --source_format=CSV \
  dusa-prj-sandbox:raw.bank_marketing \
  bank-full.csv \
  [schema_definition]

bq load --location=US --source_format=CSV \
  dusa-prj-sandbox:raw.bank_additional \
  bank-additional-full.csv \
  [schema_definition]
```

### Scripts de Creación de Datasets
```sql
-- scripts/create_datasets.sql (eliminado, integrado en README)
CREATE SCHEMA IF NOT EXISTS `dusa-prj-sandbox.raw`
CREATE SCHEMA IF NOT EXISTS `dusa-prj-sandbox.bank_marketing_dev_staging`
CREATE SCHEMA IF NOT EXISTS `dusa-prj-sandbox.bank_marketing_dev_intermediate`
CREATE SCHEMA IF NOT EXISTS `dusa-prj-sandbox.bank_marketing_dev_marts`
```

## 📁 Estructura de Archivos

### Archivos de Configuración
- `dbt_project.yml`: Configuración principal del proyecto
- `packages.yml`: Dependencias de dbt
- `requirements.txt`: Dependencias de Python
- `.gitignore`: Archivos a ignorar en Git

### Modelos dbt
```
models/
├── staging/
│   ├── stg_bank_marketing.sql
│   └── stg_bank_additional.sql
├── intermediate/
│   ├── int_customer_profiles.sql
│   └── int_campaign_performance.sql
├── marts/
│   └── marketing/
│       ├── fct_marketing_conversions.sql
│       └── dim_customer_segments.sql
├── schema.yml
└── sources.yml
```

### Tests
```
tests/
├── test_age_group_distribution.sql
└── test_conversion_rate_consistency.sql
```

### Macros
```
macros/
└── quality_monitoring.sql
```

### Documentación
```
docs/
├── CONFIGURACION_FINAL.md
└── models.md
```

## 🔄 Jobs de dbt Cloud

### Job 1: Build Completo
- **Comandos**: `dbt deps`, `dbt build --full-refresh`
- **Schedule**: `0 2 * * *` (Diario a las 2 AM)
- **Timeout**: 3600 segundos
- **Propósito**: Reconstrucción completa del pipeline

### Job 2: Tests
- **Comandos**: `dbt deps`, `dbt test`
- **Schedule**: `0 3 * * *` (Diario a las 3 AM)
- **Timeout**: 1800 segundos
- **Propósito**: Validación de calidad de datos

### Job 3: Documentación
- **Comandos**: `dbt deps`, `dbt docs generate`, `dbt docs serve --port 8080`
- **Schedule**: `0 4 * * 0` (Semanal los domingos)
- **Timeout**: 900 segundos
- **Propósito**: Generación de documentación

## 🧪 Tests Implementados

### Tests de Schema
- **Unicidad**: `unique` en `contact_id`
- **Completitud**: `not_null` en campos obligatorios
- **Valores válidos**: `accepted_values` para categorías

### Tests Personalizados
- **`test_age_group_distribution.sql`**: Verifica distribución de grupos de edad
- **`test_conversion_rate_consistency.sql`**: Valida consistencia de tasas de conversión

### Macros de Monitoreo
- **`quality_monitoring()`**: Métricas de calidad de datos
- **`quality_alerts()`**: Alertas automáticas
- **`performance_metrics()`**: Métricas de rendimiento

## 🔒 Servicios de Gobernanza (Opcional)

### Dataplex
- **API**: `dataplex.googleapis.com`
- **Propósito**: Clasificación y gobernanza de datos
- **Configuración**: `scripts/dataplex_integration.sql`

### BigQuery IAM
- **Roles requeridos**:
  - `roles/bigquery.dataEditor`
  - `roles/bigquery.jobUser`
  - `roles/dataplex.dataOwner` (opcional)

## 📊 Métricas y KPIs Calculados

### Métricas de Conversión
- Tasa de conversión global
- Tasa de conversión por segmento
- Tasa de conversión por campaña

### Segmentación
- Grupos de edad: Young, Adult, Middle Age, Senior
- Perfiles de riesgo: High, Medium, Low, No Risk
- Segmentos de cliente: Young Professional, White Collar, Retired, Blue Collar

### Métricas de Campaña
- Duración de llamadas (Short, Medium, Long)
- Frecuencia de contactos
- Timing de campañas

## 🔧 Comandos de Ejecución

### Comandos dbt Principales
```bash
# Instalar dependencias
dbt deps

# Ejecutar todo el pipeline
dbt build

# Ejecutar solo staging
dbt run --select staging

# Ejecutar tests
dbt test

# Generar documentación
dbt docs generate
dbt docs serve
```

### Comandos de Verificación
```sql
-- Verificar datos en staging
SELECT COUNT(*) FROM `dusa-prj-sandbox.bank_marketing_dev_staging.stg_bank_marketing`;

-- Verificar métricas de conversión
SELECT AVG(conversion_rate) FROM `dusa-prj-sandbox.bank_marketing_dev_marts.fct_marketing_conversions`;
```

## 📚 Recursos de Referencia

### Documentación Oficial
- [dbt Documentation](https://docs.getdbt.com/)
- [dbt Cloud Documentation](https://docs.getdbt.com/docs/cloud)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Dataplex Documentation](https://cloud.google.com/dataplex/docs)

### Datasets Originales
- [UCI Bank Marketing Dataset](https://archive.ics.uci.edu/ml/datasets/Bank+Marketing)

### Comunidad
- [dbt Community](https://community.getdbt.com/)
- [dbt Slack](https://community.getdbt.com/slack)

---

**Nota**: Todos los recursos están configurados para funcionar en conjunto en un entorno de dbt Cloud con BigQuery. Los archivos CSV originales no están incluidos en el repositorio por optimización, pero se proporcionan instrucciones para su carga en BigQuery.