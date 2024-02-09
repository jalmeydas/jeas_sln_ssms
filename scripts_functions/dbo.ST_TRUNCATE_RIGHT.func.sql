CREATE function [dbo].[ST_TRUNCATE_RIGHT]
(
@cadena as nvarchar(max)
,@expresion as nvarchar(max)
)
returns nvarchar(max)
as
BEGIN
	declare	@posicion as int
	
	if @cadena is null or len(ltrim(rtrim(@cadena))) = 0
	or @expresion is null or len(ltrim(rtrim(@expresion))) = 0
	or charindex(@expresion, @cadena) <= 0
		return	@cadena

	select	@posicion = charindex(@expresion, @cadena)

	select	@cadena = substring(@cadena, 1, @posicion - 1)

	return @cadena
END