SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_DMGetSQLRowCountsAllDB
--
--
-- Calls:		None
--
-- Description:	Get a list of tables and their row counts dynamically for all db.
-- 
-- Date			Modified By			Changes
-- 12/19/2017   Aron E. Tekulsky    Initial Coding.
-- 12/25/2017   Aron E. Tekulsky    Update to Version 140.
-- 09/14/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @CMD				nvarchar(max)
	DECLARE @DBName				nvarchar(128)


	-- My snipet sql code goes here --
	-- Declare the dbname variable.
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

	-- Initialize.
	DECLARE @rc_Counts TABLE (
			ServerName					nvarchar(128),
			DBName						nvarchar(128),
			ObjectName					nvarchar(128),
			SchemaName					nvarchar(128),
			row_count					bigint,
			UsedPageCount				bigint,
			ReservedPageCount			bigint,
			UsedTableSizeMbytes			bigint, --decimal(20,3),
			ReservedTableSizeMBytes		bigint, --decimal(20,3),
			InRowDataPageCount			bigint,
			InRowUsedPageCount			bigint,
			InRowReservedPageCount		bigint,
			is_replicated				bit,
			lock_escalation_desc		nvarchar(60),
			ModifiedDate				datetime)

	
	-- Open the cursor.
		OPEN db_cur;

	-- Do the first fetch of the cursor.
		FETCH NEXT FROM db_cur INTO
				@DBName;

	-- Set up the loop.
		WHILE (@@FETCH_STATUS <> -1)
			BEGIN
		--  place Code here --
				SET @Cmd = 'SELECT @@ServerName AS ServerName, ' + '''' + @Dbname + '''' + ' AS DBName, c.name AS SchemaName , t.name AS TableName,s.row_count AS RowCnt,
						s.used_page_count AS UsedPageCount, s.reserved_page_count AS ReservedPageCount ,
						(s.used_page_count*8)/1024 AS UsedTableSizeMbytes, (s.reserved_page_count*8)/ 1024 AS ReservedTableSizeMBytes,
						s.in_row_data_page_count AS InRowDataPageCount , s.in_row_used_page_count AS InRowUsedPageCount,
						s.in_row_reserved_page_count AS InRowReservedPageCount,
						t.is_replicated, t.lock_escalation_desc, GETDATE() 
					FROM [' + @dbname +  '].[sys].[tables] t
						INNER JOIN [' + @dbname + '].[sys].[schemas] c ON (c.schema_id = t.schema_id )
						INNER JOIN [' + @dbname + '].[sys].[dm_db_partition_stats] s ON	(s.object_id = t.object_id ) AND
																		(s.index_id < 2)
					ORDER BY c.name ASC, t.name ASC;';
								PRINT @Dbname;
								PRINT @Cmd;
					INSERT INTO @rc_Counts (
							ServerName,
							DBName,
							SchemaName, 
							ObjectName, 
							row_count, 
							UsedPageCount, 
							ReservedPageCount, 
							UsedTableSizeMbytes, 
							ReservedTableSizeMBytes, 
							InRowDataPageCount, 
							InRowUsedPageCount, 
							InRowReservedPageCount, 
							is_replicated, 
							lock_escalation_desc,
							ModifiedDate)
					EXEC(@Cmd);

				FETCH NEXT FROM db_cur INTO
					@dbname;
			END
	-- Close the cursor.
		CLOSE db_cur;
	-- Deallocate the cursor.
		DEALLOCATE db_cur;
				
		SELECT ServerName, DBName, SchemaName, ObjectName, row_count, UsedPageCount, 
				ReservedPageCount, UsedTableSizeMbytes, ReservedTableSizeMBytes, 
				InRowDataPageCount, InRowUsedPageCount, InRowReservedPageCount, 
				is_replicated, lock_escalation_desc, ModifiedDate
			FROM @rc_Counts
		ORDER BY SUBSTRING(CONVERT(varchar(20),ModifiedDate), 1, 10) DESC, ServerName ASC, DBName ASC, SchemaName ASC, ObjectName ASC;


END
GO
