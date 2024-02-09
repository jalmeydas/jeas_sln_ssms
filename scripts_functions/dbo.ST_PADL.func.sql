CREATE FUNCTION [dbo].[ST_PADL]
(
@valor AS SQL_VARIANT
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
		SET @retorno = REPLICATE(@caracter, @longitud - @longitudDato) + @cDato

	RETURN	@retorno
END