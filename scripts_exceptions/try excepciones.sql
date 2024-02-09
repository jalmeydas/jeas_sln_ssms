RAISERROR (N'This is message %s %d.', -- Message text.
           10, -- Severity,
           1, -- State,
           N'number', -- First argument.
           5); -- Second argument.
-- The message text returned is: This is message number 5.
GO

--  Second example * * * * * * * * * * * *  * * * * *
BEGIN TRY
    -- RAISERROR with severity 11-19 will cause execution to 
    -- jump to the CATCH block.
    RAISERROR ('Error raised in TRY block.', -- Message text.
               11, -- Severity.
               1 -- State.
               );
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE() + ' xxxx',
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    -- Use RAISERROR inside the CATCH block to return error
    -- information about the original error that caused
    -- execution to jump to the CATCH block.
    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH;


-- Third example * * * * * * * * * * * * * * * * * * * * * * 
sp_addmessage @msgnum = 50005,
              @severity = 10,
              @msgtext = N'<<%7.3s>>';
GO
RAISERROR (50005, -- Message id.
           10, -- Severity,
           1, -- State,
           N'abcde'); -- First argument supplies the string.
-- The message text returned is: <<    abc>>.
GO
sp_dropmessage @msgnum = 50005;
GO


-- Fourtth example * * * * * * * * * * * * * * * * * * * * * * 
sp_addmessage @msgnum = 50006,
              @severity = 10,
              @msgtext = N'Este es una prueba de un texto de 2047 caracteres ....';
GO
RAISERROR (50006, -- Message id.
           10, -- Severity,
           1, -- State,
           N'abcde'); -- First argument supplies the string.
-- The message text returned is: <<    abc>>.
GO
-- sp_dropmessage @msgnum = 50006;
GO

-- Fifth example  * * * * * * * * * * * * * * * * 

EXECUTE sp_dropmessage 50005;
GO
EXECUTE sp_addmessage 50005, -- Message id number.
    10, -- Severity.
    N'The current database ID is: %d, the database name is: %s.  the State is : %d';
GO
DECLARE @DBID INT;
SET @DBID = DB_ID();

DECLARE @DBNAME NVARCHAR(128);
SET @DBNAME = DB_NAME();

DECLARE @State INT;
SET @State = 1 ;


RAISERROR (50005,
    18, -- Severity.
    @State, -- State.
    @DBID, -- First substitution argument.
    @DBNAME, -- Second substitution argument.
    @State); -- Third substitution argument.
GO

--- Another example, se tiene que anadir primer el de ingles y despues el que quieras.
EXECUTE sp_dropmessage 60000, @lang = 'French';
GO
EXECUTE sp_dropmessage 60000, @lang = 'us_english';
GO
EXECUTE sp_dropmessage 60000, @lang = 'All';

EXEC sp_addmessage @msgnum = 60000, @severity = 16, 
   @msgtext = N'The item named %s already exists in %s.', 
   @lang = 'us_english';

EXEC sp_addmessage @msgnum = 60000, @severity = 16, 
   @msgtext = N'L''élément nommé %1! existe déjà dans %2!', 
   @lang = 'French';

EXEC sp_addmessage @msgnum = 60000, @severity = 16, 
   @msgtext = N'El elemento %s ya existe en %s.', 
   @lang = 'Español';
   
  
