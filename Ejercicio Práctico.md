**Ejercicio Práctico**

Este ejercicio utiliza datos de una campaña de marketing por correo electrónico disponibles en el UCI Machine Learning Repository (Son los archivos que tienes dentro de esta folder). Los datos contienen información sobre diversas campañas de marketing directo de una institución bancaria.



**Objetivo:**

Crear y desplegar un Data Mart que permita al equipo de marketing analizar la efectividad de sus campañas, enfocándose en KPIs como la tasa de conversión, el número de contactos exitosos y la segmentación de clientes.



**Información clave:**

* El diseño de la arquitectura, capas y modelos de datos es a libre elección.
* La solución debe contemplar pruebas unitarias, mantener la calidad de los datos y desplegar modelos de datos en BigQuery
* Los datos se pueden obtener desde Bank Marketing dataset.
* El modelo final debe calcular:
* Tasa de conversión: porcentaje de contactos exitosos sobre el total de contactos.
* Número de contactos exitosos: total de conversiones logradas.
* Segmentación de clientes: clasificación de clientes basada en criterios relevantes como edad, ocupación, etc.
* Las pruebas unitarias minimas a contemplar son:
* Validar tipos de datos.
* Comprobar valores nulos.
* Verificar rangos y unicidad de campos clave.
* Para el despliegue puede configurarse un pipeline CI/CD en cualquier herramienta que considere:
* Validación de código.
* Ejecución de pruebas unitarias.
* Despliegue en BigQuery.
* Configura alertas para pruebas fallidas y realiza auditorías periódicas de calidad de datos.
