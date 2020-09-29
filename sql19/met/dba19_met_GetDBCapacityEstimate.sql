SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_GetDBCapacityEstimate
--
--
-- Calls:		None
--
-- Description:	Get a list of capacity for each database. #tables, views
--				tables w/columns, table lengths and rowcounts.
-- 
-- Date			Modified By			Changes
-- 09/25/2017   Aron E. Tekulsky    Initial Coding.
-- 12/25/2017   Aron E. Tekulsky    Update to Version 140.
-- 06/28/2019	Aron E. Tekulsky	add MaxTableSize8Kpages.
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

	DECLARE @cmd nvarchar(4000)
	DECLARE @dbname nvarchar(128)

	DECLARE @Schematable TABLE (
			[TABLE_CATALOG] nvarchar(128),
			[TABLE_SCHEMA] nvarchar(128),
			[TABLE_NAME] nvarchar(128),
			[COLUMN_NAME] nvarchar(128),
			[DATA_TYPE] nvarchar(128),
			[CHARACTER_MAXIMUM_LENGTH] int,
			[IS_NULLABLE] varchar(3)
			)

	DECLARE @SchemaStats1 TABLE (
			[TABLE_CATALOG] nvarchar(128),
			[TABLE_SCHEMA] nvarchar(128),
			[TABLE_NAME] nvarchar(128),
			[RowLength] bigint
			)

	DECLARE @SchemaStats2 TABLE (
			[TABLE_CATALOG] nvarchar(128),
			[TABLE_SCHEMA] nvarchar(128),
			[TABLE_NAME] nvarchar(128),
			[TABLE_TYPE] char(1),
			[RowCount] bigint,
			[Status] int,
			[IdnName] nvarchar(128)
			)

	DECLARE db_cur CURSOR FOR
		SELECT Name--,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')
			AND state_desc = 'ONLINE'
			AND is_read_only <> 1 --means database=in read only mode
			AND CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
--			[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
		ORDER BY NAME ASC;

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@dbname;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			SET @cmd = '
				USE [' + @dbname + ']' + --CHAR(13) +
			'SELECT s.[TABLE_CATALOG]
					,s.[TABLE_SCHEMA]
					,s.[TABLE_NAME]
					,s.[COLUMN_NAME]
					,s.[DATA_TYPE]
					,ISNULL(s.[CHARACTER_MAXIMUM_LENGTH],t.[max_length]) AS
						CHARACTER_MAXIMUM_LENGTH
					,s.[IS_NULLABLE]
				FROM [' + @dbname + '].[INFORMATION_SCHEMA].[COLUMNS] s
					JOIN [sys].[types] t ON (s.[DATA_TYPE] = t.[name])
			ORDER BY s.[TABLE_CATALOG], s.[TABLE_SCHEMA], s.[TABLE_NAME], s.[ORDINAL_POSITION] ASC'

			INSERT INTO @Schematable
				EXEC(@cmd);

			PRINT @cmd;

			FETCH NEXT FROM db_cur INTO
				@dbname;
		END

	CLOSE db_cur;

	DEALLOCATE db_cur;

	PRINT '***** done part 1 *****';

-- Table Schema listing.

	SELECT *
		FROM @Schematable;

-- Table row lengths.
	INSERT @SchemaStats1
		SELECT c.[TABLE_CATALOG], c.[TABLE_SCHEMA], c.[TABLE_NAME], sum(CONVERT
				(bigint,c.CHARACTER_MAXIMUM_LENGTH)) as RowLength
			FROM @Schematable c
		GROUP BY c.[TABLE_CATALOG], c.[TABLE_SCHEMA], c.[TABLE_NAME];

	DECLARE db_cur CURSOR FOR
		SELECT Name--,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')
			AND state_desc = 'ONLINE'
			AND is_read_only <> 1 --means database=in read only mode
			AND CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
--			[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
		ORDER BY NAME ASC;

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@dbname;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			SET @cmd = 'USE [' + @dbname + ']' + CHAR(13) +
					' SELECT ' + '''' + @dbname + '''' + ', ' + 's.TABLE_SCHEMA,
					object_name(i.id) as tname
					,CASE (SUBSTRING(a.[TABLE_TYPE],1,1) )
					  WHEN ' + '''' + 'B' + '''' + ' THEN ' + '''' + 'T' + '''' +
					' WHEN ' + '''' + 'V' + '''' + ' THEN ' + '''' + 'V' + '''' +
					' ELSE ' + '''' + 'X' + '''' +
					' END AS [TABLE_TYPE]
					,i.rowcnt, i.status, i.name AS IdxName
					FROM ' + @dbname + '.sys.sysindexes i
						JOIN [' + @dbname + '].[INFORMATION_SCHEMA].[TABLES] s ON
							(s.[TABLE_NAME] = object_name(i.id)) AND
							(s.TABLE_CATALOG = ' + '''' + @dbname + '''' + ')
						JOIN [' + @dbname + '].[INFORMATION_SCHEMA].[TABLES] a ON	(a.[TABLE_CATALOG] = s.[TABLE_CATALOG]) AND
																					(a.[TABLE_SCHEMA] = s.[TABLE_SCHEMA]) AND
																					(a.[TABLE_NAME] = s.[TABLE_NAME])
				WHERE i.indid IN (1,0) AND OBJECTPROPERTY(i.id, ' + '''' +
					'IsUserTable' + '''' + ') = 1 --AND
--					 rowcnt > 0
				ORDER BY tname ASC, i.rowcnt DESC'

			INSERT INTO @SchemaStats2
				EXEC(@cmd);

			PRINT @cmd;

			FETCH NEXT FROM db_cur INTO
				@dbname;
		END

	CLOSE db_cur;

	DEALLOCATE db_cur;

	-- Table Lengths
	

	SELECT 'Table Length' AS ReportName, t.[TABLE_CATALOG], t.[TABLE_SCHEMA], t.[TABLE_NAME], c.RowLength, t.[RowCount],
			((CONVERT(decimal(20,4),c.RowLength) *  CONVERT(decimal(20,4),t.[RowCount])) / 1024) AS MaxTableSizeKBytes,
			((CONVERT(decimal(20,4),c.RowLength) * CONVERT(decimal(20,4),t.[RowCount])) / 1024/1024) AS MaxTableSizeMB,
			((CONVERT(decimal(20,4),c.RowLength) * CONVERT(decimal(20,4),t.[RowCount])) / 1024/1024/1024) AS MaxTableSizeGB,
					(((CONVERT(decimal(20,4),c.RowLength) * CONVERT(decimal(20,4),t.[RowCount]))/1024 / 8)) AS MaxTableSize8Kpages--,
			--[TABLE_TYPE]
		FROM @SchemaStats2 t
			JOIN @SchemaStats1 c ON (c.TABLE_CATALOG = t.TABLE_CATALOG ) AND
									(c.TABLE_NAME = t.TABLE_NAME ) AND
									(c.TABLE_SCHEMA = t.TABLE_SCHEMA )
	ORDER BY t.[TABLE_CATALOG], t.[TABLE_SCHEMA], t.[TABLE_NAME] ASC;

-- table counts
	SELECT 'table counts' AS ReportName, t.[TABLE_CATALOG], t.[TABLE_SCHEMA], [TABLE_TYPE], COUNT([TABLE_TYPE]) AS [TABLE_TYPE_Count]
		FROM @SchemaStats2 t
	GROUP BY t.[TABLE_CATALOG], t.[TABLE_SCHEMA],[TABLE_TYPE];

END
GO
