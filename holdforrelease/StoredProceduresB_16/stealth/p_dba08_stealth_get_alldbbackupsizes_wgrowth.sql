USE [dba_db08]
GO

/****** Object:  StoredProcedure [dbo].[p_dba08_stealth_get_alldbbackupsizes_wgrowth]    Script Date: 7/13/2016 1:42:25 PM ******/
DROP PROCEDURE [dbo].[p_dba08_stealth_get_alldbbackupsizes_wgrowth]
GO

/****** Object:  StoredProcedure [dbo].[p_dba08_stealth_get_alldbbackupsizes_wgrowth]    Script Date: 7/13/2016 1:42:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- ================================================================================
-- p_dba08_stealth_get_alldbbackupsizes_wgrowth
--
-- Arguments:	@servername
--				None
--
-- Called BY:	None
--
-- Description:	Get all database sizes to look for size changes.
-- 
-- Date				Modified By			Changes
-- 09/28/2011   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 07/13/2016	Aron E. Tekulsky	change server_name to 1000 and t_growthpct 
--									to 20,3.
-- ===============================================================================
--	Copyright©2009 - 2012 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================
CREATE PROCEDURE [dbo].[p_dba08_stealth_get_alldbbackupsizes_wgrowth] 
	-- Add the parameters for the stored procedure here
	@servername nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--DECLARE @servername	nvarchar(128)
	DECLARE @dbname	sysname
	DECLARE @cur	nvarchar(4000)
	DECLARE @cmd	nvarchar(4000)
	
	--DECLARE @dba_backsetsize TABLE (
	--	t_server_name		nvarchar(128) NULL,
	--	t_dbname			sysname NOT NULL,
	--	t_backup_start_date datetime NULL,
	--	t_backup_set_id		int NOT NULL,
	--	t_file_sizeMB		numeric(20,0) NULL,
	--	t_logical_name		nvarchar(128) NULL,
	--	t_filegroup_name	nvarchar(128) NULL,
	--	t_physical_name		nvarchar(260) NULL,
	--	t_type				char(1) NULL,
	--	t_GrowthPct			numeric(5,3) NULL,
	--	t_GrowthMB			numeric(20,0) NULL)
	DECLARE @dba_backsetsize TABLE (
		t_server_name		nvarchar(1000),
		t_dbname			sysname,
		t_backup_start_date datetime,
		t_backup_set_id		int,
		t_file_sizeMB		numeric(20,0),
		t_logical_name		nvarchar(128),
		t_filegroup_name	nvarchar(128),
		t_physical_name		nvarchar(260),
		t_type				char(1),
		t_GrowthPct			numeric(20,3),
		t_GrowthMB			numeric(20,0))
	
	IF @servername IS NULL OR @servername = ''
		SET @servername = @@servername 

	SET @cur = '
	-- declar the cursor
	DECLARE db_cur CURSOR FOR
		SELECT name
		FROM [' + @servername + '].' + 'master.sys.databases
		WHERE state = 0; '
		
	--print @cur
	
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
		SET @cmd = '	
		SELECT	' + '''' + @servername + '''' + ', ' + '''' + @dbname + '''' + ' as db_name, b.backup_start_date, a.backup_set_id, convert(numeric(20,0),a.file_size /1048576) as file_sizeMB, a.logical_name, a.[filegroup_name], a.physical_name, type,
			(
			SELECT	CONVERT(numeric(20,3),(((a.file_size * 100.00)/i1.file_size)-100))
				FROM [' + @servername + '].msdb.dbo.backupfile i1
				WHERE i1.backup_set_id = 
						(
							SELECT	MAX(i2.backup_set_id) 
							FROM [' + @servername + '].msdb.dbo.backupfile i2 JOIN [' + @servername + '].msdb.dbo.backupset i3
								ON i2.backup_set_id = i3.backup_set_id
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
				FROM [' + @servername + '].msdb.dbo.backupfile i1
				WHERE i1.backup_set_id = 
						(
							SELECT	MAX(i2.backup_set_id) 
							FROM [' + @servername + '].msdb.dbo.backupfile i2 JOIN [' + @servername + '].msdb.dbo.backupset i3
								ON i2.backup_set_id = i3.backup_set_id
							WHERE	i2.backup_set_id < a.backup_set_id AND 
								i2.file_type=' + '''' + 'D' + '''' + ' AND
								i3.database_name = ' + '''' + @dbname + '''' + ' AND
								i2.logical_name = a.logical_name AND
								i2.logical_name = i1.logical_name AND
								i3.type = ' + '''' + 'D' + '''' + '
						) AND
				i1.file_type = ' + '''' + 'D' + '''' + '
		) AS GrowthMB
			FROM [' + @servername + '].msdb.dbo.backupfile a 
				JOIN [' + @servername  + '].msdb.dbo.backupset b ON a.backup_set_id = b.backup_set_id
		WHERE b.database_name = ' + '''' + @dbname + '''' + ' AND
			a.file_type = ' + '''' + 'D'+ '''' + ' AND
			b.type = ' + '''' + 'D' + '''' + ';'



		print @cmd

	INSERT INTO @dba_backsetsize
	EXEC (@cmd);
	
-- get 1 line for max file size and its backup set id.

-- fetch the next db
	FETCH NEXT FROM db_cur
		INTO @dbname;
--PRINT @@fetch_status

--print @dbname

END

--SET @cmd = 'SELECT *
--FROM ' + @servername + '.dba_db.dbo.dba_backsetsize
--WHERE t_server_name = ' + '''' + @servername + '''' +
--'order by t_server_name, t_dbname asc, t_logical_name asc, t_backup_start_date asc'

--SET @cmd = 'SELECT *
--FROM '  + 'dba_db08.dbo.dba_backsetsize
--WHERE t_server_name = ' + '''' + @servername + '''' +
--'order by t_server_name asc, t_dbname asc, t_logical_name asc, t_backup_start_date desc'

SELECT t_server_name, t_dbname, t_backup_start_date, t_backup_set_id, t_file_sizeMB, 
		t_logical_name, t_filegroup_name, t_physical_name, t_type, t_GrowthPct, t_GrowthMB
	FROM @dba_backsetsize
WHERE t_server_name =  @servername 
ORDER BY t_server_name asc, t_dbname asc, t_logical_name asc, t_backup_start_date DESC

--EXEC (@cmd);


CLOSE db_cur;
DEALLOCATE db_cur;
END













GO

GRANT EXECUTE ON [dbo].[p_dba08_stealth_get_alldbbackupsizes_wgrowth] TO [db_proc_exec] AS [dbo]
GO


