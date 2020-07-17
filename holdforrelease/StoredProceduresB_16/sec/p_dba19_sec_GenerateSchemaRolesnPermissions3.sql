SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sec_GenerateSchemaRolesnPermissions3
--
-- Arguments:	@databaseName	nvarchar(128),
--				@execute		int,
--				@generaterole	int
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Generate scripts or execute code to create roles for 
--				schema access and apply permisiosns to the roles for 
--				tables and views in the schems.
-- 
-- Date			Modified By			Changes
-- 08/09/2016   Aron E. Tekulsky    Initial Coding.
-- 08/09/2016	ARON E. Tekulsky	V120.	
-- 02/19/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sec_GenerateSchemaRolesnPermissions3 
	-- Add the parameters for the stored procedure here
	@databaseName	nvarchar(128),
	@execute		int,
	@generaterole	int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @alwayson		int
	DECLARE @cmd			nvarchar(4000)

	DECLARE @database		nvarchar(128)
	DECLARE @DBFlag			int
	DECLARE @dbStatus		nvarchar(128)
	DECLARE @name			nvarchar(1000) 
	DECLARE @RoleName		nvarchar(128)
	----------DECLARE @SchemaName		nvarchar(128)

	DECLARE @TABLE_CATALOG	nvarchar(128)
	DECLARE @TABLE_SCHEMA	nvarchar(128)
	DECLARE @TABLE_NAME		nvarchar(128)
	DECLARE @TABLE_TYPE		nvarchar(128)
		
--SET @SchemaName = 'AP';

	IF @databaseName IS NULL OR @databaseName = ''
		BEGIN
			SET @DBFlag = 0; -- set permisisons for all user databases.
			SET @database = '';
		END
	ELSE
		BEGIN
			SET @DBFlag = 1;
			SET @database = @databaseName; -- only the db requested
		END

	IF 	@execute = 0 OR @execute IS NULL
		SET @execute = 0;

	IF @generaterole = 0 OR @generaterole IS NULL
		SET @generaterole = 0;

-- find out if server is runnig always on

	IF [dbo].[f_dba19_utl_GetAlwaysOnNumeric]() = 1 
		SET @alwayson = 1;

	-- get list of db's or not

	IF @DBFlag = 0 
	-- generate list of all db
		BEGIN
