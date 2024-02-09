declare	@folder_bak as varchar(max) = 'D:\SQL2019DEV\SSDE_BAK\'
		,@folder_dat as varchar(max) = 'D:\SQL2019DEV\SSDE_DAT\'
		,@folder_log as varchar(max) = 'D:\SQL2019DEV\SSDE_LOG\'
		,@nombre as varchar(max) = 'DBMedAlto'
		,@nombre_db as varchar(max)
		,@archivo as varchar(max)
		,@comando as varchar(max)
		,@tiempo as varchar(max) = '2021.03.13'

DECLARE MyCursor CURSOR FOR select 'DBMedAlto_BOFF_1' as [name] 
							union all select 'DBMedAlto_PRAC_1-6' as [name] 
							union all select 'DBMedAlto_SYS' as [name] 
OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @nombre_db
WHILE @@fetch_status = 0
BEGIN
    set @archivo = @folder_bak + @nombre_db + '_' + @tiempo + '.bak'
	set @comando = 'RESTORE DATABASE [' + @nombre_db + '] FROM  DISK = ' + CHAR(39) + @archivo + CHAR(39) + ' WITH FILE = 1'
				+ ', MOVE ' + char(39) + @nombre_db + '_SQL' + char(39) + ' TO ' + char(39) + @folder_dat + @nombre_db + '_SQL.mdf' + char(39)
				+ ', MOVE ' + char(39) + @nombre_db + '_LOG' + char(39) + ' TO ' + char(39) + @folder_log + @nombre_db + '_LOG.ldf' + char(39)
				+ ', NOUNLOAD,  STATS = 5'
	exec (@comando)
    FETCH NEXT FROM MyCursor INTO @nombre_db
END
CLOSE MyCursor
DEALLOCATE MyCursor
