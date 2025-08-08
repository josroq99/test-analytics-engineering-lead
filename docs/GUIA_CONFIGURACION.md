# Guía de Configuración y Ejecución del Data Mart (dbt Cloud)

## ☁️ Configuración en dbt Cloud (Recomendado)

### 1. Prerrequisitos
- Proyecto **GCP** con **BigQuery** habilitado
- **Service Account** con permisos: `roles/bigquery.admin`, `roles/bigquery.jobUser`
- Repositorio Git con el código del proyecto

### 2. Conectar el Repositorio
1. Sube este proyecto a GitHub/GitLab/Bitbucket
2. En **dbt Cloud**: New Project → Connect a Git provider → selecciona tu repo y branch `main`

### 3. Configurar Conexión a BigQuery
1. En el proyecto de dbt Cloud, abre Settings → Environments → Connection
2. Tipo: BigQuery
3. Project ID: tu-proyecto-id
4. Location: US (o tu región)
5. Método: Service Account → sube el JSON de la clave
6. Test Connection

### 4. Crear Entornos
- Development → Dataset: `bank_marketing_dev`
- Production → Dataset: `bank_marketing_prod`

### 5. Seeds (Datos)
Los CSV se incluyen en `seeds/`:
- `seeds/bank_marketing.csv`
- `seeds/bank_additional.csv`

En tus Jobs, ejecuta `dbt seed` antes de `dbt run`.

### 6. Crear Jobs
- Development
  ```bash
  dbt deps
  dbt seed
  dbt run --select staging
  dbt run --select intermediate
  dbt run --select marts
  dbt test
  ```
- Production (opcional)
  ```bash
  dbt deps
  dbt seed
  dbt run --target prod
  dbt test --target prod
  dbt docs generate
  ```

### 7. Schedules y Alertas
- Programa ejecución diaria/semanal
- Habilita notificaciones por email/Slack

---

## 💻 Ejecución Local (Opcional)

### 1. Instalar Dependencias
```bash
pip install dbt-core==1.7.0 dbt-bigquery==1.7.0
```

### 2. Ejecutar Proyecto
```bash
dbt deps
dbt seed
dbt run
dbt test
dbt docs generate && dbt docs serve
```

> Nota: Localmente necesitas `profiles.yml` y variables de entorno; en dbt Cloud no.

---

## 🔒 Dataplex (Opcional)
Si usas Dataplex, consulta `dataplex-config/dataplex-setup.sh` y ejecuta desde un entorno con gcloud CLI.

---

## 🧪 Pruebas
- Pruebas de seeds en `seeds/schema.yml` (usa `dbt_utils`)
- Pruebas de modelos en `models/schema.yml` y `tests/`

---

## 📚 Recursos
- dbt Cloud: https://cloud.getdbt.com/
- Docs dbt: https://docs.getdbt.com/
- BigQuery: https://cloud.google.com/bigquery/docs
