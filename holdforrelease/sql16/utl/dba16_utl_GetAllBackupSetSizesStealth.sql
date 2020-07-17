SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_GetAllBackupSetSizesStealth
--
--
-- Calls:		None
--
-- Description:	Get a listing of all of the backup set sizes on othere servers.
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
	
	DECLARE @dbname			sysname
	DECLARE @servername	nvarchar(128)
	
	--SET @servername = '37wsw7d008\sql2008_R2'
	SET @servername = 'usnypdba03'
	
    -- Insert statements for procedure here
	--CREATE TABLE #backsetsize
	--	(t_server_name		nvarchar(128)	null,
	--	t_dbname			sysname			not null,
	--	t_backup_start_date	datetime		null,
	--	t_backup_set_id		int				not null,
	--	t_file_size			numeric(20,0)	null,
	--	t_logical_name		nvarchar(128)	null,
	--	t_filegroup_name	nvarchar(128)	null,
	--	t_physical_name		nvarchar(260)	null,
	--	t_type				char(1)			null)
	
	--SET @servername = 'test'
	
	DECLARE @cur	nvarchar(4000)
	DECLARE @cmd	nvarchar(4000)
	
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
		
--	SET @cmd = '	INSERT INTO dba_db.dbo.dba_backsetsize
--	SELECT	' + '''' + @servername + '''' + ', ' + '''' + @dbname + '''' + ' as db_name, b.backup_start_date, a.backup_set_id, a.file_size /1048576 as file_size, a.logical_name, a.[filegroup_name], a.physical_name, type,
--		null, null
--		FROM ' + @servername + '.msdb.dbo.backupfile a 
--			JOIN ' + @servername  + '.msdb.dbo.backupset b ON a.backup_set_id = b.backup_set_id
--	WHERE b.database_name = ' + '''' + @dbname + '''' + ' AND
--		a.file_type = ' + '''' + 'D'+ '''' + ' AND
--		b.type = ' + '''' + 'D' + '''' + ';'
		
--		print @cmd
		
	-- loop and get the rest
	WHILE (@@fetch_status = 0)
		BEGIN
			SET @cmd = '	INSERT INTO dba_db.dbo.dba_backsetsize
				SELECT	' + '''' + @servername + '''' + ', ' + '''' + @dbname + '''' + ' as db_name, b.backup_start_date, a.backup_set_id, a.file_size /1048576 as file_size, a.logical_name, a.[filegroup_name], a.physical_name, type,
					null, null
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

--PRINT @@fetch_status


	SELECT *
		FROM dba_db.dbo.dba_backsetsize
	ORDER BY t_server_name, t_dbname ASC, t_logical_name ASC, t_backup_start_date ASC;


	CLOSE db_cur;
	DEALLOCATE db_cur;

--DROP TABLE #backsetsize

	--INSERT  dba_db05.dbo.dba_backsetsize
	--(t_server_name,
	--	t_dbname,
	--	t_backup_start_date, 
	--	t_backup_set_id,
	--	t_file_size, 
	--	t_logical_name, 
	--	t_filegroup_name, 
	--	t_physical_name, 
	--	t_type)
	--SELECT	'37wsw7d008\sql2008_R2', 'dba_db' as db_name, b.backup_start_date, a.backup_set_id, a.file_size /1048576 as file_size, a.logical_name, a.[filegroup_name], a.physical_name, type--,
	--	FROM msdb.dbo.backupfile a 
	--		JOIN msdb.dbo.backupset b ON a.backup_set_id = b.backup_set_id
	--WHERE lower(b.database_name) = 'dba_db' AND
	--	a.file_type = 'D' AND
	--	b.type = 'D';


END
GO
