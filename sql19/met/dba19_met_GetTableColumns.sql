SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_GetTableColumns
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 12/12/2016   Aron E. Tekulsky    Initial Coding.
-- 09/25/2017	Aron E. Tekulsky	add sys.types to show bytes.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
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

	DECLARE @cmd						nvarchar(4000)
	DECLARE @dbname						nvarchar(128)

	DECLARE @Schematable TABLE (
			[TABLE_CATALOG]				nvarchar(128),
			[TABLE_SCHEMA]				nvarchar(128),
			[TABLE_NAME]				nvarchar(128),
			[COLUMN_NAME]				nvarchar(128),
			[DATA_TYPE]					nvarchar(128),
			[CHARACTER_MAXIMUM_LENGTH]	int,
			[IS_NULLABLE]				varchar(3),
			[BYTES]						int)

	DECLARE db_cur CURSOR FOR
		SELECT Name--,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')
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
				'SELECT  s.[TABLE_CATALOG]
			  ,s.[TABLE_SCHEMA]
				,s.[TABLE_NAME]
			    ,s.[COLUMN_NAME]
				,s.[DATA_TYPE]
				,s.[CHARACTER_MAXIMUM_LENGTH]
				,s.[IS_NULLABLE]
				,ISNULL(s.[CHARACTER_MAXIMUM_LENGTH], t.max_length) AS BYTES
					FROM [' + @dbname + '].[INFORMATION_SCHEMA].[COLUMNS] s
						JOIN sys.types t ON (s.DATA_TYPE = t.name )
				ORDER BY s.[TABLE_CATALOG], s.[TABLE_SCHEMA], s.[TABLE_NAME], s.[ORDINAL_POSITION] ASC'

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
