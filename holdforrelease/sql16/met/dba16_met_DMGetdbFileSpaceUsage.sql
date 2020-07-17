SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_DMGetdbFileSpaceUsage
--
--
-- Calls:		None
--
-- Description:	Get file space usage for database.
-- 
-- Date			Modified By			Changes
-- 09/14/2018   Aron E. Tekulsky    Initial Coding.
-- 05/09/2019   Aron E. Tekulsky    Update to Version 140.
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

	DECLARE @Cmd NVARCHAR(4000)
	DECLARE @dbid SMALLINT
	DECLARE @name VARCHAR(50)

	DECLARE db_cur CURSOR
		FOR
			SELECT name,database_id
				FROM sys.databases
			WHERE STATE = 0
				AND database_id > 4
				AND name <> 'dba_db08';

	--AND name = 'SSISDB'; -- on-line
	-- open th cursor
	OPEN db_cur;

	-- fetch the initial row
	FETCH NEXT
		FROM db_cur
			INTO @name,@dbid;

	WHILE (@@fetch_status = 0)
		BEGIN
			SET @Cmd = 'USE [' + @name + ']' + CHAR(13)
			SET @Cmd = @Cmd + 'SELECT ' + '''' + @name + '''' + ' AS DBName, (SUM(unallocated_extent_page_count)/128) AS [Free space (MB)],
							SUM(internal_object_reserved_page_count)*8 AS [Internal objects (KB)],
							SUM(user_object_reserved_page_count)*8 AS [Userobjects (KB)],
							SUM(version_store_reserved_page_count)*8 AS [Version store (KB)]
						FROM sys.dm_db_file_space_usage;';

			PRINT @Cmd;

			EXEC (@Cmd);

	--database_id '2' represents tempdb
	------WHERE database_id = 2;
	-- fetch the initial row
			FETCH NEXT
				FROM db_cur
					INTO @name,@dbid;
		END

	CLOSE db_cur;

	DEALLOCATE db_cur;

END
GO
