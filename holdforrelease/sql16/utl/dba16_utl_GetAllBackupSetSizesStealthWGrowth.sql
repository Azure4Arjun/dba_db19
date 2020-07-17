SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_GetAllBackupSetSizesStealthWGrowth
--
--
-- Calls:		None
--
-- Description:	Get a llisting of all of the backup sets on other servers with growth.
-- 
-- Date			Modified By			Changes
-- 09/28/2011   Aron E. Tekulsky    Initial Coding.
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

		
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @cmd		nvarchar(4000)
	DECLARE @cur		nvarchar(4000)
	DECLARE @dbname		sysname
	DECLARE @servername	nvarchar(128)
	
	--SET @servername = '37wsw7d008\sql2008_R2'
	SET @servername = 'usnypdba05'
	
	
	SET @cur = '
	-- declar the cursor
	DECLARE db_cur CURSOR FOR
		SELECT name
		FROM ' + @servername + '.' + 'master.sys.databases
		WHERE state = 0; '
		
	print @cur
	
	EXEC (@cur);
		
		-- on-line
	-- open the cursor
	OPEN db_cur;
	
	-- fetch the first row
	FETCH NEXT FROM db_cur
		INTO @dbname;		
		
--		print @cmd
		
	-- loop and get the rest
	WHILE (@@fetch_status = 0)
		BEGIN
			SET @cmd = '	INSERT INTO dba_db.dbo.dba_backsetsize
				SELECT	' + '''' + @servername + '''' + ', ' + '''' + @dbname + '''' + ' as db_name, b.backup_start_date, a.backup_set_id, convert(numeric(20,0),a.file_size /1048576) as file_sizeMB, a.logical_name, a.[filegroup_name], a.physical_name, type,
				(
					SELECT	CONVERT(numeric(5,3),(((a.file_size * 100.00)/i1.file_size)-100))
						FROM ' + @servername + '.msdb.dbo.backupfile i1
					WHERE i1.backup_set_id = 
						(
							SELECT	MAX(i2.backup_set_id) 
								FROM ' + @servername + '.msdb.dbo.backupfile i2 JOIN ' + @servername + '.msdb.dbo.backupset i3 ON i2.backup_set_id = i3.backup_set_id
							WHERE i2.backup_set_id < a.backup_set_id AND 
								i2.file_type=' + '''' + 'D' + '''' + 'AND
								i3.database_name = ' + '''' + @dbname + '''' + ' AND
								i2.logical_name = a.logical_name AND
								i2.logical_name = i1.logical_name AND
								i3.type = ' + '''' + 'D' + '''' + '
						) AND
					i1.file_type = ' + '''' + 'D' + '''' + '
				) AS GrowthPct,
				(
					SELECT	convert(numeric(20,0),((a.file_size - i1.file_size)/1048576))
						FROM ' + @servername + '.msdb.dbo.backupfile i1
					WHERE i1.backup_set_id = 
						(
							SELECT	MAX(i2.backup_set_id) 
								FROM ' + @servername + '.msdb.dbo.backupfile i2 JOIN ' + @servername + '.msdb.dbo.backupset i3 ON i2.backup_set_id = i3.backup_set_id
							WHERE	i2.backup_set_id < a.backup_set_id AND 
								i2.file_type=' + '''' + 'D' + '''' + ' AND
								i3.database_name = ' + '''' + @dbname + '''' + ' AND
								i2.logical_name = a.logical_name AND
								i2.logical_name = i1.logical_name AND
								i3.type = ' + '''' + 'D' + '''' + '
						) AND
					i1.file_type = ' + '''' + 'D' + '''' + '
				) AS GrowthMB
					FROM ' + @servername + '.msdb.dbo.backupfile a 
						JOIN ' + @servername  + '.msdb.dbo.backupset b ON a.backup_set_id = b.backup_set_id
				WHERE b.database_name = ' + '''' + @dbname + '''' + ' AND
					a.file_type = ' + '''' + 'D'+ '''' + ' AND
					b.type = ' + '''' + 'D' + '''' + ';'

			print @cmd

	
			EXEC (@cmd);
	
-- get 1 line for max file size and its backup set id.

-- fetch the next db
			FETCH NEXT FROM db_cur
				INTO @dbname;
--PRINT @@fetch_status

			print @dbname

		END

	SELECT *
		FROM dba_db.dbo.dba_backsetsize
	ORDER BY t_server_name, t_dbname ASC, t_logical_name ASC, t_backup_start_date ASC


	CLOSE db_cur;
	DEALLOCATE db_cur;


END
GO
