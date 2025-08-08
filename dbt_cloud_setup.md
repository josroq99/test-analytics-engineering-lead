# 🚀 Configuración para dbt Cloud - Data Mart de Marketing

## 📋 Pasos para Configurar en dbt Cloud

### 1. Crear Proyecto en dbt Cloud

1. **Ir a [cloud.getdbt.com](https://cloud.getdbt.com)**
2. **Crear cuenta** (si no tienes una)
3. **Crear nuevo proyecto**:
   - Nombre: `bank_marketing_dm`
   - Tipo: `dbt Core`
   - Versión: `1.7.0`

### 2. Conectar Repositorio

1. **Conectar GitHub**:
   - Autorizar acceso a GitHub
   - Seleccionar repositorio: `tu-usuario/bank_marketing_dm`
   - Branch por defecto: `main`

### 3. Configurar Conexión BigQuery

1. **En la pestaña "Settings" > "Connections"**:
   - **Connection Type**: `BigQuery`
   - **Project ID**: `tu-proyecto-gcp-id`
   - **Dataset**: `bank_marketing_dev`
   - **Location**: `US` (o tu región)

2. **Configurar Service Account**:
   - **Method**: `Service Account`
   - **Upload JSON key**: Subir tu archivo de service account
   - **Test Connection**: Verificar que funciona

### 4. Configurar Variables de Entorno

En **Settings > Environment Variables**:

```bash
# Variables requeridas
DBT_CLOUD_PROJECT_ID=tu-proyecto-gcp-id
DBT_DATASET=bank_marketing_dev
GCP_LOCATION=US

# Variables opcionales
DBT_CLOUD_RUN_SLOT_COUNT=4
DBT_CLOUD_RUN_TIMEOUT_SECONDS=300
```

### 5. Configurar Jobs

#### Job 1: Development
- **Name**: `Development`
- **Environment**: `Development`
- **Commands**:
```bash
dbt deps
dbt seed
dbt run --select staging
dbt run --select intermediate
dbt run --select marts
dbt test
```

#### Job 2: Production
- **Name**: `Production`
- **Environment**: `Production`
- **Commands**:
```bash
dbt deps
dbt seed
dbt run --target prod
dbt test --target prod
dbt docs generate
```

#### Job 3: Full Refresh
- **Name**: `Full Refresh`
- **Environment**: `Production`
- **Commands**:
```bash
dbt deps
dbt seed --full-refresh
dbt run --target prod --full-refresh
dbt test --target prod
```

### 6. Configurar Schedules

#### Schedule 1: Daily Production Run
- **Job**: `Production`
- **Schedule**: `0 6 * * *` (6 AM daily)
- **Timezone**: `UTC`

#### Schedule 2: Development on Git Push
- **Job**: `Development`
- **Trigger**: `On Git Push`
- **Branch**: `develop`

### 7. Configurar Notificaciones

En **Settings > Notifications**:
- **Email notifications**: Habilitar
- **Slack notifications**: Configurar webhook (opcional)
- **Failure notifications**: Habilitar

## 🔧 Configuración de Ambientes

### Development Environment
```yaml
# En dbt Cloud UI
Target: Development
Threads: 4
Timeout: 300s
Dataset: bank_marketing_dev
```

### Production Environment
```yaml
# En dbt Cloud UI
Target: Production
Threads: 8
Timeout: 600s
Dataset: bank_marketing_prod
```

## 📊 Estructura de Datasets en BigQuery

```sql
-- Crear datasets en BigQuery
CREATE DATASET `tu-proyecto-gcp.bank_marketing_dev`;
CREATE DATASET `tu-proyecto-gcp.bank_marketing_prod`;
CREATE DATASET `tu-proyecto-gcp.raw`;
CREATE DATASET `tu-proyecto-gcp.staging`;
CREATE DATASET `tu-proyecto-gcp.intermediate`;
CREATE DATASET `tu-proyecto-gcp.marts`;
CREATE DATASET `tu-proyecto-gcp.marketing`;
```

## 🚀 Comandos de Prueba

### En dbt Cloud IDE:
```bash
# Verificar conexión
dbt debug

# Instalar dependencias
dbt deps

# Cargar datos de prueba
dbt seed

# Ejecutar modelos de staging
dbt run --select staging

# Ver DAG
dbt ls --select +fct_marketing_conversions

# Ejecutar pruebas
dbt test

# Generar documentación
dbt docs generate
dbt docs serve
```

## 📈 Monitoreo y Alertas

### Métricas a Monitorear:
- **Tiempo de ejecución** de jobs
- **Tasa de éxito** de runs
- **Errores** en modelos
- **Pruebas fallidas**

### Alertas Recomendadas:
- Job failures
- Tests failures
- Long-running jobs (>10 min)
- Data freshness issues

## 🔒 Seguridad

### Permisos de Service Account:
```json
{
  "roles": [
    "roles/bigquery.admin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser"
  ]
}
```

### Acceso a dbt Cloud:
- **SSO**: Configurar si está disponible
- **2FA**: Habilitar para todos los usuarios
- **Audit logs**: Revisar regularmente

## 📝 Checklist de Configuración

- [ ] Proyecto creado en dbt Cloud
- [ ] Repositorio conectado
- [ ] Conexión BigQuery configurada
- [ ] Variables de entorno configuradas
- [ ] Jobs creados (Dev, Prod, Full Refresh)
- [ ] Schedules configurados
- [ ] Notificaciones configuradas
- [ ] Datasets creados en BigQuery
- [ ] Service account con permisos correctos
- [ ] Prueba de conexión exitosa
- [ ] Primer run exitoso

## 🆘 Troubleshooting

### Error: "Connection failed"
- Verificar service account key
- Confirmar permisos en BigQuery
- Verificar project ID

### Error: "Dataset not found"
- Crear datasets en BigQuery
- Verificar nombres de datasets
- Confirmar permisos de escritura

### Error: "Package not found"
- Ejecutar `dbt deps`
- Verificar `packages.yml`
- Confirmar conexión a internet

## 📞 Soporte

- **dbt Cloud Docs**: [docs.getdbt.com](https://docs.getdbt.com)
- **Community**: [discourse.getdbt.com](https://discourse.getdbt.com)
- **Support**: [support.getdbt.com](https://support.getdbt.com)
