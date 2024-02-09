CREATE FUNCTION [dbo].[ST_STRINGFORMAT]
(
@texto AS nvarchar(MAX)
,@p1 AS sql_variant
,@p2 AS sql_variant = null
,@p3 AS sql_variant = null
,@p4 AS sql_variant = null
,@p5 AS sql_variant = null
,@p6 AS sql_variant = null
,@p7 AS sql_variant = null
,@p8 AS sql_variant = null
)
RETURNS nvarchar(MAX)
BEGIN
	DECLARE	@esp1 AS bit
			,@esp2 AS bit
			,@esp3 AS bit
			,@esp4 AS bit
			,@esp5 AS bit
			,@esp6 AS bit
			,@esp7 AS bit
			,@esp8 AS bit

	SELECT	@esp1 = IIF(@p1 IS NULL OR CHARINDEX('{1}', @texto) = 0, 0, 1)
			,@esp2 = IIF(@p2 IS NULL OR CHARINDEX('{2}', @texto) = 0, 0, 1)
			,@esp3 = IIF(@p3 IS NULL OR CHARINDEX('{3}', @texto) = 0, 0, 1)
			,@esp4 = IIF(@p4 IS NULL OR CHARINDEX('{4}', @texto) = 0, 0, 1)
			,@esp5 = IIF(@p5 IS NULL OR CHARINDEX('{5}', @texto) = 0, 0, 1)
			,@esp6 = IIF(@p6 IS NULL OR CHARINDEX('{6}', @texto) = 0, 0, 1)
			,@esp7 = IIF(@p7 IS NULL OR CHARINDEX('{7}', @texto) = 0, 0, 1)
			,@esp8 = IIF(@p8 IS NULL OR CHARINDEX('{8}', @texto) = 0, 0, 1)

	IF @esp1 = 1
		SET @texto = REPLACE(@texto, '{1}', LTRIM(RTRIM((CAST(@p1 AS nvarchar(MAX))))))
	IF @esp2 = 1
		SET @texto = REPLACE(@texto, '{2}', LTRIM(RTRIM((CAST(@p2 AS nvarchar(MAX))))))
	IF @esp3 = 1
		SET @texto = REPLACE(@texto, '{3}', LTRIM(RTRIM((CAST(@p3 AS nvarchar(MAX))))))
	IF @esp4 = 1
		SET @texto = REPLACE(@texto, '{4}', LTRIM(RTRIM((CAST(@p4 AS nvarchar(MAX))))))
	IF @esp5 = 1
		SET @texto = REPLACE(@texto, '{5}', LTRIM(RTRIM((CAST(@p5 AS nvarchar(MAX))))))
	IF @esp6 = 1
		SET @texto = REPLACE(@texto, '{6}', LTRIM(RTRIM((CAST(@p6 AS nvarchar(MAX))))))
	IF @esp7 = 1
		SET @texto = REPLACE(@texto, '{7}', LTRIM(RTRIM((CAST(@p7 AS nvarchar(MAX))))))
	IF @esp8 = 1
		SET @texto = REPLACE(@texto, '{8}', LTRIM(RTRIM((CAST(@p8 AS nvarchar(MAX))))))

	RETURN	@texto
END