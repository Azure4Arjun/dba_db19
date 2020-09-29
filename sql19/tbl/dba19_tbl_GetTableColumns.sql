SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GetTableColumns
--
--
-- Calls:		None
--
-- Description:	Get a listing of all table sand their columns.
-- 
-- Date			Modified By			Changes
-- 12/12/2016   Aron E. Tekulsky    Initial Coding.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @cmd			nvarchar(4000)
	DECLARE @dbname			nvarchar(128)

	DECLARE @Schematable TABLE (
			[TABLE_CATALOG]				nvarchar(128),
			[TABLE_SCHEMA]				nvarchar(128),
			[TABLE_NAME]				nvarchar(128),
			[COLUMN_NAME]				nvarchar(128),
			[DATA_TYPE]					nvarchar(128),
			[CHARACTER_MAXIMUM_LENGTH]	int,
			[IS_NULLABLE]				varchar(3)
	)

	DECLARE db_cur CURSOR FOR
		SELECT Name--,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','ReportServer','ReportServerTempDB','dba_db08')
				AND state_desc = 'ONLINE'
				AND is_read_only <> 1 --means database=in read only mode
				AND CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
						--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
		ORDER BY NAME ASC;

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@dbname;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			SET  @cmd = '
				USE [' + @dbname + ']' + --CHAR(13) + 
			'SELECT  [TABLE_CATALOG]
				,[TABLE_SCHEMA]
				,[TABLE_NAME]
				,[COLUMN_NAME]
				,[DATA_TYPE]
				,[CHARACTER_MAXIMUM_LENGTH]
				,[IS_NULLABLE]
				FROM [' + @dbname + '].[INFORMATION_SCHEMA].[COLUMNS]
			ORDER BY [TABLE_CATALOG], [TABLE_SCHEMA], [TABLE_NAME], [ORDINAL_POSITION] ASC'

			INSERT INTO @Schematable
				EXEC(@cmd);

				PRINT @cmd;

		
			FETCH NEXT FROM db_cur INTO
				@dbname;
		END

	CLOSE db_cur;

	DEALLOCATE db_cur;

	SELECT *
		FROM @Schematable;


END
GO
