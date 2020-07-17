SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetDashTableNames
--
--
-- Calls:		None
--
-- Description:	Geta a listing of table names with a '-'  in them.
-- 
-- Date			Modified By			Changes
-- 10/24/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

/****** Script for Select tables with dash in name  ******/
	DECLARE @cmd	nvarchar(4000)
	DECLARE @DbName	nvarchar(128)

	DECLARE @dashtable TABLE (
			catlog	nvarchar(128),
			schemaa	nvarchar(128),
			tablnam nvarchar(128),
			tabltyp	varchar(10))



	DECLARE db_cur CURSOR FOR
		SELECT name
			FROM sys.databases
		WHERE state = 0 and database_id > 4;

	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO
			@DbName;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN

			SET @cmd = 'SELECT [TABLE_CATALOG], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE]
						  FROM [' + @DbName + '].[INFORMATION_SCHEMA].[TABLES]
						WHERE [TABLE_NAME] LIKE (' + '''' + '%-%' + '''' + ') OR' +
						    '[TABLE_NAME] LIKE (' + '''' + '% %' + '''' + ');'

			PRINT @cmd
					
			INSERT INTO @dashtable
				EXEC (@cmd);
		
	
			FETCH NEXT FROM db_cur
				INTO
					@DbName;
		END

	CLOSE db_cur;
	DEALLOCATE db_cur;


	SELECT *
		FROM @dashtable;


END
GO
