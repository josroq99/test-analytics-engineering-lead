# Data Mart de Marketing Bancario

Este proyecto implementa un Data Mart completo para análisis de campañas de marketing directo bancario utilizando dbt y BigQuery, con gobernanza opcional en Dataplex.

## 📊 Descripción del Proyecto

El Data Mart procesa datos de campañas de marketing directo de una institución bancaria portuguesa, incluyendo:
- **Dataset Principal**: Información de clientes y campañas (4,521 registros)
- **Dataset Adicional**: Contexto socioeconómico adicional (4,119 registros)

### Métricas Clave Implementadas

1. **Tasa de Conversión**: `contactos_exitosos / total_contactos`
2. **Número de Contactos Exitosos**: Conteo de conversiones
3. **Segmentación de Clientes**: Por edad, ocupación y otros criterios
4. **Métricas de Campaña**: Duración, frecuencia, timing
5. **Perfiles de Riesgo**: Clasificación de riesgo del cliente

## 🏗️ Arquitectura del Proyecto

### Estructura de Carpetas

```
bank_marketing_dm/
├── models/
│   ├── staging/           # Modelos de limpieza y estandarización
│   ├── intermediate/      # Modelos intermedios y transformaciones
│   └── marts/
│       └── marketing/     # Data marts finales
├── seeds/                 # CSVs para dbt seed (bank_marketing / bank_additional)
├── tests/                 # Pruebas personalizadas
├── macros/                # Macros reutilizables
├── docs/                  # Documentación adicional
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

## ☁️ Puesta en Marcha con dbt Cloud (Recomendado)

### Prerrequisitos
- Proyecto de **GCP** con **BigQuery** habilitado
- **Service Account** con permisos (BigQuery Admin/Data Editor, Job User)
- Repositorio Git (GitHub, GitLab, Bitbucket)

### Pasos
1. **Sube el repo** a tu proveedor Git.
2. En **dbt Cloud**: crea un proyecto y **conecta el repo**.
3. Configura la **conexión a BigQuery** (sube la clave de Service Account, Project ID, Location, Dataset por defecto `bank_marketing_dev`).
4. Crea 2 entornos:
   - Development → dataset: `bank_marketing_dev`
   - Production → dataset: `bank_marketing_prod`
5. Crea un **Job de Development** con comandos:
   ```bash
   dbt deps
   dbt seed
   dbt run --select staging
   dbt run --select intermediate
   dbt run --select marts
   dbt test
   ```
6. (Opcional) Crea un **Job de Production**:
   ```bash
   dbt deps
   dbt seed
   dbt run --target prod
   dbt test --target prod
   dbt docs generate
   ```

Notas:
- Los CSV ya están en `seeds/` (`bank_marketing.csv`, `bank_additional.csv`). Ejecuta `dbt seed` en los jobs.
- `profiles.yml` no se usa en dbt Cloud (conexión gestionada por la UI de dbt Cloud).

## 🔧 Uso Local (Opcional)

Si quieres ejecutar localmente con dbt Core:

1. Instala dependencias mínimas:
   ```bash
   pip install dbt-core==1.7.0 dbt-bigquery==1.7.0
   dbt deps
   ```
2. Exporta credenciales y configura `profiles.yml` local (no necesario en Cloud).
3. Ejecuta:
   ```bash
   dbt seed
   dbt run
   dbt test
   dbt docs generate && dbt docs serve
   ```

## 📈 Métricas y KPIs

- **Tasa de Conversión Global**: Porcentaje de contactos exitosos
- **Tasa por Segmento**: Conversión por grupo de clientes
- **Tasa por Campaña**: Rendimiento por tipo de contacto
- **Segmentación por Edad**: Young, Adult, Middle Age, Senior
- **Perfiles de Riesgo**: High, Medium, Low, No Risk
- **Métricas de Campaña**: Duración de llamadas, frecuencia, timing

## 🧪 Pruebas y Validación

- Pruebas de integridad: `not_null`, `accepted_values`, reglas de rango (via `dbt_utils.expression_is_true`)
- Pruebas personalizadas: en `tests/`

## 🔒 Gobernanza con Dataplex (Opcional)

- Zonas de datos: Raw, Staging, Curated
- Policy tags: PII, Financial Data, Campaign Data
- Reglas de calidad: completitud mínima del 95%, rangos de edad, dominios válidos

## 🔄 Ejecución Automatizada en dbt Cloud

- Jobs por entorno (Dev/Prod)
- Schedules (cron) y triggers por push
- Logs, alertas y documentación integrados

## 📊 Consultas de Ejemplo

### Tasa de Conversión por Segmento
```sql
SELECT 
    customer_segment,
    COUNT(*) as total_contacts,
    SUM(conversion_flag) as successful_conversions,
    AVG(conversion_rate) * 100 as conversion_rate_percent
FROM {{ ref('fct_marketing_conversions') }}
GROUP BY customer_segment
ORDER BY conversion_rate_percent DESC;
```

### Rendimiento por Tipo de Contacto
```sql
SELECT 
    contact_type,
    call_duration_category,
    COUNT(*) as total_calls,
    AVG(conversion_rate) * 100 as conversion_rate_percent
FROM {{ ref('fct_marketing_conversions') }}
GROUP BY contact_type, call_duration_category
ORDER BY conversion_rate_percent DESC;
```

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

---

**Nota**: Este proyecto es un ejercicio técnico basado en el dataset de UCI Bank Marketing. Los datos son simulados y no representan información real de clientes bancarios.
