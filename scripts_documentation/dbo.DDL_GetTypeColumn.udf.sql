CREATE FUNCTION [dbo].[DDL_GetTypeColumn]
(
@domain_schema AS nvarchar(100)
,@domain_name AS nvarchar(100)
,@datatype AS nvarchar(100)
,@precision AS int = null
,@scale AS int = null
,@length AS int = null
)
RETURNS nvarchar(100)
BEGIN
	DECLARE	@type AS nvarchar(100)

	IF	NOT @domain_name IS NULL
		SET @type = '[' + @domain_schema + '].[' + @domain_name + ']'
	ELSE
		BEGIN
			SET @type = @datatype
			
			IF	NOT @datatype IN ('bit', 'tinyint', 'smallint', 'int', 'bigint', 'smallmoney', 'money', 'float', 'real',
								'date', 'datetimeoffset', 'datetime2', 'smalldatetime', 'datetime', 'time',
								'text', 'ntext',
								'uniqueidentifier', 'sql_variant', 'xml', 'table', 'timestamp')
			BEGIN
				IF NOT @length IS NULL
					SET @type += '(' + CAST(@length AS varchar(10)) + ')'

				IF NOT @precision IS NULL AND NOT @scale IS NULL
					SET @type += '(' + CAST(@precision AS varchar(10)) + ',' + CAST(@scale AS varchar(10)) + ')'

				IF NOT @precision IS NULL AND @scale IS NULL
					SET @type += '(' + CAST(@precision AS varchar(10)) + ')'
			END
		END
	RETURN	@type
END