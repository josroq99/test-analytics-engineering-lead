{% macro quality_alert(model_name, column_name, threshold, condition) %}
    {% set query %}
        SELECT 
            COUNT(*) as total_rows,
            COUNT(CASE WHEN {{ condition }} THEN 1 END) as failed_rows,
            (COUNT(CASE WHEN {{ condition }} THEN 1 END) * 100.0 / COUNT(*)) as failure_rate
        FROM {{ ref(model_name) }}
    {% endset %}
    
    {% set results = run_query(query) %}
    
    {% if results %}
        {% set row = results.rows[0] %}
        {% if row[2] > threshold %}
            {{ log("🚨 QUALITY ALERT: " ~ model_name ~ "." ~ column_name ~ " has " ~ row[2] | round(2) ~ "% failure rate (threshold: " ~ threshold ~ "%)", info=true) }}
        {% else %}
            {{ log("✅ QUALITY CHECK PASSED: " ~ model_name ~ "." ~ column_name ~ " has " ~ row[2] | round(2) ~ "% failure rate", info=true) }}
        {% endif %}
    {% endif %}
{% endmacro %}
