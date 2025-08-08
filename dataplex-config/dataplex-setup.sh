#!/bin/bash

# Configuración de Dataplex para el Data Mart de Marketing
# Este script configura las zonas de datos, etiquetas y políticas

set -e

# Variables de configuración
PROJECT_ID="${GCP_PROJECT_ID}"
LOCATION="${GCP_LOCATION:-us-central1}"
LAKE_NAME="bank-marketing-lake"

echo "Configurando Dataplex para el proyecto: $PROJECT_ID"

# 1. Crear el Data Lake
echo "Creando Data Lake: $LAKE_NAME"
gcloud dataplex lakes create $LAKE_NAME \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --description="Data Lake para campañas de marketing bancario"

# 2. Crear zonas de datos
echo "Creando zonas de datos..."

# Zona Raw
gcloud dataplex zones create raw-zone \
    --lake=$LAKE_NAME \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --resource-location-type=SINGLE_REGION \
    --discovery-enabled \
    --description="Zona para datos raw de marketing bancario"

# Zona Staging
gcloud dataplex zones create staging-zone \
    --lake=$LAKE_NAME \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --resource-location-type=SINGLE_REGION \
    --discovery-enabled \
    --description="Zona para datos de staging procesados"

# Zona Curated
gcloud dataplex zones create curated-zone \
    --lake=$LAKE_NAME \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --resource-location-type=SINGLE_REGION \
    --discovery-enabled \
    --description="Zona para datos curados y marts"

# 3. Crear assets para cada zona
echo "Creando assets en las zonas..."

# Assets en zona Raw
gcloud dataplex assets create bank-marketing-raw \
    --zone=raw-zone \
    --lake=$LAKE_NAME \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --resource-type=BIGQUERY_DATASET \
    --resource-name="projects/$PROJECT_ID/datasets/raw" \
    --description="Dataset raw con datos originales de marketing"

gcloud dataplex assets create bank-additional-raw \
    --zone=raw-zone \
    --lake=$LAKE_NAME \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --resource-type=BIGQUERY_DATASET \
    --resource-name="projects/$PROJECT_ID/datasets/raw" \
    --description="Dataset raw con contexto socioeconómico"

# Assets en zona Staging
gcloud dataplex assets create staging-models \
    --zone=staging-zone \
    --lake=$LAKE_NAME \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --resource-type=BIGQUERY_DATASET \
    --resource-name="projects/$PROJECT_ID/datasets/staging" \
    --description="Modelos de staging de dbt"

# Assets en zona Curated
gcloud dataplex assets create marketing-marts \
    --zone=curated-zone \
    --lake=$LAKE_NAME \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --resource-type=BIGQUERY_DATASET \
    --resource-name="projects/$PROJECT_ID/datasets/marts" \
    --description="Data marts de marketing"

# 4. Crear Policy Tags para clasificación de datos
echo "Creando Policy Tags..."

# Crear Taxonomy
gcloud data-catalog taxonomies create marketing-taxonomy \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --display-name="Marketing Data Taxonomy" \
    --description="Taxonomía para clasificación de datos de marketing"

# Crear Policy Tags
gcloud data-catalog taxonomies policy-tags create customer-pii \
    --taxonomy=marketing-taxonomy \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --display-name="Customer PII" \
    --description="Datos personales identificables de clientes"

gcloud data-catalog taxonomies policy-tags create financial-data \
    --taxonomy=marketing-taxonomy \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --display-name="Financial Data" \
    --description="Datos financieros y de balance"

gcloud data-catalog taxonomies policy-tags create campaign-data \
    --taxonomy=marketing-taxonomy \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --display-name="Campaign Data" \
    --description="Datos de campañas de marketing"

# 5. Aplicar Policy Tags a las columnas
echo "Aplicando Policy Tags a las columnas..."

# Ejemplo de aplicación de policy tags (esto se haría manualmente o con scripts adicionales)
echo "Policy Tags creados. Aplicar manualmente a las columnas correspondientes:"
echo "- customer-pii: age, job, marital_status, education_level"
echo "- financial-data: balance_euros, has_default_credit, has_housing_loan, has_personal_loan"
echo "- campaign-data: contact_type, campaign_contacts, contact_duration_seconds"

# 6. Crear Data Quality Rules
echo "Configurando reglas de calidad de datos..."

# Crear Data Quality Scan
gcloud dataplex data-scans create marketing-quality-scan \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --data-source-resource="projects/$PROJECT_ID/datasets/marts" \
    --data-quality-spec='{
        "rules": [
            {
                "column": "conversion_rate",
                "dimension": "COMPLETENESS",
                "threshold": 0.95
            },
            {
                "column": "age",
                "dimension": "VALIDITY",
                "rule": {
                    "range_expectation": {
                        "min_value": "17",
                        "max_value": "95"
                    }
                }
            }
        ]
    }' \
    --description="Data Quality scan para marts de marketing"

echo "Configuración de Dataplex completada exitosamente!"
