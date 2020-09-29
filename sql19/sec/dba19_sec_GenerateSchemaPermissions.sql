SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sec_GenerateSchemaPermissions
--
--
-- Calls:		None
--
-- Description:	Generate schema permissions for databases
-- 
-- Date			Modified By			Changes
-- 10/28/2016   Aron E. Tekulsky    Initial Coding.
-- 08/24/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @cmd				nvarchar(4000)

	DECLARE @database			nvarchar(128)
	DECLARE @LoopCount			int
	DECLARE @OldTABLE_SCHEMA	nvarchar(128)
	DECLARE @RoleName			nvarchar(128)
	DECLARE @SchemaName			nvarchar(128)

	DECLARE @TABLE_CATALOG		nvarchar(128)
	DECLARE @TABLE_SCHEMA		nvarchar(128)
	DECLARE @TABLE_NAME			nvarchar(128)
	DECLARE @TABLE_TYPE			nvarchar(128)


		
--SET @SchemaName = 'AP';

	--SET @database = 'EDW';
	SET @database = DB_NAME();
	SET @SchemaName = 'dbo';


----SET @RoleName = 'test1' ;
--SET @RoleName = @database  + @SchemaName + 'ReadAccess';


	DECLARE schema_cur CURSOR FOR
		SELECT TABLE_CATALOG, TABLE_SCHEMA , TABLE_NAME , TABLE_TYPE 
			FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_CATALOG = @database AND
			TABLE_SCHEMA = @SchemaName
		ORDER BY TABLE_CATALOG ASC, TABLE_SCHEMA ASC, TABLE_NAME ASC;

	SET @cmd = 'use [' + @database + ']  ;';

	PRINT @cmd

	--EXEC (@cmd)


	OPEN schema_cur;

	FETCH NEXT FROM schema_cur INTO
		@TABLE_CATALOG, @TABLE_SCHEMA , @TABLE_NAME , @TABLE_TYPE 

	-- initialize
	SET @OldTABLE_SCHEMA = '';
	SET @LoopCount = 0;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN

		
			IF @TABLE_SCHEMA <> @OldTABLE_SCHEMA  
				BEGIN

					SET @OldTABLE_SCHEMA = @TABLE_SCHEMA;
					SET @LoopCount = 1;
				END

			WHILE (@LoopCount <= 6)
				BEGIN
					IF @LoopCount = 1 -- read
						BEGIN
							--SET @RoleName = @database  + @TABLE_SCHEMA + 'ReadAccess';
							----------SET @RoleName = @TABLE_SCHEMA + 'ReadAccess';
							IF UPPER(@TABLE_SCHEMA) = 'DBO'
								SET @RoleName = 'DBReader';
							ELSE
								SET @RoleName = 'DB' + @TABLE_SCHEMA + 'Reader';
						END
					ELSE IF @LoopCount = 2 -- update
						BEGIN
							--SET @RoleName = @database  + @TABLE_SCHEMA + 'InsertAccess';
							--SET @RoleName = @TABLE_SCHEMA + 'InsertAccess';
							IF UPPER(@TABLE_SCHEMA) = 'DBO'
								SET @RoleName = 'DBUpdater';
							ELSE
								SET @RoleName = 'DB' + @TABLE_SCHEMA + 'Updater';
						END
					--ELSE IF @LoopCount = 3 -- sa update ETL
					--	BEGIN
					--		--SET @RoleName = @database  + @TABLE_SCHEMA + 'UpdateAccess';
					--		--SET @RoleName = @TABLE_SCHEMA + 'UpdateAccess';
					--		--IF UPPER(@TABLE_SCHEMA) = 'DBO'
					--			SET @RoleName = 'DB_UPD_ETLUpdater';
					--		--ELSE
					--		--	SET @RoleName = 'DB' + @TABLE_SCHEMA + 'Updater';
					--	END
					ELSE IF @LoopCount = 3 -- Programer
						BEGIN
							--SET @RoleName = @database  + @TABLE_SCHEMA + 'DeleteAccess';
							--SET @RoleName = @TABLE_SCHEMA + 'DeleteAccess';
							IF UPPER(@TABLE_SCHEMA) = 'DBO'
								SET @RoleName = 'DBDeveloper';
							ELSE
								SET @RoleName = 'DB' + @TABLE_SCHEMA + 'Developer';
						END
					--ELSE IF @LoopCount = 5 -- Metadata Reader
					--	BEGIN
					--		--SET @RoleName = @database  + @TABLE_SCHEMA + 'DeleteAccess';
					--		--SET @RoleName = @TABLE_SCHEMA + 'DeleteAccess';
					--		IF UPPER(@TABLE_SCHEMA) = 'DBO'
					--			SET @RoleName = 'DukeMetadataReader';
					--		ELSE
					--			SET @RoleName = 'Duke' + @TABLE_SCHEMA + 'MetadataReader';
					--	END
					--ELSE IF @LoopCount = 6 -- Production Suppoer
					--	BEGIN
					--		--SET @RoleName = @database  + @TABLE_SCHEMA + 'DeleteAccess';
					--		--SET @RoleName = @TABLE_SCHEMA + 'DeleteAccess';
					--		IF UPPER(@TABLE_SCHEMA) = 'DBO'
					--			SET @RoleName = 'DukeProdSupport';
					--		ELSE
					--			SET @RoleName = 'Duke' + @TABLE_SCHEMA + 'DukeProdSupport';
					--	END
					ELSE IF @LoopCount = 4 -- Production Support
						BEGIN
							--SET @RoleName = @database  + @TABLE_SCHEMA + 'DeleteAccess';
							--SET @RoleName = @TABLE_SCHEMA + 'DeleteAccess';
							IF UPPER(@TABLE_SCHEMA) = 'DBO'
								SET @RoleName = 'DBDDL_AdminUpdater';
							ELSE
								SET @RoleName = 'DB' + @TABLE_SCHEMA + 'DDL_AdminUpdater';
						END

					-- create the role
					PRINT ''
					PRINT '--Creating ***** role [' + @RoleName + '] for database [' + @database + ']'
					PRINT ''

					SET @cmd = 'CREATE ROLE ['  + @RoleName + '] ;'

					--EXEC (@cmd);
					PRINT @cmd
					PRINT ''

				--END 

					-- increment the loop counter
					SET @LoopCount = @LoopCount + 1;
				END

			PRINT ''
			--PRINT '-- Creating Permissions for Object [' + @database + '].[' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + ']'
			PRINT '-- Creating Permissions for Object ['  + @TABLE_SCHEMA + '].[' + @TABLE_NAME + ']'
			PRINT ''

