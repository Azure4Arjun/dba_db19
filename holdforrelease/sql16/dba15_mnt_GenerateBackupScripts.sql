SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba15_mnt_GenerateBackupScripts
--
--
-- Calls:		None
--
-- Description:	Generate a script to execute and take backups.
-- 
-- Date			Modified By			Changes
-- 05/07/2018   Aron E. Tekulsky    Initial Coding.
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

	DECLARE @Cmd nvarchar(4000)
	DECLARE @DBName nvarchar(128)
	DECLARE @SourceServer nvarchar(128)
	DECLARE @SourceShare nvarchar(128)
	DECLARE db_cur CURSOR FOR

	SELECT d.name
		FROM sys.databases d
	WHERE d.database_id > 4 AND
		d.name NOT in ('OSSDBADB') AND
		state_desc = 'ONLINE'
	ORDER BY d.database_id ASC;

	-- Initialize
	----SET @SourceServer = 'F:\SS2K14$PROD';
	SET @SourceServer = 'F:\MSSQL_TEST';
	SET @SourceShare = 'Backup';

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@DBName;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			SET @Cmd = 'BACKUP DATABASE [' + @DBName + '] TO DISK = N' + '''' +
				@SourceServer + '\' + @SourceShare + '\' + @DBName + '.bak' + '''' +
				' WITH COPY_ONLY, NOFORMAT, INIT, NAME = N' + '''' + @DBName + '-
				Full Database Backup' + '''' + ', SKIP, NOREWIND, NOUNLOAD,
				COMPRESSION, STATS = 10, CHECKSUM
				GO ' ;

			PRINT @Cmd;

			SET @Cmd = 'declare @backupSetId as int
				SELECT @backupSetId = position FROM msdb..backupset WHERE
				database_name=N' + '''' + @DBName + '''' + ' and backup_set_id=
				(SELECT MAX(backup_set_id) FROM msdb..backupset WHERE
				database_name=N'+ '''' + @DBName + '''' + ' )
				IF @backupSetId IS NULL begin raiserror(N' + '''' + 'Verify
				failed. Backup information for database ' + '''' + '''' +
				@DBName + '''' + '''' + ' not found.' + '''' + ', 16, 1) end
				RESTORE VERIFYONLY FROM DISK = N'+ '''' + @SourceServer + '\' +
				@SourceShare + '\' + @DBName + '.bak'' WITH FILE =
				@backupSetId, NOUNLOAD, NOREWIND
				GO' ;

			PRINT @Cmd;

			FETCH NEXT FROM db_cur INTO
				@DBName;
		END

	CLOSE db_cur;
	DEALLOCATE db_cur;


END
GO
