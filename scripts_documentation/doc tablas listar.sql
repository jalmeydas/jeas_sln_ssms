select	CASE [TABLE_TYPE] 
			WHEN 'BASE TABLE' THEN 'Tabla'
			WHEN 'VIEW' THEN 'Vista'
			ELSE '(Ninguno)'
		END AS [Tipo]
		,'[' + [TABLE_SCHEMA] + '].[' + [TABLE_NAME] + ']' AS [Nombre]
from	INFORMATION_SCHEMA.TABLES
where	not TABLE_NAME like '%etl_erp_%'
order by TABLE_TYPE, TABLE_SCHEMA, TABLE_NAME 