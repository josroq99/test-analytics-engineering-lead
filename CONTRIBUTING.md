# Guía de Contribución

¡Gracias por tu interés en contribuir al Data Mart de Marketing Bancario! Este documento proporciona las pautas para contribuir al proyecto.

## 🚀 **Cómo Contribuir**

### 1. **Fork del Repositorio**

1. Ve al repositorio principal en GitHub
2. Haz clic en "Fork" en la esquina superior derecha
3. Clona tu fork localmente:
   ```bash
   git clone https://github.com/tu-usuario/bank-marketing-dm.git
   cd bank-marketing-dm
   ```

### 2. **Configurar el Entorno de Desarrollo (Opcional Local)**

1. **Instalar dependencias**:
   ```bash
   pip install dbt-core==1.7.0 dbt-bigquery==1.7.0
   dbt deps
   ```

2. **Verificar configuración**:
   ```bash
   dbt debug
   ```

> Nota: En dbt Cloud la conexión y ejecución se gestiona desde la UI; no necesitas `profiles.yml`.

### 3. **Crear una Rama**

```bash
git checkout -b feature/nombre-de-tu-feature
```

**Convenciones de nombres para ramas**:
- `feature/nueva-funcionalidad`
- `bugfix/correccion-error`
- `docs/mejora-documentacion`
- `test/agregar-pruebas`

### 4. **Hacer Cambios**

#### **Agregar Nuevos Modelos**

1. **Crear modelo en la capa correcta**:
   - `models/staging/` para limpieza de datos
   - `models/intermediate/` para transformaciones
   - `models/marts/` para tablas finales

2. **Agregar documentación**:
   ```sql
   -- Modelo: nombre_del_modelo
   -- Descripción: Breve descripción del modelo
   -- Autor: Tu nombre
   -- Fecha: YYYY-MM-DD
   ```

3. **Agregar pruebas** en `models/schema.yml`:
   ```yaml
   - name: tu_modelo
     description: "Descripción del modelo"
     columns:
       - name: columna
         description: "Descripción de la columna"
         tests:
           - not_null
           - unique
   ```

#### **Agregar Pruebas Personalizadas**

1. Crear archivo en `tests/`:
   ```sql
   -- test_nombre_prueba.sql
   SELECT * FROM {{ ref('modelo') }} WHERE condicion
   ```

#### **Actualizar Documentación**

1. Actualizar `README.md` si es necesario
2. Agregar ejemplos en `docs/ANALISIS_Y_CONSULTAS.md`
3. Actualizar `docs/GUIA_CONFIGURACION.md` si hay cambios en configuración

### 5. **Ejecutar Pruebas**

```bash
# Ejecutar todas las pruebas
dbt test

# Ejecutar pruebas específicas
dbt test --select model:tu_modelo

# Pruebas de seeds
dbt test --select source:raw
```

### 6. **Commit y Push**

```bash
git add .
git commit -m "feat: agregar nueva funcionalidad"
git push origin feature/nombre-de-tu-feature
```

### 7. **Crear Pull Request**

1. Ve a tu fork en GitHub
2. Haz clic en "Compare & pull request"
3. Completa la plantilla de PR:

## 📝 **Plantilla de Pull Request**

```markdown
## Descripción
Breve descripción de los cambios realizados.

## Tipo de Cambio
- [ ] Bug fix (corrección que no rompe funcionalidad existente)
- [ ] Nueva feature (funcionalidad que agrega valor)
- [ ] Breaking change (cambio que rompe funcionalidad existente)
- [ ] Documentación (actualización de docs)

## Cambios Realizados
- [Lista de cambios específicos]

## Pruebas Realizadas
- [ ] Ejecuté `dbt test` y todas las pruebas pasan
- [ ] Ejecuté `dbt run` y los modelos se compilan correctamente
- [ ] Verifiqué la documentación generada con `dbt docs generate`

## Impacto
Descripción del impacto de los cambios en el proyecto.

## Checklist
- [ ] Mi código sigue las pautas de estilo del proyecto
- [ ] He realizado pruebas locales o en dbt Cloud
- [ ] He actualizado la documentación correspondiente
- [ ] Las pruebas nuevas y existentes pasan con mis cambios
```

## 🎯 **Pautas de Desarrollo**

### **Convenciones de Código**

#### **SQL**
- Usar snake_case para nombres de columnas y tablas
- Agregar comentarios descriptivos
- Usar CTEs para queries complejas
- Mantener consistencia en indentación

```sql
-- Ejemplo de modelo bien estructurado
WITH source_data AS (
    SELECT 
        id,
        name,
        created_at
    FROM {{ source('raw', 'table_name') }}
),

cleaned_data AS (
    SELECT 
        id,
        LOWER(TRIM(name)) as clean_name,
        DATE(created_at) as created_date
    FROM source_data
    WHERE name IS NOT NULL
)

SELECT * FROM cleaned_data
```

#### **YAML**
- Usar indentación de 2 espacios
- Mantener orden lógico de elementos
- Agregar descripciones claras

```yaml
version: 2

models:
  - name: modelo_ejemplo
    description: "Descripción clara del modelo"
    columns:
      - name: id
        description: "Identificador único"
        tests:
          - not_null
          - unique
```

### **Estructura de Commits**

Usar [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: agregar nueva funcionalidad de segmentación
fix: corregir error en cálculo de tasa de conversión
docs: actualizar documentación de configuración
test: agregar pruebas para modelo de clientes
refactor: reorganizar estructura de modelos staging
```

## 📚 **Recursos Útiles**

- [dbt Documentation](https://docs.getdbt.com/)
- [dbt Cloud](https://cloud.getdbt.com/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Dataplex Documentation](https://cloud.google.com/dataplex/docs)

---

**¡Gracias por contribuir al Data Mart de Marketing Bancario!** 🎉
