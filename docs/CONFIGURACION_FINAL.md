# Guía de Configuración Final - dbt Cloud

## 🎯 Objetivo
Configurar completamente el proyecto dbt Cloud con jobs automatizados, documentación, alertas y gobernanza de datos.

## 📋 Checklist de Configuración

### ✅ 1. Jobs de dbt Cloud

**Configurar en la interfaz de dbt Cloud:**

1. **Ir a Jobs** → **New Job**
2. **Configurar Build Completo:**
   - **Name**: `Build Completo`
   - **Commands**: 
     ```bash
     dbt deps
     dbt build --full-refresh
     ```
   - **Schedule**: `0 2 * * *` (Diario a las 2 AM)
   - **Threads**: 4
   - **Timeout**: 3600 segundos

3. **Configurar Tests:**
   - **Name**: `Ejecutar Tests`
   - **Commands**:
     ```bash
     dbt deps
     dbt test
     ```
   - **Schedule**: `0 3 * * *` (Diario a las 3 AM)

4. **Configurar Documentación:**
   - **Name**: `Generar Documentación`
   - **Commands**:
     ```bash
     dbt deps
     dbt docs generate
     dbt docs serve --port 8080
     ```
   - **Schedule**: `0 4 * * 0` (Semanal los domingos)

### ✅ 2. Notificaciones y Alertas

**Configurar en dbt Cloud:**

1. **Ir a Account Settings** → **Notifications**
2. **Configurar Email Notifications:**
   - ✅ On Success
   - ✅ On Failure
   - ✅ On Cancel

3. **Configurar Slack (opcional):**
   - Agregar webhook de Slack
   - Configurar canal específico para alertas

### ✅ 3. Documentación

**Generar documentación automática:**

1. **Ejecutar en dbt Cloud:**
   ```bash
   dbt docs generate
   dbt docs serve
   ```

2. **Acceder a la documentación:**
   - URL: `https://cloud.getdbt.com/accounts/{account_id}/projects/{project_id}/docs`
   - Revisar todos los modelos y sus relaciones
   - Verificar tests y métricas

### ✅ 4. Monitoreo de Calidad

**Usar los macros creados:**

1. **Ejecutar monitoreo:**
   ```sql
   {{ quality_monitoring() }}
   ```

2. **Verificar alertas:**
   ```sql
   {{ quality_alerts() }}
   ```

3. **Revisar métricas de rendimiento:**
   ```sql
   {{ performance_metrics() }}
   ```

### ✅ 5. Integración con Dataplex (Opcional)

**Configurar gobernanza de datos:**

1. **Habilitar Dataplex API:**
   ```bash
   gcloud services enable dataplex.googleapis.com
   ```

2. **Ejecutar script de integración:**
   - Ir a BigQuery Console
   - Ejecutar `scripts/dataplex_integration.sql`

3. **Verificar entidades creadas:**
   - Ir a Dataplex Console
   - Verificar que las entidades aparecen
   - Revisar políticas de calidad

## 🔧 Configuración Avanzada

### Variables de Entorno en dbt Cloud

**Configurar en Project Settings:**

```yaml
# Variables para diferentes ambientes
DBT_ENV: "production"
BIGQUERY_LOCATION: "US"
PROJECT_ID: "dusa-prj-sandbox"
```

### Configuración de Permisos

**BigQuery IAM Roles necesarios:**
- `roles/bigquery.dataEditor`
- `roles/bigquery.jobUser`
- `roles/dataplex.dataOwner` (si usas Dataplex)

### Configuración de Red

**Para acceso desde dbt Cloud:**
- Configurar IP allowlist si es necesario
- Verificar conectividad a BigQuery

## 📊 Dashboard de Monitoreo

### Métricas a Monitorear

1. **Calidad de Datos:**
   - Tasa de completitud > 95%
   - Tests pasando > 99%
   - Alertas activas = 0

2. **Rendimiento:**
   - Tiempo de build < 30 minutos
   - Tiempo de tests < 10 minutos
   - Uso de recursos < 80%

3. **Negocio:**
   - Tasa de conversión > 10%
   - Distribución de segmentos balanceada
   - Datos actualizados diariamente

### Alertas Recomendadas

```yaml
# Configurar en dbt Cloud
alerts:
  - name: "Build Failure"
    condition: "build_status == 'failed'"
    channels: ["email", "slack"]
    
  - name: "Test Failures"
    condition: "test_failures > 0"
    channels: ["email", "slack"]
    
  - name: "Data Quality Issues"
    condition: "quality_score < 0.95"
    channels: ["email"]
```

## 🚀 Próximos Pasos

### Inmediatos (1-2 semanas)
1. ✅ Configurar jobs automáticos
2. ✅ Implementar alertas básicas
3. ✅ Generar documentación
4. ✅ Configurar monitoreo

### Corto Plazo (1 mes)
1. 🔄 Integrar con Dataplex
2. 🔄 Crear dashboards de métricas
3. 🔄 Implementar tests personalizados
4. 🔄 Configurar CI/CD avanzado

### Mediano Plazo (2-3 meses)
1. 🔄 Machine Learning integration
2. 🔄 Real-time data streaming
3. 🔄 Advanced analytics
4. 🔄 Multi-environment setup

## 🛠️ Troubleshooting

### Problemas Comunes

**Error: "Permission denied"**
```bash
# Verificar permisos de BigQuery
gcloud projects get-iam-policy dusa-prj-sandbox
```

**Error: "Dataset not found"**
```bash
# Crear datasets manualmente
bq mk --location=US dusa-prj-sandbox:bank_marketing_dev_staging
```

**Error: "Job timeout"**
- Aumentar timeout en configuración de job
- Optimizar queries complejas
- Usar incremental models

### Logs y Debugging

**Ver logs en dbt Cloud:**
1. Ir a Jobs → Job History
2. Seleccionar job específico
3. Revisar logs detallados

**Debugging local:**
```bash
dbt debug
dbt run --models model_name --debug
```

## 📞 Soporte

### Recursos Útiles
- [dbt Cloud Documentation](https://docs.getdbt.com/docs/cloud)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Dataplex Documentation](https://cloud.google.com/dataplex/docs)

### Contacto
- **dbt Support**: support@getdbt.com
- **Google Cloud Support**: https://cloud.google.com/support

---

## ✅ Checklist Final

- [ ] Jobs configurados y funcionando
- [ ] Tests pasando al 100%
- [ ] Documentación generada y accesible
- [ ] Alertas configuradas
- [ ] Monitoreo activo
- [ ] Dataplex integrado (opcional)
- [ ] Equipo entrenado en el uso
- [ ] Documentación actualizada

**¡Tu proyecto dbt Cloud está listo para producción! 🎉**