USE DBA_DB16
GO

IF object_id(N'dbo.v_dba19_sys_BadColumnDataTypes', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_BadColumnDataTypes
GO

-- ======================================================================================
-- v_dba19_sys_BadColumnDataTypes
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 11/01/2010   Aron E. Tekulsky    Initial Coding.
-- 02/11/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2018   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_BadColumnDataTypes AS
	DECLARE @CurrentDatabaseName	nvarchar(128),
			@CurrentDatabaseiD		int,
			@StateDesc				nvarchar(60)
		
	DECLARE @cmd					nvarchar(4000)

	DECLARE db_cur CURSOR FOR
		SELECT name, database_id, state_desc
			FROM sys.databases 
		WHERE state_desc = 'ONLINE' AND
		database_id > 4;
	
	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO @CurrentDatabaseName, @CurrentDatabaseiD, @StateDesc;
	
	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			SET @cmd = ' SELECT i.TABLE_CATALOG, i.TABLE_SCHEMA, i.TABLE_NAME, i.COLUMN_NAME, i.DATA_TYPE
							FROM ' + @CurrentDatabaseName + '.INFORMATION_SCHEMA.COLUMNS i
						WHERE i.DATA_TYPE in (''image'',''text'')';
							
			PRINT @CMD;

			EXEC (@CMD)
	
			FETCH NEXT FROM db_cur
				INTO @CurrentDatabaseName, @CurrentDatabaseiD, @StateDesc;
	
		END
	CLOSE db_cur;

	DEALLOCATE db_cur;