-----------------------------------------
-- ********** Read Access ********** --
-----------------------------------------

			IF UPPER(@TABLE_SCHEMA) = 'DBO'
				BEGIN
					SET @RoleName = 'DBReader';
					-- reference
					SET @cmd = 'GRANT REFERENCES      ON ' + '[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd

					-- select
					SET @cmd = 'GRANT SELECT          ON '  + '[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd

					-- view the definition of the object
					SET @cmd = 'GRANT VIEW DEFINITION ON ' + '[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd
					PRINT ''

				END
			ELSE
				BEGIN
					SET @RoleName = 'DB' + @TABLE_SCHEMA + 'Reader';
					-- reference
					SET @cmd = 'GRANT REFERENCES      ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd

					-- select
					SET @cmd = 'GRANT SELECT          ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd

					-- view the definition of the object
					SET @cmd = 'GRANT VIEW DEFINITION ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd
					PRINT ''

				END

-----------------------------------------
-- ********** Update Access ********** --
-----------------------------------------

			IF UPPER(@TABLE_SCHEMA) = 'DBO'
				BEGIN
					SET @RoleName = 'DBUpdater';
					-- reference
					SET @cmd = 'GRANT REFERENCES      ON ' + '[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd

					-- select
					SET @cmd = 'GRANT SELECT          ON '  + '[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd

					-- view the definition of the object
					SET @cmd = 'GRANT VIEW DEFINITION ON ' + '[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd

				-- Insert access
					SET @cmd = 'GRANT INSERT          ON ' + '[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
					--EXEC (@cmd);
					PRINT @cmd

				-- Update access
					SET @cmd = 'GRANT UPDATE          ON ' + '[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
					--EXEC (@cmd);
					PRINT @cmd

				-- Delete access
					SET @cmd = 'GRANT DELETE          ON '  + '[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
					--EXEC (@cmd);
					PRINT @cmd

				-- Execute access
					SET @cmd = 'GRANT EXECUTE         ON '  + '[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
					--EXEC (@cmd);
					PRINT @cmd
					PRINT ''

				END
			ELSE
				BEGIN
					SET @RoleName = 'DB' + @TABLE_SCHEMA + 'DBUpdater';
					-- reference
					SET @cmd = 'GRANT REFERENCES      ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd

					-- select
					SET @cmd = 'GRANT SELECT          ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd

					-- view the definition of the object
					SET @cmd = 'GRANT VIEW DEFINITION ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

					PRINT @cmd

				-- Insert access
					SET @cmd = 'GRANT INSERT          ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
					--EXEC (@cmd);
					PRINT @cmd

				-- Update access
					SET @cmd = 'GRANT UPDATE          ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
					--EXEC (@cmd);
					PRINT @cmd


				-- Delete access
					SET @cmd = 'GRANT DELETE          ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
					--EXEC (@cmd);
					PRINT @cmd

				-- Execute access
					SET @cmd = 'GRANT EXECUTE         ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
					--EXEC (@cmd);
					PRINT @cmd

					PRINT ''
				END

				------------SET @RoleName = @database  + @TABLE_SCHEMA + 'ReadAccess';

			------------ reference
			----------SET @cmd = 'GRANT REFERENCES ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

			--EXEC (@cmd);
			----------PRINT @cmd

			---------- select
			----------SET @cmd = 'GRANT SELECT ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'

			--EXEC (@cmd);
			----------PRINT @cmd

			------------ view the definition of the object
			----------SET @cmd = 'GRANT VIEW DEFINITION ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
			--EXEC (@cmd);
			----------PRINT @cmd

-- Set up a insert role
			----------SET @RoleName = @database  + @TABLE_SCHEMA + 'InsertAccess';

			------------ Insert access
			----------SET @cmd = 'GRANT INSERT ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
			------------EXEC (@cmd);
			----------PRINT @cmd

------------ Set up a update role
----------			SET @RoleName = @database  + @TABLE_SCHEMA + 'UpdateAccess';
	
			------------ Insert access
			----------SET @cmd = 'GRANT UPDATE ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
			------------EXEC (@cmd);
			----------PRINT @cmd

------------ Set up delete role
----------			SET @RoleName = @database  + @TABLE_SCHEMA + 'DeleteAccess';
		
			------------ Insert access
			----------SET @cmd = 'GRANT DELETE ON [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '] TO [' + @RoleName + '] ;'
			------------EXEC (@cmd);
			----------PRINT @cmd


			FETCH NEXT FROM schema_cur INTO
				@TABLE_CATALOG, @TABLE_SCHEMA , @TABLE_NAME , @TABLE_TYPE 
		END


	CLOSE schema_cur;

	DEALLOCATE schema_cur;

END
GO
