# Data Mart de Marketing Bancario - dbt Cloud

Este proyecto implementa un Data Mart completo para análisis de campañas de marketing directo bancario utilizando **dbt Cloud** y **BigQuery**, con gobernanza opcional en **Dataplex**.

## 📊 Descripción del Proyecto

El Data Mart procesa datos de campañas de marketing directo de una institución bancaria portuguesa, transformando datos raw en insights accionables para el negocio.

### Datasets Procesados
- **Dataset Principal**: Información de clientes y campañas (4,521 registros)
- **Dataset Adicional**: Contexto socioeconómico adicional (4,119 registros)

### Métricas Clave Implementadas
1. **Tasa de Conversión**: `contactos_exitosos / total_contactos`
2. **Segmentación de Clientes**: Por edad, ocupación y riesgo
3. **Métricas de Campaña**: Duración, frecuencia, timing
4. **Perfiles de Riesgo**: Clasificación automática de riesgo

## 🏗️ Arquitectura del Proyecto

### Estructura de Carpetas
```
bank_marketing_dm/
├── models/
│   ├── staging/           # Modelos de limpieza y estandarización
│   ├── intermediate/      # Modelos intermedios y transformaciones
│   └── marts/
│       └── marketing/     # Data marts finales
├── tests/                 # Pruebas personalizadas
├── macros/                # Macros de monitoreo y calidad
├── docs/                  # Documentación técnica
├── scripts/               # Scripts de integración
└── dbt_project.yml        # Configuración del proyecto
```

### Capas de Datos
1. **Staging (Vistas)**
   - `stg_bank_marketing`: Limpieza del dataset principal
   - `stg_bank_additional`: Limpieza del dataset adicional

2. **Intermediate (Tablas)**
   - `int_customer_profiles`: Perfiles y segmentación de clientes
   - `int_campaign_performance`: Métricas de rendimiento de campañas

3. **Marts (Tablas)**
   - `fct_marketing_conversions`: Tabla de hechos principal
   - `dim_customer_segments`: Dimensión de segmentos

## 🔄 Proceso Seguido y Decisiones Tomadas

### 1. Uso de dbt Cloud
**Decisión**: Uso de dbt Cloud para mejor gestión y escalabilidad.

**Proceso**:
- Configuración de jobs en dbt Cloud
- Adaptación de configuración para entorno cloud

### 2. Estrategia de Ingesta de Datos
**Decisión**: Carga directa en BigQuery.

**Razones**:
- Mejor rendimiento para datasets grandes
- Separación clara entre datos raw y transformados
- Facilita la gobernanza de datos

**Proceso**:
- Eliminación de archivos CSV del repositorio
- Creación de datasets raw en BigQuery
- Uso de `dbt source()` para referenciar datos

### 3. Optimización de Tests
**Decisión**: Simplificar tests removiendo dependencias problemáticas.

**Proceso**:
- Eliminación de `dbt_utils` por problemas de compatibilidad
- Implementación de tests básicos y confiables
- Uso de `not_null`, `unique`, `accepted_values`

### 4. Configuración de BigQuery
**Decisión**: Usar datasets con prefijos automáticos de dbt Cloud.

**Proceso**:
- Configuración de location `us-central1`
- Naming convention: `bank_marketing_dev_{layer}`
- Creación automática de datasets

## 🚀 Configuración y Ejecución

### Prerrequisitos
- Proyecto de **GCP** con **BigQuery** habilitado
- **Service Account** con permisos (BigQuery Admin/Data Editor, Job User)
- Repositorio Git (GitHub, GitLab, Bitbucket)
- Acceso a **dbt Cloud**

### Paso 1: Preparar Datos en BigQuery

#### 1.1 Crear Datasets
```sql
-- Ejecutar en BigQuery Console
CREATE SCHEMA IF NOT EXISTS `dusa-prj-sandbox.raw`
OPTIONS(location="us-central1", description="Datos raw del proyecto");

CREATE SCHEMA IF NOT EXISTS `dusa-prj-sandbox.bank_marketing_dev_staging`
OPTIONS(location="us-central1", description="Dataset para staging");

CREATE SCHEMA IF NOT EXISTS `dusa-prj-sandbox.bank_marketing_dev_intermediate`
OPTIONS(location="us-central1", description="Dataset para intermediate");

CREATE SCHEMA IF NOT EXISTS `dusa-prj-sandbox.bank_marketing_dev_marts`
OPTIONS(location="us-central1", description="Dataset para marts");
```

#### 1.2 Cargar Datos Raw
```bash
# Cargar dataset principal
bq load --location=us-central1 --source_format=CSV \
  dusa-prj-sandbox:raw.bank_marketing \
  bank-full.csv \
  age:INTEGER,job:STRING,marital:STRING,education:STRING,default:STRING,balance:INTEGER,housing:STRING,loan:STRING,contact:STRING,day:INTEGER,month:STRING,duration:INTEGER,campaign:INTEGER,pdays:INTEGER,previous:INTEGER,poutcome:STRING,y:STRING

# Cargar dataset adicional
bq load --location=Uus-central1 --source_format=CSV \
  dusa-prj-sandbox:raw.bank_additional \
  bank-additional-full.csv \
  age:INTEGER,job:STRING,marital:STRING,education:STRING,default:STRING,balance:INTEGER,housing:STRING,loan:STRING,contact:STRING,day:INTEGER,month:STRING,duration:INTEGER,campaign:INTEGER,pdays:INTEGER,previous:INTEGER,poutcome:STRING,y:STRING,emp_var_rate:FLOAT,cons_price_idx:FLOAT,cons_conf_idx:FLOAT,euribor3m:FLOAT,nr_employed:FLOAT
```

