SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GetListTablesINViewsWColumnsSO
--
--
-- Calls:		None
--
-- Description:	Get a list of all of the views in a database and each table that
--				is a part of the view. Including Columns.
--
-- https://stackoverflow.com/questions/12000999/how-to-list-the-source-table-name-of-columns-in-a-view-sql-server-2005
-- 
-- Date			Modified By			Changes
-- 09/24/2020   Aron E. Tekulsky    Initial Coding.
-- 09/24/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @DBName	nvarchar(128) -- blank = all, value = one db.
	DECLARE @Cmd	nvarchar (4000)

	SET @DBName = '';

	IF @DBName = ''
		BEGIN
		-- My snipet sql code goes here --
		-- Declare the cursor.
			DECLARE db_cur CURSOR FOR
				SELECT Name--,state_desc Status
					FROM sys.databases
				WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','ReportServer','ReportServerTempDB','dba_db16','SSISDB')
					AND state_desc = 'ONLINE'
					AND is_read_only <> 1 --means database=in read only mode
					AND CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
					--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
				ORDER BY NAME ASC;
		END					
	ELSE
		BEGIN
		-- Declare the cursor.
			DECLARE db_cur CURSOR FOR
				SELECT Name--,state_desc Status
					FROM sys.databases
				WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','ReportServer','ReportServerTempDB','dba_db16','SSISDB')
					AND state_desc = 'ONLINE'
					AND is_read_only <> 1 --means database=in read only mode
					AND CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
					--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
					AND name = @DBName
				ORDER BY NAME ASC;
		END


	-- Open the cursor.
		OPEN db_cur;

	-- Do the first fetch of the cursor.
		FETCH NEXT FROM db_cur INTO
				@DBName;

	-- Set up the loop.
		WHILE (@@FETCH_STATUS <> -1)
			BEGIN
		--  place Code here --
				SET @Cmd = 
				'	SELECT cu.VIEW_CATALOG, cu.VIEW_SCHEMA, cu.VIEW_NAME, 
					cu.TABLE_CATALOG, cu.TABLE_SCHEMA, cu.TABLE_NAME, 
					c.COLUMN_NAME, --c.ORDINAL_POSITION,
					c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH,
					c.IS_NULLABLE,c.COLUMN_DEFAULT, 
					c.NUMERIC_PRECISION, c.NUMERIC_SCALE,
					c.DATETIME_PRECISION
				FROM [' + @DBName + '].[INFORMATION_SCHEMA].[VIEW_COLUMN_USAGE] AS cu
					JOIN [' + @DBName + '].[INFORMATION_SCHEMA].[COLUMNS] AS c ON (c.TABLE_SCHEMA  = cu.TABLE_SCHEMA)
														AND (c.TABLE_CATALOG = cu.TABLE_CATALOG)
														AND (c.TABLE_NAME    = cu.TABLE_NAME)
														AND (c.COLUMN_NAME   = cu.COLUMN_NAME)
			ORDER BY cu.VIEW_CATALOG, cu.VIEW_SCHEMA, cu.VIEW_NAME ASC, c.ORDINAL_POSITION ASC;';

				----PRINT @Cmd;

				EXEC (@Cmd);

				FETCH NEXT FROM db_cur INTO
					@dbname;
			END

	-- Close the cursor.
		CLOSE db_cur;

	-- Deallocate the cursor.
		DEALLOCATE db_cur;
				

	------SELECT cu.VIEW_CATALOG, cu.VIEW_SCHEMA, cu.VIEW_NAME, 
	------		cu.TABLE_CATALOG, cu.TABLE_SCHEMA, cu.TABLE_NAME, 
	------		c.COLUMN_NAME, --c.ORDINAL_POSITION,
	------		c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH,
	------		c.IS_NULLABLE,c.COLUMN_DEFAULT, 
	------		c.NUMERIC_PRECISION, c.NUMERIC_SCALE,
	------		c.DATETIME_PRECISION
	------	FROM INFORMATION_SCHEMA.VIEW_COLUMN_USAGE AS cu
	------		JOIN INFORMATION_SCHEMA.COLUMNS AS c ON (c.TABLE_SCHEMA  = cu.TABLE_SCHEMA)
	------											AND (c.TABLE_CATALOG = cu.TABLE_CATALOG)
	------											AND (c.TABLE_NAME    = cu.TABLE_NAME)
	------											AND (c.COLUMN_NAME   = cu.COLUMN_NAME)
	------ORDER BY cu.VIEW_CATALOG, cu.VIEW_SCHEMA, cu.VIEW_NAME ASC, c.ORDINAL_POSITION ASC;
END
GO