-- populate table with db names

			IF @alwayson = 1
				BEGIN
					DECLARE db_cur CURSOR FOR 
						SELECT d.Name,d.state_desc Status--, d.replica_id
							FROM sys.databases d
						WHERE d.name NOT IN ('master', 'model', 'msdb', 'tempdb','Analysis Services Repository')
							AND d.state_desc = 'ONLINE'
							AND d.is_read_only <> 1 AND --means database=in read only mode
							CHARINDEX('-',d.name) = 0 AND -- no dashes in dbname
							[dbo].[f_dba19_utl_GetDBRole](d.name) = 1 -- primary
						order by d.name asc;
				END
			ELSE
				BEGIN
					DECLARE db_cur CURSOR FOR 
						SELECT d.Name,d.state_desc Status--, d.replica_id
							FROM sys.databases d
						WHERE d.name NOT IN ('master', 'model', 'msdb', 'tempdb','Analysis Services Repository')
							AND d.state_desc = 'ONLINE'
							AND d.is_read_only <> 1 AND --means database=in read only mode
							CHARINDEX('-',d.name) = 0 --AND -- no dashes in dbname
						order by d.name asc;
				END
		--END
		-- process all db's
			--BEGIN
				DECLARE db_cur CURSOR FOR 
					SELECT d.Name,d.state_desc Status--, d.replica_id
						FROM sys.databases d
					WHERE d.name NOT IN ('master', 'model', 'msdb', 'tempdb','Analysis Services Repository')
						AND d.state_desc = 'ONLINE'
						AND d.is_read_only <> 1 AND --means database=in read only mode
						CHARINDEX('-',d.name) = 0 --AND -- no dashes in dbname
						AND d.name = @databaseName
					order by d.name asc;
				--END

				OPEN db_cur;

				FETCH NEXT FROM db_cur INTO
					@name, @dbStatus;

	--			WHILE (@@FETCH_STATUS <> -1)
				WHILE (@@FETCH_STATUS = 0)
					BEGIN
			--IF @DBFlag = 0 
			--	SET @database = @databaseName; -- only the db requested
			--ELSE
						SET @database = @name;

						DECLARE schema_cur CURSOR FOR
							SELECT TABLE_CATALOG, TABLE_SCHEMA , TABLE_NAME , TABLE_TYPE 
								FROM INFORMATION_SCHEMA.TABLES
							WHERE TABLE_CATALOG = @database --AND
							ORDER BY TABLE_CATALOG ASC, TABLE_SCHEMA ASC, TABLE_NAME ASC;

						SET @cmd = 'use [' + @database + ']  ;';

						IF @execute = 1
							EXEC (@cmd);
						ELSE
							PRINT @cmd;



						OPEN schema_cur;

						FETCH NEXT FROM schema_cur INTO
							@TABLE_CATALOG, @TABLE_SCHEMA , @TABLE_NAME , @TABLE_TYPE 

						PRINT 'schema is ' + convert(nvarchar(1000),@@FETCH_STATUS)


					-- select 'first one ', fetch_status
					--	from sys.dm_exec_cursors(0);
			
					--select 'second one ',fetch_status
					--	from sys.dm_exec_cursors(1);

			--			WHILE (@@FETCH_STATUS <> -1)
						WHILE (@@FETCH_STATUS = 0)
							BEGIN
								SET @RoleName = @database  + @TABLE_SCHEMA + 'ReadAccess';
			
								SET @cmd = 'GRANT REFERENCES ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

								IF @execute = 1
									EXEC (@cmd);
								ELSE
									PRINT @cmd;
			

								SET @cmd = 'GRANT SELECT ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

								IF @execute = 1
									EXEC (@cmd);
								ELSE
									PRINT @cmd;

								FETCH NEXT FROM schema_cur INTO
									@TABLE_CATALOG, @TABLE_SCHEMA , @TABLE_NAME , @TABLE_TYPE 
							END


						CLOSE schema_cur;

						DEALLOCATE schema_cur;

					FETCH NEXT FROM db_cur INTO
						@name, @dbStatus;

					END

					CLOSE db_cur;

					DEALLOCATE db_cur;
			END
-- end all dbs
	ELSE
		BEGIN
		PRINT '***** specific db *****'

			------IF @alwayson = 1
			------	BEGIN
			------	--DECLARE db_cur CURSOR FOR 
			------		SELECT d.Name,d.state_desc Status--, d.replica_id
			------			FROM sys.databases d
			------		WHERE d.name NOT IN ('master', 'model', 'msdb', 'tempdb','Analysis Services Repository')
			------			AND d.state_desc = 'ONLINE'
			------			AND d.is_read_only <> 1 AND --means database=in read only mode
			------			CHARINDEX('-',d.name) = 0 AND -- no dashes in dbname
			------			[dba_db08].[dbo].[f_dba14_get_dbrole] (d.name) = 1 -- primary
			------			AND d.name = @databaseName
			------		order by d.name asc;
			------	END
			------ELSE
			------	BEGIN
			------		--DECLARE db_cur CURSOR FOR 
			------			SELECT d.Name,d.state_desc Status--, d.replica_id
			------				FROM sys.databases d
			------			WHERE d.name NOT IN ('master', 'model', 'msdb', 'tempdb','Analysis Services Repository')
			------				AND d.state_desc = 'ONLINE'
			------				AND d.is_read_only <> 1 AND --means database=in read only mode
			------				CHARINDEX('-',d.name) = 0 --AND -- no dashes in dbname
			------			order by d.name asc;
			------	END
	-- one db only

			DECLARE schema_cur CURSOR FOR
				SELECT TABLE_CATALOG, TABLE_SCHEMA , TABLE_NAME , TABLE_TYPE 
					FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_CATALOG = @database --AND
				ORDER BY TABLE_CATALOG ASC, TABLE_SCHEMA ASC, TABLE_NAME ASC;

			SET @cmd = 'use [' + @database + ']  ;';

			--IF @execute = 1
				EXEC (@cmd);

			--SET @cmd = 'GO'
			--	EXEC (@cmd);

			--ELSE
				PRINT @cmd;

				SELECT TABLE_CATALOG, TABLE_SCHEMA , TABLE_NAME , TABLE_TYPE 
					FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_CATALOG = @database --AND
				ORDER BY TABLE_CATALOG ASC, TABLE_SCHEMA ASC, TABLE_NAME ASC;

			OPEN schema_cur;

			FETCH NEXT FROM schema_cur INTO
				@TABLE_CATALOG, @TABLE_SCHEMA , @TABLE_NAME , @TABLE_TYPE ;

			PRINT 'schema is ' + convert(nvarchar(1000),@@FETCH_STATUS);


					-- select 'first one ', fetch_status
					--	from sys.dm_exec_cursors(0);
			
					--select 'second one ',fetch_status
					--	from sys.dm_exec_cursors(1);

			--WHILE (@@FETCH_STATUS <> -1)
			WHILE (@@FETCH_STATUS = 0)
				BEGIN
					SET @RoleName = @database  + @TABLE_SCHEMA + 'ReadAccess';
			
					SET @cmd = 'GRANT REFERENCES ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					IF @execute = 1
						EXEC (@cmd);
					ELSE
						PRINT @cmd;
			

					SET @cmd = 'GRANT SELECT ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					IF @execute = 1
						EXEC (@cmd);
					ELSE
						PRINT @cmd;

					FETCH NEXT FROM schema_cur INTO
						@TABLE_CATALOG, @TABLE_SCHEMA , @TABLE_NAME , @TABLE_TYPE ;
				END


			CLOSE schema_cur;

			DEALLOCATE schema_cur;


