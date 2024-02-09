declare	@pagina as int
declare	@registros as int
declare	@desde as int
declare	@hasta as int

select	@pagina = 1
		,@registros = 100
select	@desde = @registros * (@pagina-1)
select	@hasta = @desde + @registros

--select	@pagina as pagina, @registros as registros, @desde as desde, @hasta as hasta

SELECT	*
FROM	(SELECT	a.ID, a.Codigo
				,a.Nombre1
				,ROW_NUMBER() OVER (ORDER BY a.Nombre1) AS FILA 
		FROM	ssis.Cliente a) AS ALIAS 
WHERE	FILA > @desde
		AND FILA <= @hasta

