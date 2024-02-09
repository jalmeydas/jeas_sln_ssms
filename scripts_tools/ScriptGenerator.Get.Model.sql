DECLARE	@APOSTROFE AS char(1) = CHAR(39)
DECLARE	@CARPETA AS varchar(1024) = 'E:\data\adnax\'
-- 1)Esquemas	2)Dominios	3)Tablas	4)Columnas	5)PKs	6)AKs	7)FKs	8)IDXs
DECLARE	@OBJETO AS int = 4
DECLARE	@NOMBRE AS varchar(max) --= 'CanalTipoCuenta'

DECLARE	@Archivo AS varchar(1024)
DECLARE	@Comando_inic AS varchar(1024)
DECLARE	@Comando_fina AS nvarchar(1024)
DECLARE	@Data AS varchar(MAX)

if	@OBJETO is null 
	goto inicio

if	@OBJETO = 1
	goto esquemas
if	@OBJETO = 2
	goto dominios
if	@OBJETO = 3
	goto tablas
if	@OBJETO = 4
	goto columnas
if	@OBJETO = 5
	goto PKs
if	@OBJETO = 6
	goto AKs
if	@OBJETO = 7
	goto FKs
if	@OBJETO = 8
	goto IDXs


inicio:


esquemas:
	SET	@Archivo = '_ddl.Esquema.json'
	SET	@Comando_inic = 'SELECT @Data = BulkColumn FROM OPENROWSET(BULK' + @APOSTROFE + @CARPETA + '{1}' + @APOSTROFE +', SINGLE_BLOB) JSON'
	SET	@Comando_fina = [dbo].[ST_STRINGFORMAT](@Comando_inic, @Archivo, default, default, default, default, default, default, default )

	EXECUTE sp_executesql @Comando_fina, N'@Data varchar(MAX) OUTPUT', @Data = @Data OUTPUT

	select	x.[EsquemaID]
			,isnull(x.[EsquemaID_pad], '') as [EsquemaID_pad]
			,x.[Carpeta]
			,ROW_NUMBER() OVER(ORDER BY x.[Carpeta] ASC) AS [Orden]
			,x.[Titulo-es]
	from	(
			select	[Nodo] as [EsquemaID]
					,[Rama] as [EsquemaID_pad]
					,[DBAdnax_ODS].[dbo].[JSON_GetPathNodo](@Data, 'Esquema', [Nodo]) as [Carpeta]
					,[Texto] as [Titulo-es]
			from	[DBAdnax_ODS].[dbo].[JSON_GetNodosTable](@Data, 'Esquema')
			) as x
	order by x.[Carpeta]

	if not @OBJETO is null 
		goto fin


dominios:
	select	a.[DOMAIN_SCHEMA] as [EsquemaID]
			,a.[DOMAIN_NAME] as [Dominio]
			,a.[DATA_TYPE] as [TipoSQL]
			,iif(a.[CHARACTER_MAXIMUM_LENGTH] is null, '', cast(a.[CHARACTER_MAXIMUM_LENGTH] as varchar(max))) as [Longitud]
			,case
				when a.[DATA_TYPE] in ('int', 'char', 'varchar', 'nchar', 'nvarchar', 'bit', 'date', 'datetime') then ''
				when a.[NUMERIC_PRECISION] = 0 then ''
				else cast(a.[NUMERIC_PRECISION] as varchar(max))
			end as [Precision]
			,case
				when a.[DATA_TYPE] in ('int', 'char', 'varchar', 'nchar', 'nvarchar', 'bit', 'date', 'datetime') then ''
				when a.[NUMERIC_SCALE] = 0 then ''
				else cast(a.[NUMERIC_SCALE] as varchar(max))
			end as [Escala]
	from	[INFORMATION_SCHEMA].[DOMAINS] as a
	order by a.[DOMAIN_SCHEMA], a.[DOMAIN_NAME]

	if not @OBJETO is null 
		goto fin


tablas:
	select	a.[TABLE_SCHEMA] as [EsquemaID]
			,a.[TABLE_NAME] as [Tabla]
	from	[INFORMATION_SCHEMA].[TABLES] as a
	where	a.[TABLE_TYPE] = 'BASE TABLE'
			and not a.[TABLE_NAME] in ('sysdiagrams')
	order by a.[TABLE_SCHEMA]
			,a.[TABLE_NAME]

	if not @OBJETO is null 
		goto fin


