SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_GetAllBackupSetSizes
--
--
-- Calls:		None
--
-- Description:	Get a listof all of the backups sets and their sizes.
-- 
-- Date			Modified By			Changes
-- 09/28/2011   Aron E. Tekulsky    Initial Coding.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @dbname		sysname -- temp
	DECLARE @servername	nvarchar(128)
	
	CREATE TABLE #backsetsize
		(t_server_name		nvarchar(128)	null,
		t_dbname			sysname			not null,
		t_backup_start_date	datetime		null,
		t_backup_set_id		int				not null,
		t_file_size			numeric(20,0)	null,
		t_logical_name		nvarchar(128)	null,
		t_filegroup_name	nvarchar(128)	null,
		t_physical_name		nvarchar(260)	null,
		t_type				char(1)			null)
	
	SET @servername = 'test'
	
	-- declar the cursor
	DECLARE db_cur CURSOR FOR
		SELECT name
		FROM sys.databases
		WHERE state = 0; -- on-line
	-- open the cursor
	OPEN db_cur;
	
	-- fetch the first row
	FETCH NEXT FROM db_cur
		INTO @dbname;
		
	-- loop and get the rest
	--WHILE (@@fetch_status <> -1)
	WHILE (@@fetch_status = 0)
		BEGIN
	--SET @dbname = COALESCE('eautopay', DB_NAME()) -- temp

			INSERT INTO #backsetsize
				SELECT	@servername, @dbname as db_name, b.backup_start_date, a.backup_set_id, a.file_size /1048576 as file_size, a.logical_name, a.[filegroup_name], a.physical_name, type--,
		--(
		--	SELECT	CONVERT(numeric(5,2),((a.file_size * 100.00)/i1.file_size)-100)
		--	FROM	msdb.dbo.backupfile i1
		--	WHERE 	i1.backup_set_id = 
		--				(
		--					SELECT	MAX(i2.backup_set_id) 
		--					FROM	msdb.dbo.backupfile i2 JOIN msdb.dbo.backupset i3
		--						ON i2.backup_set_id = i3.backup_set_id
		--					WHERE	i2.backup_set_id < a.backup_set_id AND 
		--						i2.file_type='D' AND
		--						i3.database_name = @dbname AND
		--						i2.logical_name = a.logical_name AND
		--						i2.logical_name = i1.logical_name AND
		--						i3.type = 'D'
		--				) AND
		--		i1.file_type = 'D' 
		--) AS Growth
				FROM	msdb.dbo.backupfile a JOIN msdb.dbo.backupset b ON a.backup_set_id = b.backup_set_id
			WHERE b.database_name = @dbname AND
				a.file_type = 'D' AND
				b.type = 'D';
-- get 1 line for max file size and its backup set id.

-- fetch the next db
			FETCH NEXT FROM db_cur
				INTO @dbname;

		END

	SELECT *
		FROM #backsetsize
	ORDER BY t_server_name, t_dbname ASC, t_logical_name ASC, t_backup_start_date ASC;


	CLOSE db_cur;
	DEALLOCATE db_cur;
	DROP TABLE #backsetsize;

END
GO
