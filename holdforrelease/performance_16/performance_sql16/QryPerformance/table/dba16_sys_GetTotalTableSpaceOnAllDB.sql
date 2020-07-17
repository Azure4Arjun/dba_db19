SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetTotalTableSpaceOnAllDB
--
--
-- Calls:		None
--
-- Description:	check the space used by each table o all databases on the server. 
--				For compression extimation.
--
-- https://codingsight.com/overview-of-data-compression-in-sql-server/
--
-- Date			Modified By			Changes
-- 12/06/2018	Aron E. Tekulsky	Initial Coding.
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/09/2019	Aron E. Tekulsky	Add Unused pages, Unused space, and fix decimals on mb.
--									Add load for all. Add detial/summary flag.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @Cmd		nvarchar(4000)
	DECLARE @DetailFlag	int

	DECLARE @TotalTableSpace TABLE (
		DBName			nvarchar(128),
		TableName		nvarchar(128),
		SchemaName		nvarchar(128),
		IndexName		nvarchar(128),
		IndexId			int,
		RowCounts		bigint,
		TotalPages		bigint,
		UsedPages		bigint,
		UnusedPages		bigint,
		DataPages		bigint,
		TotalSpaceKB	decimal(20,2),
		TotalSpaceMB	decimal(20,2),
		UsedSpaceKB		bigint,
		UsedSpaceMB		decimal(20,2),
		UnusedSpaceKB	bigint,
		UnusedSpaceMB	decimal(20,2),
		DataSpaceKB		bigint,
		DataSpaceMB		decimal(20,2)
		)

		SET @DetailFlag = 0 -- 0 Detail, 1 summary.

	-- Declare the dbname variable.
	DECLARE @DBName		nvarchar(128)

	-- Declare the cursor.
	DECLARE db_cur CURSOR FOR
		SELECT Name--,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','ReportServer','ReportServerTempDB','dba_db16','SSISDB')
			AND state_desc = 'ONLINE'
			------AND is_read_only <> 1 --means database=in read only mode
			AND CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
			--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
		ORDER BY NAME ASC;
						
	-- Open the cursor.
	OPEN db_cur;

	-- Do the first fetch of the cursor.
	FETCH NEXT FROM db_cur INTO
			@DBName;

	-- Set up the loop.
	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
		--  place Code here --
			SET @Cmd = ' USE [' + @dbname + '] ' +
				'
				SELECT ' + '''' +  @dbname + '''' + ', t.NAME AS TableName
						,s.name AS SchemaName
						,i.name AS indexName
						,i.index_id 
						,sum(p.rows) AS RowCounts
						,sum(a.total_pages) AS TotalPages
						,sum(a.used_pages) AS UsedPages
						,sum(a.total_pages) - sum(a.used_pages)  AS UnusedPages
						,sum(a.data_pages) AS DataPages
						,(CONVERT(decimal(20,2),sum(a.total_pages) * 8))  AS TotalSpaceKB
						,CONVERT(decimal(20,2),((CONVERT(decimal(20,2),(sum(a.total_pages) * 8)) / 1024.00))) AS TotalSpaceMB
						,(sum(a.used_pages) * 8) AS UsedSpaceKB
						,CONVERT(decimal(20,2),((CONVERT(decimal(20,2),(sum(a.used_pages) * 8)) / 1024))) AS UsedSpaceMB
						,(sum(a.total_pages) * 8) - (sum(a.used_pages) * 8) AS UnusedSpaceKB
						,CONVERT(decimal(20,2),((CONVERT(decimal(20,2),(sum(a.total_pages) * 8)) - CONVERT(decimal(20,2),(sum(a.used_pages) * 8))) / 1024)) AS UnusedSpaceMB
						,(sum(a.data_pages) * 8) AS DataSpaceKB
						,CONVERT(decimal(20,2),((CONVERT(decimal(20,2),(sum(a.data_pages) * 8)) / 1024))) AS DataSpaceMB
					FROM sys.tables t
						INNER JOIN sys.indexes i ON (t.OBJECT_ID = i.object_id)
						INNER JOIN sys.partitions p ON (i.object_id = p.OBJECT_ID)
													AND (i.index_id = p.index_id)
						INNER JOIN sys.allocation_units a ON (p.partition_id = a.container_id)
						INNER JOIN sys.schemas s ON (s.schema_id = t.schema_id )
				WHERE t.NAME NOT LIKE ' + '''' + 'dt%' + '''' + 
						' AND i.OBJECT_ID > 255
						AND i.index_id <= 1
				GROUP BY t.NAME
					,s.name
					,i.object_id
					,i.index_id
					,i.name
				ORDER BY TableName ASC, i.index_id ASC;'
	----ORDER BY TotalSpaceMB DESC;

			PRINT @Cmd;

			INSERT INTO @TotalTableSpace (
				DBName,	TableName, SchemaName, indexName, IndexId, RowCounts, TotalPages, UsedPages, UnusedPages, 
				DataPages, TotalSpaceKB, TotalSpaceMB, UsedSpaceKB, UsedSpaceMB, UnusedSpaceKB, 
				UnusedSpaceMB, DataSpaceKB, DataSpaceMB)
			EXEC (@Cmd);
					
			FETCH NEXT FROM db_cur INTO
				@dbname;
		END

	-- Close the cursor.
	CLOSE db_cur;

	-- Deallocate the cursor.
	DEALLOCATE db_cur;

	IF @DetailFlag = 0 -- Details
		BEGIN
			SELECT DBName,	TableName, SchemaName, indexName, RowCounts, TotalPages, UsedPages, UnusedPages, 
					DataPages, TotalSpaceKB, TotalSpaceMB, UsedSpaceKB, UsedSpaceMB, UnusedSpaceKB, 
					UnusedSpaceMB, DataSpaceKB, DataSpaceMB
				FROM @TotalTableSpace
			ORDER BY DBName ASC, TableName ASC, IndexId ASC;
		END

	ELSE -- summary

		BEGIN
			SELECT DBName,	SUM(RowCounts) AS TotalRowCounts, SUM(TotalPages) AS TotalPages, SUM(UsedPages) AS TotalUsedPages, SUM(UnusedPages) TotalUnusedPages, 
					SUM(DataPages) AS TotalDataPages, SUM(TotalSpaceKB) AS TotalSpaceKB, SUM(TotalSpaceMB) AS TotalSpaceMB, SUM(UsedSpaceKB) AS TotalUsedSpaceKB, 
					SUM(UsedSpaceMB)AS TotalUsedSpaceMB, SUM(UnusedSpaceKB) AS TotalUnusedSpaceKB, 
					SUM(UnusedSpaceMB) AS TotalUnusedSpaceMB, SUM(DataSpaceKB) AS TotalDataSpaceKB, SUM(DataSpaceMB) AS TotalDataSpaceMB
				FROM @TotalTableSpace
			GROUP BY DBName
			ORDER BY DBName ASC;
		END

END
GO
