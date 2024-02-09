USE [master]
GO

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'DBMedAlto_BOFF_1'
DROP DATABASE [DBMedAlto_BOFF_1]

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'DBMedAlto_PRAC_1-6'
DROP DATABASE [DBMedAlto_PRAC_1-6]

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'DBMedAlto_SYS'
DROP DATABASE [DBMedAlto_SYS]
