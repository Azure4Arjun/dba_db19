SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetAllDBBackupSizesWGrowth
--
-- Arguments:	@servername	nvarchar(128)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get all database sizes to look for size changes.
-- 
-- Date			Modified By			Changes
-- 09/28/2011   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/19/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetAllDBBackupSizesWGrowth 
	-- Add the parameters for the stored procedure here
	@servername	nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @dbname			sysname
	
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
			INSERT INTO dba_backsetsize
				SELECT	@servername, @dbname as db_name, b.backup_start_date, a.backup_set_id, convert(numeric(20,0),a.file_size /1048576) as file_sizeMB,
						a.logical_name, a.[filegroup_name], a.physical_name, b.type,
						(
							SELECT CONVERT(numeric(5,3),(((a.file_size * 100.00)/i1.file_size)-100))
								FROM msdb.dbo.backupfile i1
							WHERE i1.backup_set_id = 
								(
									SELECT MAX(i2.backup_set_id) 
										FROM msdb.dbo.backupfile i2 JOIN msdb.dbo.backupset i3 ON i2.backup_set_id = i3.backup_set_id
									WHERE i2.backup_set_id < a.backup_set_id AND 
											i2.file_type='D' AND
											i3.database_name = @dbname AND
											i2.logical_name = a.logical_name AND
											i2.logical_name = i1.logical_name AND
											i3.type = 'D') AND
								i1.file_type = 'D') AS GrowthPct,
						(
							SELECT	convert(numeric(20,0),((a.file_size - i1.file_size)/1048576))
								FROM	msdb.dbo.backupfile i1
							WHERE 	i1.backup_set_id = 
									(
										SELECT	MAX(i2.backup_set_id) 
											FROM	msdb.dbo.backupfile i2 JOIN msdb.dbo.backupset i3 ON i2.backup_set_id = i3.backup_set_id
										WHERE	i2.backup_set_id < a.backup_set_id AND 
												i2.file_type='D' AND
												i3.database_name = @dbname AND
												i2.logical_name = a.logical_name AND
												i2.logical_name = i1.logical_name AND
												i3.type = 'D') AND
										i1.file_type = 'D') AS GrowthMB
						FROM	msdb.dbo.backupfile a JOIN msdb.dbo.backupset b ON a.backup_set_id = b.backup_set_id
				WHERE	b.database_name = @dbname AND
						a.file_type = 'D' AND
						b.type = 'D';
-- get 1 line for max file size and its backup set id.

-- fetch the next db
			FETCH NEXT FROM db_cur
				INTO @dbname;

		END

	SELECT *
		FROM dba_backsetsize
	ORDER BY t_server_name, t_dbname ASC, t_logical_name ASC, t_backup_start_date ASC;


	CLOSE db_cur;
	DEALLOCATE db_cur;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetAllDBBackupSizesWGrowth TO [db_proc_exec] AS [dbo]
GO
