# Proceso y Decisiones del Data Mart de Marketing

## 🎯 **Objetivo del Ejercicio**

Crear un Data Mart completo para análisis de campañas de marketing directo bancario utilizando las mejores prácticas de ingeniería de datos con dbt, BigQuery y (opcionalmente) Dataplex.

## 📊 **Análisis Inicial de Datos**

### Datasets Identificados
1. **Dataset Principal** (`bank_marketing.csv`): 4,521 registros con información de clientes y campañas
2. **Dataset Adicional** (`bank_additional.csv`): 4,119 registros con contexto socioeconómico

### Estructura de Datos Analizada
- **16 atributos** en el dataset principal
- **20 atributos** en el dataset adicional (incluye 5 indicadores socioeconómicos)
- **Variable objetivo**: `y` (suscripción a depósito a plazo)

## 🏗️ **Decisiones de Arquitectura**

### 1. **Separación en Capas (Layered Architecture)**

**Decisión**: Implementar arquitectura en 3 capas siguiendo las mejores prácticas de dbt.

**Justificación**:
- **Staging**: Limpieza y estandarización de datos raw
- **Intermediate**: Transformaciones complejas y lógica de negocio
- **Marts**: Tablas finales optimizadas para análisis

**Beneficios**:
- Reutilización de código
- Facilidad de mantenimiento
- Trazabilidad de datos
- Testing por capas

### 2. **Materialización de Modelos**

**Decisión**: 
- **Staging**: Vistas (materialized: view)
- **Intermediate**: Tablas (materialized: table)
- **Marts**: Tablas (materialized: table)

**Justificación**:
- Staging como vistas para flexibilidad en cambios
- Intermediate y Marts como tablas para performance en consultas complejas

### 3. **Estrategia de Testing**

**Decisión**: Implementar testing en múltiples niveles:
- **Source Testing**: Validación de datos de entrada
- **Model Testing**: Validación de transformaciones
- **Custom Testing**: Validación de lógica de negocio

**Tipos de pruebas implementadas**:
- `not_null`: Integridad de datos
- `unique`: Unicidad de claves
- `accepted_values`: Validación de dominios
- `dbt_utils.expression_is_true`: Reglas de rango/positividad

## 🔄 **Proceso de Desarrollo**

### Fase 1: Configuración del Proyecto
1. **Análisis de requerimientos**
2. **Configuración de dbt** con BigQuery
3. **Estructura de carpetas** siguiendo convenciones
4. **Configuración de entornos en dbt Cloud** (Dev/Prod)

### Fase 2: Modelado de Datos
1. **Análisis exploratorio** de los datasets
2. **Diseño de modelos staging** para limpieza
3. **Diseño de modelos intermediate** para transformaciones
4. **Diseño de marts** para análisis final

### Fase 3: Implementación de Métricas
1. **Tasa de conversión**: `contactos_exitosos / total_contactos`
2. **Segmentación de clientes**: Por edad, ocupación, riesgo
3. **Métricas de campaña**: Duración, frecuencia, timing
4. **Perfiles de riesgo**: Clasificación automática

### Fase 4: Testing y Validación
1. **Pruebas unitarias**
2. **Pruebas de integración** entre modelos
3. **Validación de métricas de negocio**
4. **Testing de calidad de datos**

### Fase 5: Gobernanza y Automatización
1. **Dataplex** (opcional) para gobernanza
2. **Automatización** con Jobs de dbt Cloud (schedules, alerts)
3. **Documentación** generada con `dbt docs`

## 🎯 **Decisiones de Diseño Específicas**

### 1. **Segmentación de Clientes**

**Decisión**: Crear segmentos principales:
- `young_professional`, `retired`, `white_collar`, `blue_collar`, `other`

**Justificación**: Segmentación basada en comportamiento y demografía para optimizar campañas.

### 2. **Categorización de Edad**

**Decisión**: 4 grupos de edad: `young`, `adult`, `middle_age`, `senior`.

**Justificación**: Diferentes comportamientos financieros por grupo etario.

### 3. **Perfiles de Riesgo**

**Decisión**: `high_risk`, `medium_risk`, `low_risk`, `no_risk`.

**Justificación**: Clasificación por comportamiento crediticio para optimizar ofertas.

### 4. **Métricas de Campaña**

**Decisión**: Categorización de duración de llamadas, frecuencia y timing.

**Justificación**: Optimizar estrategias de contacto y timing de campañas.

## 🔒 **Gobernanza**

- Zonas de datos en Dataplex: Raw, Staging, Curated
- Policy tags: PII, Financial Data, Campaign Data

## 🔄 **Automatización con dbt Cloud**

**Decisión**: Usar Jobs de dbt Cloud en lugar de GitHub Actions.

**Jobs**:
- Dev: `dbt deps && dbt seed && dbt run --select staging intermediate marts && dbt test`
- Prod: `dbt deps && dbt seed && dbt run --target prod && dbt test --target prod && dbt docs generate`

**Justificación**: Simplifica gestión de credenciales, programación, logs y alertas.

## 📈 **Métricas y KPIs Implementados**

- Conversión global y por segmento
- Conversiones exitosas absolutas
- Efectividad por tipo de contacto
- Análisis de riesgo por segmento

## 🧪 **Estrategia de Testing**

- `not_null`, `unique`, `accepted_values`, `dbt_utils.expression_is_true`

## 📋 **Próximos Pasos Recomendados**

- Incrementales para datasets grandes
- Más pruebas personalizadas
- Más métricas y dimensiones
- Schedules y alertas en Prod

---

**Nota**: Este documento refleja decisiones para ejecución en dbt Cloud; la ejecución local sigue siendo posible con dbt Core.
