CREATE FUNCTION [dbo].[DDL_GetColumns]
(
@schema AS nvarchar(100)
,@table AS nvarchar(100)
,@mode AS int = 0	-- 0:columns, 1:delimited columns, 2:JSon, 3:parameter, 4:variable, 5:structure, 6:structure JSon, 7:Match columns
,@layout AS bit = 0	-- 0:horizontal, 1:vertical
,@match_alias1 AS char(1) = 'a'
,@match_alias2 AS char(1) = 'b'
)
RETURNS nvarchar(MAX)
BEGIN
	DECLARE	@text AS nvarchar(MAX)
			,@columns AS nvarchar(MAX)
			,@columnsMATCH AS nvarchar(MAX)
			,@parameters AS nvarchar(MAX)
			,@variables AS nvarchar(MAX)
			,@structure AS nvarchar(MAX)
			,@structureJSON AS nvarchar(MAX)
			,@enter AS char(1)

	SELECT	@text = ''
			,@columns = ''
			,@columnsMATCH = ''
			,@parameters = ''
			,@variables = ''
			,@structure = ''
			,@structureJSON = ''
			,@enter = CHAR(13)

	SELECT	@columns += a.COLUMN_NAME + ',',
			@columnsMATCH += @match_alias1 + '.[' + a.COLUMN_NAME + '] = ' + @match_alias2 + '.[' + a.COLUMN_NAME + ']' + IIF(@layout=0, ', ', ',' + @enter),
			@parameters += '@' + a.COLUMN_NAME + ' AS ' + [dbo].[DDL_GetTypeColumn](a.DOMAIN_SCHEMA, a.DOMAIN_NAME, a.DATA_TYPE, a.NUMERIC_PRECISION, a.NUMERIC_SCALE, a.CHARACTER_MAXIMUM_LENGTH) + IIF(a.IS_NULLABLE = 'YES', ' = null', '') + ',' + IIF(@layout=0, ' ', @enter),
			@variables += '@' + a.COLUMN_NAME + ' AS ' + [dbo].[DDL_GetTypeColumn](a.DOMAIN_SCHEMA, a.DOMAIN_NAME, a.DATA_TYPE, a.NUMERIC_PRECISION, a.NUMERIC_SCALE, a.CHARACTER_MAXIMUM_LENGTH) + ',' + IIF(@layout=0, ' ', @enter),
			@structure += '[' + a.COLUMN_NAME + '] ' + [dbo].[DDL_GetTypeColumn](a.DOMAIN_SCHEMA, a.DOMAIN_NAME, a.DATA_TYPE, a.NUMERIC_PRECISION, a.NUMERIC_SCALE, a.CHARACTER_MAXIMUM_LENGTH) + IIF(a.IS_NULLABLE = 'YES', ' NULL', ' NOT NULL') + ',' + IIF(@layout=0, ' ', @enter),
			@structureJSON += '[' + a.COLUMN_NAME + '] ' + [dbo].[DDL_GetTypeColumn](a.DOMAIN_SCHEMA, a.DOMAIN_NAME, a.DATA_TYPE, a.NUMERIC_PRECISION, a.NUMERIC_SCALE, a.CHARACTER_MAXIMUM_LENGTH) + ',' + IIF(@layout=0, ' ', @enter)
	FROM	[INFORMATION_SCHEMA].[COLUMNS] AS a
	WHERE	a.TABLE_SCHEMA = @schema
			and A.TABLE_NAME = @table
	ORDER BY a.ORDINAL_POSITION

	SET @columns = SUBSTRING(@columns, 1, LEN(@columns)-1)

	IF @mode = 0 --columns
		SET @text = REPLACE(@columns, ',', IIF(@layout=0, ', ', ',' + @enter))

	IF @mode = 1 --delimited columns
		SET @text = '[' + REPLACE(@columns, ',', IIF(@layout=0, '], [', '],' + @enter + '[')) + ']'

	IF @mode = 2 --JSon
		SET @text = '{'+ IIF(@layout=0, '', @enter) + '"' + REPLACE(@columns, ',', IIF(@layout=0, '": "", "', '": "",' + @enter + '"')) + '": ""' + IIF(@layout=0, '', @enter) + '}'

	IF @mode = 3 --parameter
		SET @text = SUBSTRING(@parameters, 1, LEN(@parameters) - IIF(@layout=0, 1, 2))

	IF @mode = 4 --variables
		SET @text = SUBSTRING(@variables, 1, LEN(@variables) - IIF(@layout=0, 1, 2))

	IF @mode = 5 --structure
		SET @text = SUBSTRING(@structure, 1, LEN(@structure) - IIF(@layout=0, 1, 2))

	IF @mode = 6 --structure JSon
		SET @text = SUBSTRING(@structureJSON, 1, LEN(@structureJSON) - IIF(@layout=0, 1, 2))

	IF @mode = 7 --Match columns
		SET @text = SUBSTRING(@columnsMATCH, 1, LEN(@columnsMATCH) - IIF(@layout=0, 1, 2))

	RETURN	@text
END