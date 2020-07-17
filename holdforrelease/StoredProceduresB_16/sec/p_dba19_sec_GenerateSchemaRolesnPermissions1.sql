SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sec_GenerateSchemaRolesnPermissions1
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Generate scripts or execute code to create roles for schema access 
--				and apply permisiosns to the roles for tables and views in the schems.
-- 
-- Date			Modified By			Changes
-- 08/09/2016   Aron E. Tekulsky    Initial Coding.
-- 02/19/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sec_GenerateSchemaRolesnPermissions1 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @cmd			nvarchar(4000)

	DECLARE @database		nvarchar(128)
	DECLARE @RoleName		nvarchar(128)
	DECLARE @SchemaName		nvarchar(128)

	DECLARE @TABLE_CATALOG	nvarchar(128)
	DECLARE @TABLE_SCHEMA	nvarchar(128)
	DECLARE @TABLE_NAME		nvarchar(128)
	DECLARE @TABLE_TYPE		nvarchar(128)
		
--SET @SchemaName = 'AP';

	SET @database = 'test16';

----SET @RoleName = 'test1' ;
--SET @RoleName = @database  + @SchemaName + 'ReadAccess';

	DECLARE schema_cur CURSOR FOR
		SELECT TABLE_CATALOG, TABLE_SCHEMA , TABLE_NAME , TABLE_TYPE 
			FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_CATALOG = @database --AND
		--	TABLE_SCHEMA = 'AP'
		ORDER BY TABLE_CATALOG ASC, TABLE_SCHEMA ASC, TABLE_NAME ASC;

	SET @cmd = 'use [' + @database + ']  ;';

	PRINT @cmd;

--EXEC (@cmd)


	OPEN schema_cur;

	FETCH NEXT FROM schema_cur INTO
		@TABLE_CATALOG, @TABLE_SCHEMA , @TABLE_NAME , @TABLE_TYPE 


	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			SET @RoleName = @database  + @TABLE_SCHEMA + 'ReadAccess';


			SET @cmd = 'GRANT REFERENCES ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;';

		--	EXEC (@cmd);
			PRINT @cmd;

			SET @cmd = 'GRANT SELECT ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;';

		--	EXEC (@cmd);
			PRINT @cmd;

			FETCH NEXT FROM schema_cur INTO
				@TABLE_CATALOG, @TABLE_SCHEMA , @TABLE_NAME , @TABLE_TYPE ;
		END


	CLOSE schema_cur;

	DEALLOCATE schema_cur;



	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sec_GenerateSchemaRolesnPermissions1 TO [db_proc_exec] AS [dbo]
GO
