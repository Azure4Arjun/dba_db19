SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_GetEstimateBackpSizeAllDBDetailSS
--
--
-- Calls:		None
--
-- Description:	Get an estimate of the size of a native full backup for all
--				db's on the server.
-- 
-- https://www.sqlshack.com/forecast-sql-backup-size/
-- 
-- Date			Modified By			Changes
-- 01/01/2012	Aron E. Tekulsky	Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
-- 05/06/2020   Aron E. Tekulsky    Update to Version 150.
-- 05/07/2020	Aron E. Tekulsky	Convert to usiong sys.database_files.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	CREATE TABLE #Spaceusedtable (
		DatabaseName		NVARCHAR(128)
		,DatabaseSize		DECIMAL(15, 2)
		,UnallocatedSpace	DECIMAL(15, 2)
		,TotalPages			DECIMAL(15, 2) -- @reservedpages
		,DataPages			DECIMAL(15, 2)
		,UsedPages			DECIMAL(15, 2)
		,IndexSize			DECIMAL(15, 2)
		,UnusedPages		DECIMAL(15, 2)
		,Pages				DECIMAL(15, 2)
		,logsize			DECIMAL(15, 2)
		,EstBackupSizeMB	DECIMAL(15, 2)
	)	

	DECLARE @Cmd			NVARCHAR(4000)
	DECLARE @dbname			SYSNAME
	DECLARE @Status			VARCHAR(12)
	DECLARE @TableName		NVARCHAR(128)

	SET @TAbleName = '#Spaceusedtable';

	DECLARE db_cur CURSOR FOR
		SELECT Name --,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master','model','msdb','tempdb','OSSDBADB')
			AND state_desc = 'ONLINE'
			AND is_read_only <> 1 --means database=in read only mode
			AND CHARINDEX('-', name) = 0 --AND-- no dashes in dbname
	--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
		ORDER BY NAME ASC;

	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO 
			@dbname;

	WHILE (@@FETCH_STATUS <> - 1)
		BEGIN
			SET @Cmd = 'USE [' + @dbname + '] ' + CHAR(13) + 'SELECT ' + '''' + @dbname + '''' + ',
				sum(a.total_pages)*8192/1024, -- @totalpages
				sum(a.data_pages)*8192/1024, -- @datapages
				sum(a.used_pages)*8192/1024, -- @usedpages
				((sum(a.used_pages) - sum(
					CASE
						-- XML-Index and FT-Index and semantic index internal tables are not 
						-- considered "data", but is part of "index_size"
						WHEN it.internal_type IN (202,204,207,211,212,213,214,215,216,221,222,236) THEN 0
						WHEN a.type <> 1 and p.index_id < 2 THEN a.used_pages
						WHEN p.index_id < 2 THEN a.data_pages
						ELSE 0
					END)) * 8192/1024) AS IndexSize,
				(sum(a.total_pages) - sum(a.used_pages))*8192/1024 AS UnusedPages,
				sum(
					CASE
						-- XML-Index and FT-Index and semantic index internal tables are not considered
						-- "data", but is part of "index_size"
						WHEN it.internal_type IN (202,204,207,211,212,213,214,215,216,221,222,236) THEN 0
						WHEN a.type <> 1 and p.index_id < 2 THEN a.used_pages
						WHEN p.index_id < 2 THEN a.data_pages
						ELSE 0
					END)*8192/1024 AS Pages -- @pages
			FROM ' + '[' + @dbname + '].sys.system_internals_partitions p
				JOIN ' + '[' + @dbname + '].sys.allocation_units a ON (p.partition_id = a.container_id)
				LEFT JOIN [' + @dbname + '].sys.internal_tables it ON (p.object_id = it.object_id);';

			PRINT '1 ' + @dbname + ' is ' + @Cmd;

			INSERT INTO #Spaceusedtable (
				DatabaseName
				,TotalPages
				,DataPages
				,UsedPages
				,IndexSize
				,UnusedPages
				,Pages
				) 
			EXEC sp_executesql @Cmd
				,N'@eStatus varchar(12)'
				,@eStatus = @Status;

	-- Update with the dataabse size
			SET @Cmd = ' UPDATE [' + @TAbleName + '] ' + ' SET DatabaseSize = ' + 
						'(SELECT sum((f.size))
							FROM [' + @dbname + '].sys.database_files f
							WHERE f.type = 0)
					WHERE DatabaseName = ' + '''' + @dbname + '''' + '; ';

			PRINT '2 ' + @dbname + ' is '  + @Cmd;

			EXEC sp_executesql @Cmd
					,N'@eStatus varchar(12)'
					,@eStatus = @Status;

	-- Update with the log size
			SET @Cmd = ' UPDATE [' + @TableName + '] ' + ' SET logsize = ' +
					'(SELECT sum((size))
							FROM [' + @dbname + '].sys.database_files
						WHERE type <> 0) 
					WHERE DatabaseName = ' + '''' + @dbname + '''' + '; ';

			PRINT '3 ' + @dbname + ' is ' + @Cmd;
	
			EXEC sp_executesql @Cmd
				,N'@eStatus varchar(12)'
				,@eStatus = @Status;

			FETCH NEXT FROM db_cur
				INTO @dbname;
		END

	CLOSE db_cur;

	DEALLOCATE db_cur;

	SELECT DatabaseName
			,CONVERT(DECIMAL(15,2),DatabaseSize *8192/1024/1024) AS DatabaseSizeMB
			,CONVERT(DECIMAL(15,2),logsize *8192/1024/1024) AS logsizeMB
			,CONVERT(DECIMAL(15,2),(DatabaseSize + logsize)*8192/1024/1024) AS TotalDatabaseSizeMB
			,CONVERT(DECIMAL(15,2),CASE
				WHEN (DatabaseSize ) >=( TotalPages / 1024)  THEN
					((DatabaseSize ) - (TotalPages/1024))
				ELSE 0
			END) AS UnallocatedSpaceMB
			,TotalPages  AS ReservedPageskB
			,Pages  AS PagesKB
			,IndexSize AS IndexSizeKB
			,UnusedPages AS UnusedPagesKB
			,((convert(DEC(15, 2), ((TotalPages - UnusedPages )) ))  / 1024 ) AS EstBackupSizeMB
		FROM #Spaceusedtable;

	DROP TABLE #Spaceusedtable;
END
GO