columnas:
	select	a.[TABLE_SCHEMA] + '.' + a.[TABLE_NAME] as [TablaID]
			,a.[ORDINAL_POSITION] as [Orden]
			,a.[COLUMN_NAME] as [Columna]
			,iif(a.[DOMAIN_SCHEMA] is null, '', a.[DOMAIN_SCHEMA] + '.' + a.[DOMAIN_NAME]) as [DominioID]
			,iif(a.[IS_NULLABLE] = 'YES', 'No', 'Si') AS [Requerido]
			,iif(b.[is_identity] = 1, 'Si', 'No') as [Consecutivo]
			,iif(b.[is_rowguidcol] = 1, 'Si', 'No') as [GUID]
			,a.[DATA_TYPE] as [TipoSQL]
			,iif(a.[CHARACTER_MAXIMUM_LENGTH] is null, '', cast(a.[CHARACTER_MAXIMUM_LENGTH] as varchar(max))) as [Longitud]
			,case
				when a.[DATA_TYPE] in ('int', 'char', 'varchar', 'nchar', 'nvarchar', 'bit', 'date', 'datetime') then ''
				when a.[NUMERIC_PRECISION] = 0 then ''
				else cast(a.[NUMERIC_PRECISION] as varchar(max))
			end as [Precision]
			,case
				when a.[DATA_TYPE] in ('int', 'char', 'varchar', 'nchar', 'nvarchar', 'bit', 'date', 'datetime') then ''
				when a.[NUMERIC_SCALE] = 0 then ''
				else cast(a.[NUMERIC_SCALE] as varchar(max))
			end as [Escala]
	from	[INFORMATION_SCHEMA].[COLUMNS] as a
			left outer join [sys].[all_columns] as b on OBJECT_ID(a.[TABLE_SCHEMA] + '.' + a.[TABLE_NAME]) = b.[object_id]
														and a.[COLUMN_NAME] = b.[name]
	where	not a.[TABLE_NAME] in ('sysdiagrams')
			and a.[TABLE_NAME] = ISNULL(@NOMBRE, a.[TABLE_NAME])
	order by a.[TABLE_SCHEMA], a.[TABLE_NAME], a.[ORDINAL_POSITION]

	if not @OBJETO is null 
		goto fin

PKs:
	select	a.[TABLE_SCHEMA] + '.' + a.[TABLE_NAME] as [TablaID]
			,(
			select stuff((select ',' + x.[COLUMN_NAME]
			from [INFORMATION_SCHEMA].[KEY_COLUMN_USAGE] as x
			WHERE x.[TABLE_SCHEMA] = a.[TABLE_SCHEMA] and x.[TABLE_NAME] = a.[TABLE_NAME] and x.[CONSTRAINT_NAME] = b.[CONSTRAINT_NAME]
			ORDER BY x.[ORDINAL_POSITION] FOR XML PATH ('')), 1, 1, '')
			) as [Columnas]
	from	[INFORMATION_SCHEMA].[TABLES] as a
			left outer join [INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] AS b ON a.[TABLE_SCHEMA] = b.[TABLE_SCHEMA]
																			and a.[TABLE_NAME] = b.[TABLE_NAME]
																			and 'PRIMARY KEY' = b.[CONSTRAINT_TYPE]
	where	a.[TABLE_TYPE] = 'BASE TABLE'
			and not a.[TABLE_NAME] in ('sysdiagrams')
	order by a.[TABLE_SCHEMA]
			,a.[TABLE_NAME]

	if not @OBJETO is null 
		goto fin


AKs:
	select	a.[TABLE_SCHEMA] + '.' + a.[TABLE_NAME] as [TablaID]
			,(
			select stuff((select ',' + x.[COLUMN_NAME]
			from [INFORMATION_SCHEMA].[KEY_COLUMN_USAGE] as x
			WHERE x.[TABLE_SCHEMA] = a.[TABLE_SCHEMA] and x.[TABLE_NAME] = a.[TABLE_NAME] and x.[CONSTRAINT_NAME] = b.[CONSTRAINT_NAME]
			ORDER BY x.[ORDINAL_POSITION] FOR XML PATH ('')), 1, 1, '')
			) as [Columnas]
			,iif(b.[CONSTRAINT_NAME] = 'AK_' + a.[TABLE_NAME], '', b.[CONSTRAINT_NAME]) as [ak_name]
	from	[INFORMATION_SCHEMA].[TABLES] as a
			inner join [INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] AS b ON a.[TABLE_SCHEMA] = b.[TABLE_SCHEMA]
																			and a.[TABLE_NAME] = b.[TABLE_NAME]
																			and 'UNIQUE' = b.[CONSTRAINT_TYPE]
	where	a.[TABLE_TYPE] = 'BASE TABLE'
			and not a.[TABLE_NAME] in ('sysdiagrams')
	order by a.[TABLE_SCHEMA]
			,a.[TABLE_NAME]
			,b.[CONSTRAINT_NAME]

	if not @OBJETO is null 
		goto fin

