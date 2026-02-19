SELECT fc.func_id, fc.func_name, fc.model_id, m.model_name, m.provider
FROM ai_func_config_tb fc
JOIN ai_model_tb m ON fc.model_id = m.model_id
WHERE fc.func_id = 'TC_CLARIFY';

SELECT model_id, model_name, provider FROM ai_model_tb
WHERE model_name LIKE '%gpt-4o%' OR model_name LIKE '%o3%' OR model_name LIKE '%o4%'
ORDER BY model_id;
