CREATE FUNCTION [dbo].[ST_SPLIT]
(
@texto as nvarchar(max)
,@DELIMITADOR as nvarchar(10) = N'"'
,@SEPARADOR as varchar(10) = N','
)
returns @table table ([valor] nvarchar(max))
as
begin
	declare	@DELIMITADOR_SEPARADOR as nvarchar(10)
			,@valor as nvarchar(max)
			,@i as int

	select	@DELIMITADOR = isnull(@DELIMITADOR, '"')
			,@SEPARADOR = isnull(@SEPARADOR, ',')

	select	@DELIMITADOR_SEPARADOR = @DELIMITADOR + @SEPARADOR + @DELIMITADOR
			,@texto = trim(@texto)

	-- Quitar delimitador Inicial
	if substring(@texto, 1, len(@DELIMITADOR)) = @DELIMITADOR
		set @texto = substring(@texto, len(@DELIMITADOR)+1, len(@texto))
	
	-- Quitar delimitador Final
	if substring(@texto, len(@texto), len(@DELIMITADOR)) = @DELIMITADOR
		set @texto = substring(@texto, 1, len(@texto) - len(@DELIMITADOR))

	while (charindex(@DELIMITADOR_SEPARADOR, @texto) >= 1)
	begin
		set @i = charindex(@DELIMITADOR_SEPARADOR, @texto)

		set @valor = trim(substring(@texto, 1, @i-1))
		insert into @table ([valor]) values (@valor)

		set @texto = trim(substring(@texto, @i + len(@DELIMITADOR_SEPARADOR), len(@texto)))
	end

	if len(@texto) > 0
		insert into @table ([valor]) values (@texto)
	
	return
end
