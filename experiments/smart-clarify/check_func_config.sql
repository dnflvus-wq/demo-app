SELECT fc.func_id, fc.func_nm, fc.func_type, m.model_nm, m.model_id
FROM ai_func_config_tb fc
JOIN ai_model_tb m ON fc.model_id = m.model_id
WHERE fc.func_id = 'TC_CLARIFY';
