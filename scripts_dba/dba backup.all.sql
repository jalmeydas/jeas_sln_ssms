declare	@folder_bak as varchar(max) = 'D:\SQL2019DEV\SSDE_BAK\'
		,@nombre as varchar(max) = 'DBMedAlto'
		,@nombre_db as varchar(max)
		,@archivo as varchar(max)
		,@comando as varchar(max)
		,@tiempo as varchar(max) = replace(replace(convert(varchar, getdate(), 120), '-', ''), ':', '')

DECLARE MyCursor CURSOR FOR select [name] from [sys].[databases] where [name] like @nombre + '%'
OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @nombre_db
WHILE @@fetch_status = 0
BEGIN
    set @archivo = @folder_bak + @nombre_db + '_' + @tiempo + '.bak'
	set @comando = 'BACKUP DATABASE [' + @nombre_db + '] TO  DISK = ' + CHAR(39) + @archivo + CHAR(39) + ' WITH NOFORMAT, NOINIT,  SKIP, NOREWIND, NOUNLOAD,  STATS = 10'
	exec (@comando)
    FETCH NEXT FROM MyCursor INTO @nombre_db
END
CLOSE MyCursor
DEALLOCATE MyCursor

