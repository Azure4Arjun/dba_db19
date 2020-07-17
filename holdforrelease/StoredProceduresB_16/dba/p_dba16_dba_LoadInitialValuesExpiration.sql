SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_dba_LoadInitialValuesExpiration
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Load initial values in database expiration - called by crawler.
-- 
-- Date			Modified By			Changes
-- 09/14/2010   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 05/30/2012	Aron E. Tekulsky	execute a full backup of the new db.
-- 06/04/2012	Aron E. Tekulsky	add intelligence to determine if new db is mirror or not.
-- 06/05/2012	Aron E. Tekulsky	Change to pointing to new drive.
-- 06/05/2012	Aron E. Tekulsky	add automatic 90 day expiration to all new db.
-- 06/05/2012	Aron E. Tekulsky	get db expiration days from dba_db.
-- 06/05/2012	Aron E. Tekulsky	get backup location from db.
-- 06/26/2012	Aron E. Tekulsky	filter out items that are snapshots.
-- 04/08/2016	Aron E. Tekulsky	add registry read to get backup location.
--	08/11/2016	Aron E. Tekulsky	reset backup location to top of tree each time.
-- 06/17/2019   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_dba_LoadInitialValuesExpiration 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
 --   INSERT dba_db08.dbo.dba_database_expiration (
	--	name, db_dbid, db_cr_date, db_restore_date, db_status,db_owner,db_backup_db  )
	--SELECT d.name, d.database_id, d.create_date, d.create_date, 
	--		ISNULL(upper(substring(a.mirroring_role_desc,1,1)),'A') AS db_status,
	--		l.name, 1
	--	FROM sys.databases d
	--		LEFT OUTER JOIN sys.database_mirroring a ON (d.database_id = a.database_id)
	--		LEFT JOIN sys.syslogins l ON (l.sid = d.owner_sid)
	--WHERE d.name Not IN (SELECT name FROM dba_db08.dbo.dba_database_expiration)

	DECLARE @cmd					nvarchar(4000)
	DECLARE @create_date			datetime
	DECLARE @database_id			int
	DECLARE @db_status				char(1)
	DECLARE @dbo					nvarchar(128)
	DECLARE @db_backup_db			int
	DECLARE @db_expiration_days		int
	DECLARE @db_backup_location		nvarchar(2000)
	DECLARE @db_backup_location2	nvarchar(2000)
	DECLARE	@expiration_date		datetime
	DECLARE @name					nvarchar(128)


	--EXEC [dbo].[p_dba08_get_system_config_text_output] 'dba_backup_location', @db_backup_location OUTPUT

	print 'get registry values'
	EXEC [dba_db16].[dbo].[p_dba16_sys_GetRegistryValue] 1,@db_backup_location2 OUTPUT
	
	print 'next is '

	EXEC [dba_db16].[dbo].[p_dba16_utl_GetSystemConfigIntOutput] 'dba_db_expiration_days', @db_expiration_days OUTPUT

----PRINT 'db backup location is &&& ' 
--PRINT 'db backup location is &&& ' +  @db_backup_location
PRINT 'db backup location is &&& ' +  @db_backup_location2

	IF @db_expiration_days IS NULL OR @db_expiration_days = '' 
		SET @db_expiration_days = 90


	SET @db_backup_db = 1

	DECLARE db_cur CURSOR FOR
		SELECT d.name, d.database_id, d.create_date, 
			--ISNULL(upper(substring(a.mirroring_role_desc,1,1)),'A') AS db_status,
			CASE 
				WHEN d.[state] = 1 -- restoring so assume it is a mirror
						THEN 
							'M' 
				WHEN d.[state] = 0 -- online
						THEN 
							ISNULL(upper(substring(a.mirroring_role_desc,1,1)),'A') 
			END AS db_status,
			l.name
		FROM sys.databases d
			LEFT OUTER JOIN sys.database_mirroring a ON (d.database_id = a.database_id)
			LEFT JOIN sys.syslogins l ON (l.sid = d.owner_sid)
	WHERE --d.snapshot_isolation_state = 1 AND
						--d.source_database_id IS NOT NULL AND
						d.name Not IN (SELECT name FROM dba_db16.dbo.dba_database_expiration);

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
			@name, @database_id, @create_date, @db_status, @dbo;

	WHILE(@@fetch_status = 0)
		BEGIN

				SET @expiration_date = getdate() + @db_expiration_days -- expiration date is 90 days

				INSERT dba_db16.dbo.dba_database_expiration (
							name, db_dbid, db_cr_date, db_expiration_date, db_restore_date, db_status,db_owner,db_backup_db)
							Values (@name, @database_id, @create_date,@expiration_date,  @create_date, @db_status, @dbo, 1)

				IF @db_status NOT IN ('M','P')
					--EXEC p_dba_do_newdb_backup @name, '\\usnyqdba01\usnyd2edb03_db\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\BACKUP\'

					------PRINT '$$ making a new Diretory $$'

					-- this makes sure we start at thte top of the tree each time.
					SET @db_backup_location = @db_backup_location2;

					-- create subdir
					--SET @cmd = ' MKDIR ' + @db_backup_location + '\' + @name
					SET @cmd = ' MKDIR ' + '"' + @db_backup_location + '\' + @name + '"' ;

					PRINT @cmd

					EXEC p_dba16_exe_ExecuteSqlCmdShell @cmd

					SET @db_backup_location = @db_backup_location + '\' + @name + '\'

					------print @name+ ' dblocation is **' + @db_backup_location


					EXEC p_dba16_mnt_DoNewdbBackup @name, @db_backup_location
					
				FETCH NEXT FROM db_cur INTO
						@name, @database_id, @create_date, @db_status, @dbo;

		END

		CLOSE db_cur;

		DEALLOCATE db_cur;

 --   INSERT dba_db.dbo.dba_database_expiration (
	--	name, db_dbid, db_cr_date, db_restore_date, db_status,db_owner,db_backup_db  )
	--SELECT d.name, d.database_id, d.create_date, d.create_date, 
	--		ISNULL(upper(substring(a.mirroring_role_desc,1,1)),'A') AS db_status,
	--		l.name, 1
	--	FROM sys.databases d
	--		LEFT OUTER JOIN sys.database_mirroring a ON (d.database_id = a.database_id)
	--		LEFT JOIN sys.syslogins l ON (l.sid = d.owner_sid)
	--WHERE d.name Not IN (SELECT name FROM dba_db.dbo.dba_database_expiration)


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_dba_LoadInitialValuesExpiration TO [db_proc_exec] AS [dbo]
GO
