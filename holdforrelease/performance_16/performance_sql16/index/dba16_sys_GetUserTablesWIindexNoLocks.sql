SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetUserTablesWIindexNoLocks
--
--
-- Calls:		None
--
-- Description:	Get a listing of indexes on tables with no lock.
-- 
-- Date			Modified By			Changes
-- 11/12/2017   Aron E. Tekulsky    Initial Coding.
-- 11/05/2017   Aron E. Tekulsky    Update to Version 140.
-- 10/04/2019	Aron E. Tekulsky	Update to load all db's into table and output in 1 
--									report.
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

	DECLARE @command				nvarchar(4000)
    DECLARE @CurrentDatabase		nvarchar(1000)
	DECLARE @dbStatus				nvarchar(128)

	DECLARE @IndexedTables AS TABLE(
			current_db				nvarchar(128),
			ObjectName				nvarchar(128),
			TypeDesc				nvarchar(60),
			ObjectId				int,
			ColumnName				nvarchar(128),
			IndexName				nvarchar(128),
			AllowRowLocks			bit,
			AllowPageLocks			bit
	)


	DECLARE db_cur CURSOR FOR
		SELECT Name,state_desc 
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb', 'Analysis Services Repository')
			AND state_desc = 'ONLINE'
			--AND name in ('iie_enterprise')--'iie_enterprise','iiedb1')
		--AND    is_read_only <> 1 --means database=in read only mode
		ORDER BY name ASC;
		
	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO @CurrentDatabase, @dbStatus;
	
	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
	--JOIN sys.index_columns ic ON (ic.object_id = o.object_id)

			SET @command = 'USE [' + @CurrentDatabase + '] ' +
			' SELECT ' + '''' + @CurrentDatabase + '''' + ' AS current_db, o.name,o.type_desc, o.object_id, c.name, i.name, i.allow_row_locks, i.allow_page_locks
					FROM ' + @CurrentDatabase + '.sys.objects o
					JOIN ' + @CurrentDatabase + '.sys.columns c ON (c.object_id =  o.object_id)
					JOIN ' + @CurrentDatabase + '.sys.indexes i ON (i.object_id = o.object_id)
				WHERE o.type_desc = ''user_table'' AND
					((i.allow_row_locks = 0 OR i.allow_row_locks = NULL) OR
					(i.allow_page_locks = 0 OR i.allow_page_locks = NULL))'
			
			PRINT @command;

			INSERT @IndexedTables (
					current_db, ObjectName, TypeDesc, ObjectId, ColumnName, IndexName, AllowRowLocks, AllowPageLocks)
			EXEC (@command);
			
	
			FETCH NEXT FROM db_cur
				INTO @CurrentDatabase, @dbStatus;

		END

	CLOSE db_cur;

	DEALLOCATE db_cur;

	SELECT current_db, ObjectName, ObjectId, TypeDesc, ColumnName, IndexName, AllowRowLocks, AllowPageLocks
		FROM @IndexedTables;

--group by type_desc
END
GO