### Paso 2: Configurar dbt Cloud

#### 2.1 Crear Proyecto
1. Ir a [dbt Cloud](https://cloud.getdbt.com)
2. Crear nuevo proyecto
3. Conectar repositorio Git
4. Configurar conexión BigQuery:
   - **Project ID**: `dusa-prj-sandbox`
   - **Location**: `us-central1`
   - **Dataset**: `bank_marketing_dev`

#### 2.2 Configurar Jobs
Crear los siguientes jobs en dbt Cloud:

**Job 1: Build Completo**
```bash
dbt deps
dbt build --full-refresh
```
- **Schedule**: `0 2 * * *` (Diario a las 2 AM)
- **Timeout**: 3600 segundos

**Job 2: Documentación**
```bash
dbt deps
dbt docs generate
dbt docs serve --port 8080
```
- **Schedule**: `0 4 * * 0` (Semanal los domingos)

### Paso 3: Ejecutar Pipeline

#### 3.1 Primera Ejecución
```bash
# En dbt Cloud Development Environment
dbt deps
dbt build
dbt test
```

#### 3.2 Verificar Resultados
```sql
-- Verificar datos en staging
SELECT COUNT(*) FROM `dusa-prj-sandbox.bank_marketing_dev_staging.stg_bank_marketing`;

-- Verificar métricas de conversión
SELECT 
    AVG(conversion_rate) as avg_conversion_rate,
    COUNT(*) as total_contacts
FROM `dusa-prj-sandbox.bank_marketing_dev_marts.fct_marketing_conversions`;
```

## 📈 Consultas de Ejemplo

### Análisis de Conversión por Segmento
```sql
SELECT 
    cs.customer_segment,
    cs.segment_description,
    AVG(fmc.conversion_rate) as avg_conversion_rate,
    COUNT(*) as total_contacts
FROM `dusa-prj-sandbox.bank_marketing_dev_marts.fct_marketing_conversions` fmc
JOIN `dusa-prj-sandbox.bank_marketing_dev_intermediate.int_customer_profiles` icp 
    ON fmc.contact_id = icp.contact_id
JOIN `dusa-prj-sandbox.bank_marketing_dev_marts.dim_customer_segments` cs 
    ON icp.customer_segment = cs.customer_segment
GROUP BY cs.customer_segment, cs.segment_description
ORDER BY avg_conversion_rate DESC;
```

### Rendimiento de Campañas por Duración
```sql
SELECT 
    icp.call_duration_category,
    AVG(fmc.conversion_rate) as conversion_rate,
    COUNT(*) as total_calls
FROM `dusa-prj-sandbox.bank_marketing_dev_marts.fct_marketing_conversions` fmc
JOIN `dusa-prj-sandbox.bank_marketing_dev_intermediate.int_campaign_performance` icp 
    ON fmc.contact_id = icp.contact_id
GROUP BY icp.call_duration_category
ORDER BY conversion_rate DESC;
```

## 🧪 Tests y Validación

### Tests Implementados
- **Unicidad**: `contact_id` en todas las tablas
- **Completitud**: Campos obligatorios con `not_null`
- **Valores válidos**: `accepted_values` para categorías
- **Distribución**: Test personalizado para grupos de edad

### Ejecutar Tests
```bash
# Ejecutar todos los tests
dbt test

# Ejecutar test específico
dbt test --models stg_bank_marketing

# Ejecutar test personalizado
dbt test --select test_age_group_distribution
```

## 📊 Monitoreo y Calidad

### Macros de Monitoreo
El proyecto incluye macros para monitoreo automático:

```sql
-- Monitoreo de calidad
{{ quality_monitoring() }}

-- Alertas de calidad
{{ quality_alerts() }}

### Métricas a Monitorear
1. **Calidad de Datos**: Tasa de completitud > 95%
2. **Rendimiento**: Tiempo de build < 30 minutos
3. **Negocio**: Tasa de conversión > 10%

## 🔒 Gobernanza con Dataplex (Opcional)

### Configuración
1. Habilitar Dataplex API en GCP
2. Ejecutar `scripts/dataplex_integration.sql`
3. Configurar políticas de calidad automáticas

### Beneficios
- Clasificación automática de datos
- Políticas de calidad en tiempo real
- Auditoría de acceso y uso

## 📚 Documentación Adicional

- **`docs/CONFIGURACION_FINAL.md`**: Guía completa de configuración
- **`docs/models.md`**: Documentación técnica de modelos
- **`CONTRIBUTING.md`**: Guías de contribución

## 🛠️ Troubleshooting

### Problemas Comunes

**Error: "Dataset not found"**
```bash
# Verificar datasets creados
bq ls dusa-prj-sandbox
```

**Error: "Permission denied"**
```bash
# Verificar permisos de Service Account
gcloud projects get-iam-policy dusa-prj-sandbox
```

**Error: "Job timeout"**
- Aumentar timeout en configuración de job
- Optimizar queries complejas
- Usar incremental models

### Logs y Debugging
- Ver logs en dbt Cloud: Jobs → Job History
- Debugging local: `dbt debug`

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

---

**Nota**: Este proyecto es un ejercicio técnico basado en el dataset de UCI Bank Marketing. Los datos son simulados y no representan información real de clientes bancarios.