-- end one db only

		END


	--OPEN db_cur;

	--FETCH NEXT FROM db_cur INTO
	--	@name, @dbStatus;

	--WHILE (@@FETCH_STATUS <> -1)
	--WHILE (@@FETCH_STATUS = 0)
	------	BEGIN
	------		--IF @DBFlag = 0 
	------		--	SET @database = @databaseName; -- only the db requested
	------		--ELSE
	------			SET @database = @name;

	------		DECLARE schema_cur CURSOR FOR
	------			SELECT TABLE_CATALOG, TABLE_SCHEMA , TABLE_NAME , TABLE_TYPE 
	------				FROM INFORMATION_SCHEMA.TABLES
	------			WHERE TABLE_CATALOG = @database --AND
	------			ORDER BY TABLE_CATALOG ASC, TABLE_SCHEMA ASC, TABLE_NAME ASC;

	------		SET @cmd = 'use [' + @database + ']  ;';

	------		IF @execute = 1
	------			EXEC (@cmd);
	------		ELSE
	------			PRINT @cmd;

	------		OPEN schema_cur;

	------		FETCH NEXT FROM schema_cur INTO
	------			@TABLE_CATALOG, @TABLE_SCHEMA , @TABLE_NAME , @TABLE_TYPE 

	------			PRINT 'schema is ' + convert(nvarchar(1000),@@FETCH_STATUS)


	------				-- select 'first one ', fetch_status
	------				--	from sys.dm_exec_cursors(0);
			
	------				--select 'second one ',fetch_status
	------				--	from sys.dm_exec_cursors(1);

	------		--WHILE (@@FETCH_STATUS <> -1)
	------		WHILE (@@FETCH_STATUS = 0)
	------			BEGIN
	------				SET @RoleName = @database  + @TABLE_SCHEMA + 'ReadAccess';
			
	------				SET @cmd = 'GRANT REFERENCES ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

	------				IF @execute = 1
	------					EXEC (@cmd);
	------				ELSE
	------					PRINT @cmd;
			

	------				SET @cmd = 'GRANT SELECT ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

	------				IF @execute = 1
	------					EXEC (@cmd);
	------				ELSE
	------					PRINT @cmd;

	------				FETCH NEXT FROM schema_cur INTO
	------					@TABLE_CATALOG, @TABLE_SCHEMA , @TABLE_NAME , @TABLE_TYPE 
	------			END


	------		CLOSE schema_cur;

	------		DEALLOCATE schema_cur;

	------	--FETCH NEXT FROM db_cur INTO
	------	--@name, @dbStatus;

	------END

	--CLOSE db_cur;

	--DEALLOCATE db_cur;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sec_GenerateSchemaRolesnPermissions3 TO [db_proc_exec] AS [dbo]
GO