FKs:
	select	t.[TABLE_SCHEMA] + '.' + t.[TABLE_NAME] as [TablaID_fk]
			,(
			select stuff((select ',' + x.[COLUMN_NAME]
			from [INFORMATION_SCHEMA].[KEY_COLUMN_USAGE] as x
			WHERE x.[TABLE_SCHEMA] = t.[TABLE_SCHEMA] and x.[TABLE_NAME] = t.[TABLE_NAME] and x.[CONSTRAINT_NAME] = fk.[CONSTRAINT_NAME]
			ORDER BY x.[ORDINAL_POSITION] FOR XML PATH ('')), 1, 1, '')
			) as [Columnas_fk]
			,pk.[TABLE_SCHEMA] + '.' + pk.[TABLE_NAME] as [TablaID_pk]
			,(
			select stuff((select ',' + x.[COLUMN_NAME]
			from [INFORMATION_SCHEMA].[KEY_COLUMN_USAGE] as x
			WHERE x.[TABLE_SCHEMA] = pk.[TABLE_SCHEMA] and x.[TABLE_NAME] = pk.[TABLE_NAME] and x.[CONSTRAINT_NAME] = pk.[CONSTRAINT_NAME]
			ORDER BY x.[ORDINAL_POSITION] FOR XML PATH ('')), 1, 1, '')
			) as [Columnas_pk]
			,iif('FK_' + t.[TABLE_NAME] + '_' + pk.[TABLE_NAME] = fk.[CONSTRAINT_NAME], '', fk.[CONSTRAINT_NAME]) as [fk_name]
	from	[INFORMATION_SCHEMA].[TABLES] as t
			inner join [INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] AS fk ON t.[TABLE_SCHEMA] = fk.[TABLE_SCHEMA]
																			and t.[TABLE_NAME] = fk.[TABLE_NAME]
																			and 'FOREIGN KEY' = fk.[CONSTRAINT_TYPE]
			inner join [INFORMATION_SCHEMA].[REFERENTIAL_CONSTRAINTS] as c ON fk.[CONSTRAINT_NAME] = c.[CONSTRAINT_NAME]
			inner join [INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] AS pk ON c.[CONSTRAINT_SCHEMA] = pk.[TABLE_SCHEMA]
																			and c.[UNIQUE_CONSTRAINT_NAME] = pk.[CONSTRAINT_NAME]
																			and 'PRIMARY KEY' = pk.[CONSTRAINT_TYPE]
	where	t.[TABLE_TYPE] = 'BASE TABLE'
			and not t.[TABLE_NAME] in ('sysdiagrams')
	order by t.[TABLE_SCHEMA]
			,t.[TABLE_NAME]
			,fk.[CONSTRAINT_NAME]

	if not @OBJETO is null 
		goto fin


IDXs:
	declare	@TablaID as varchar(max)
			,@Columnas as varchar(max)
			,@object_ID as int
			,@index_id as int
			,@Columna as varchar(max)
			,@i as int

	declare	@t as table
	(
	[TablaID] varchar(max)
	,[Columnas] varchar(max)
	)

	declare indices cursor for 
	select	t.[TABLE_SCHEMA] + '.' + t.[TABLE_NAME] as [TablaID]
			,OBJECT_ID(t.[TABLE_SCHEMA] + '.' + t.[TABLE_NAME]) as [object_ID]
			,i.[index_id]
	from	[INFORMATION_SCHEMA].[TABLES] as t
			inner join [sys].[indexes] as i on OBJECT_ID(t.[TABLE_SCHEMA] + '.' + t.[TABLE_NAME]) = i.[object_id]
	where	t.[TABLE_TYPE] = 'BASE TABLE'
			and not t.[TABLE_NAME] in ('sysdiagrams')
			and [is_primary_key] = 0
			and [is_unique_constraint] = 0
	order by t.[TABLE_SCHEMA]
			,t.[TABLE_NAME]

	OPEN indices

	FETCH NEXT FROM indices INTO @TablaID, @object_ID, @index_id

	WHILE @@FETCH_STATUS = 0  
	BEGIN
		select	@Columnas = ''
				,@i = 1
				,@Columna = index_col('erp.Empresa', @index_id, @i)

		while not @Columna is null
		begin
			set @Columnas += ',' + @Columna
			set @i += 1
			set @Columna = index_col('erp.Empresa', @index_id, @i)
		end

		insert
		into	@t
				([TablaID], [Columnas])
		values	(@TablaID, stuff(@Columnas, 1, 1, ''))

		FETCH NEXT FROM indices INTO @TablaID, @object_ID, @index_id
	END   
	CLOSE indices
	DEALLOCATE indices

	select * from @t

fin: