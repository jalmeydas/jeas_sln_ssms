CREATE FUNCTION [dbo].[ST_PADR]
(
@valor AS sql_variant
,@longitud AS integer
,@caracter AS char(1)
) 
RETURNS varchar(max) 
AS 
BEGIN
	DECLARE	@retorno AS varchar(max)
			,@cDato AS varchar(max)
			,@longitudDato AS integer
	
	SET @cDato = LTRIM(RTRIM(CAST(@valor AS varchar(max))))
	SET @longitudDato = LEN(@cDato)

	IF	(@longitudDato >= @longitud)
		SET @retorno = SUBSTRING(@cDato, 1, @longitud)
	ELSE
		SET @retorno = @cDato + REPLICATE(@caracter, @longitud - @longitudDato)

	RETURN	@retorno
END