CREATE FUNCTION [dbo].[NULL_ISEQUAL]
(
@valor1 AS sql_variant
,@valor2 AS sql_variant
) 
RETURNS bit
AS 
BEGIN
	DECLARE	@Retorno AS bit
	
	IF	@valor1 IS NULL AND @valor2 IS NULL
		BEGIN
			SET	@Retorno = 1
			GOTO Fin
		END

	IF	@valor1 IS NULL OR @valor2 IS NULL
		BEGIN
			SET	@Retorno = 0
			GOTO Fin
		END

	IF	@valor1 = @valor2
		SET	@Retorno = 1
	ELSE
		SET	@Retorno = 0

	Fin:

	RETURN	@Retorno
END