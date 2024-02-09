-- Crear una Secuencia
CREATE SEQUENCE [dbo].[Ejemplo_Sequence]
		AS INT
		START WITH 1
		INCREMENT BY 1
		NO MAXVALUE
		NO CYCLE

-- Modificar una Secuencia
ALTER SEQUENCE [dbo].[Ejemplo_Sequence] RESTART WITH 1

-- Saber si existe la secuencia
IF EXISTS (SELECT * FROM [INFORMATION_SCHEMA].[SEQUENCES] WHERE SEQUENCE_SCHEMA = 'dbo' AND SEQUENCE_NAME = 'Secuencia_tmp')
	DROP SEQUENCE [dbo].[Secuencia_tmp]
