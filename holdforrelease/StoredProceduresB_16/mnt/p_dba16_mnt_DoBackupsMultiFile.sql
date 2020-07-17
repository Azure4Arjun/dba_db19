SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_mnt_DoBackupsMultiFile
--
-- Arguments:	@backup_type			nvarchar(10), -- Full, Log
--				--@compatibility_level2	tinyint, -- 80 sql 2000, 90 sql 2005, 100 sql 2008
--				@database_type			nvarchar(6), -- user or system
--				@backup_location		nvarchar(1000),
--				@verify_backup			char(1),
--				@check_sum				char(1),
--				@num_stripes			int
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	create backups fo rdatabases with multiple files.
-- 
-- Date			Modified By			Changes
-- 06/21/2011   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/08/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_mnt_DoBackupsMultiFile 
	-- Add the parameters for the stored procedure here
	@backup_type				nvarchar(10), -- Full, Log
	--@compatibility_level2	tinyint, -- 80 sql 2000, 90 sql 2005, 100 sql 2008
	@database_type			nvarchar(6), -- user or system
	@backup_location		nvarchar(1000),
	@verify_backup			char(1),
	@check_sum				char(1),
	@num_stripes			int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
/* local variables */
	DECLARE @query_cmd				nvarchar(4000),
			@query_cmd2				nvarchar(4000),
			@backupdate				datetime,
			@backup_date_text		nvarchar(8),
			@backup_time_text		nvarchar(8),
			@database_name			nvarchar(1000),
			--@db_name				varchar(100),
			@database_id			int,
			@errmsg					nvarchar(1000),
			@filetype				char(3),
			@compatability_level	tinyint,
			@servername				nvarchar(100),
			@slash					bigint,
			@semicolon				int,
			@backup_type2			nvarchar(10),
			@backupSetId			int,
			@Compress				char(1),
			@stripecounter			int
			
	DECLARE @StartMessage			nvarchar(max),
			@errcode				int


-- ola code --------------------------------

	DECLARE @Error int

  ----------------------------------------------------------------------------------------------------
  --// Log initial information                                                                    //--
  ----------------------------------------------------------------------------------------------------

	SET @StartMessage = 'DateTime: ' + CONVERT(nvarchar,GETDATE(),120) + CHAR(13) + CHAR(10);
	SET @StartMessage = @StartMessage + 'Server: ' + CAST(SERVERPROPERTY('ServerName') AS nvarchar) + CHAR(13) + CHAR(10);
	SET @StartMessage = @StartMessage + 'Version: ' + CAST(SERVERPROPERTY('ProductVersion') AS nvarchar) + CHAR(13) + CHAR(10);
	SET @StartMessage = @StartMessage + 'Edition: ' + CAST(SERVERPROPERTY('Edition') AS nvarchar) + CHAR(13) + CHAR(10);
	SET @StartMessage = @StartMessage + 'Procedure: ' + QUOTENAME(DB_NAME(DB_ID())) + '.' + (SELECT QUOTENAME(sys.schemas.name) FROM sys.schemas INNER JOIN sys.objects ON sys.schemas.[schema_id] = sys.objects.[schema_id] WHERE [object_id] = @@PROCID) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID)) + CHAR(13) + CHAR(10);
	SET @StartMessage = @StartMessage + 'Parameters: @database_name = ' + ISNULL('''' + REPLACE(@database_name,'''','''''') + '''','NULL');
	SET @StartMessage = @StartMessage + ', @backup_location = ' + ISNULL('''' + REPLACE(@backup_location,'''','''''') + '''','NULL');
	SET @StartMessage = @StartMessage + ', @backup_type = ' + ISNULL('''' + REPLACE(@backup_type,'''','''''') + '''','NULL');
	SET @StartMessage = @StartMessage + ', @verify_backup = ' + ISNULL('''' + REPLACE(@verify_backup,'''','''''') + '''','NULL');
	SET @StartMessage = @StartMessage + ', @check_sum = ' + ISNULL('''' + REPLACE(@check_sum,'''','''''') + '''','NULL');
	SET @StartMessage = @StartMessage + ', @num_stripes = ' + ISNULL('''' + REPLACE(@num_stripes,'''','''''') + '''','NULL');
  --SET @StartMessage = @StartMessage + ', @cleanup_time = ' + ISNULL(CAST(@cleanup_time AS nvarchar),'NULL');
	SET @StartMessage = @StartMessage + ', @Compress = ' + ISNULL('''' + REPLACE(@Compress,'''','''''') + '''','NULL');
  --SET @StartMessage = @StartMessage + ', @CopyOnly = ' + ISNULL('''' + REPLACE(@CopyOnly,'''','''''') + '''','NULL');
  --SET @StartMessage = @StartMessage + ', @ChangeBackupType = ' + ISNULL('''' + REPLACE(@ChangeBackupType,'''','''''') + '''','NULL');
  --SET @StartMessage = @StartMessage + ', @BackupSoftware = ' + ISNULL('''' + REPLACE(@BackupSoftware,'''','''''') + '''','NULL');
  --SET @StartMessage = @StartMessage + ', @Execute = ' + ISNULL('''' + REPLACE(@Execute,'''','''''') + '''','NULL');
	SET @StartMessage = @StartMessage + CHAR(13) + CHAR(10);
	SET @StartMessage = REPLACE(@StartMessage,'%','%%');

	RAISERROR(@StartMessage,10,1) WITH NOWAIT;

	IF IS_SRVROLEMEMBER('sysadmin') = 0
		BEGIN
			RAISERROR('The server role SysAdmin is needed for the installation.',16,1);
			SET @Error = @@ERROR;
		END

	IF CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))-1) + '.' + REPLACE(RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))),'.','') AS numeric(18,9)) < 9.003042
		BEGIN
			RAISERROR('The solution is supported on SQL Server 2005 and SQL Server 2008. Service Pack 2 is required on SQL Server 2005.',16,1);
			 SET @Error = @@ERROR;
		END

	IF (SELECT [compatibility_level] FROM sys.databases WHERE database_id = DB_ID()) < 90
		BEGIN
			RAISERROR('The database that you are creating the objects in has to be in compatibility_level 90 or 100.',16,1);
			SET @Error = @@ERROR;
		END

	IF (SELECT collation_name FROM sys.databases WHERE database_id = DB_ID()) <> (SELECT collation_name FROM sys.databases WHERE [name] = 'tempdb')
		BEGIN
			RAISERROR('The database that you are creating the objects in has to have the same collation as tempdb.',16,1);
			SET @Error = @@ERROR;
		END

	IF (SELECT value_in_use FROM sys.configurations WHERE name = 'Agent XPs') <> 1
		BEGIN
			 RAISERROR('The SQL Server Agent has to be started.',16,1);
			SET @Error = @@ERROR;
	END


-- end ola code --------------------------------------


	IF DBA_16.[dbo].[f_dba16_utl_GetSemicolon](@backup_type) > 0
		BEGIN
			SET @errmsg = 'The Backup type could have SQL Injection ' + @backup_type + ' is invalid';
			RAISERROR(@errmsg,16,1);
			SET @Error = @@ERROR;
		END

	IF DBA_16.[dbo].[f_dba16_utl_GetSemicolon](@backup_location) > 0
		BEGIN
			SET @errmsg = 'The Backup location could have SQL Injection ' + @backup_location + ' is invalid';
			RAISERROR(@errmsg,16,1);
			SET @Error = @@ERROR;
		END

 --@database_type
	IF DBA_16.[dbo].[f_dba16_utl_GetSemicolon](@database_type) > 0
		BEGIN
			SET @errmsg = 'The Database type could have SQL Injection ' + @database_type + ' is invalid';
			RAISERROR(@errmsg,16,1);
			SET @Error = @@ERROR;
		END

-- set to upper case
--print '**** comparing backup types ****'

	SET @backup_type = upper(@backup_type);

	IF UPPER(@backup_type) IS NULL
		BEGIN
			SET @backup_type = 'FULL';
		END

	IF UPPER(@backup_type) NOT IN ('FULL', 'LOG')
		BEGIN
			SET @errmsg = 'The Backup type specified ' + @backup_type + ' is invalid';
			RAISERROR(@errmsg,16,1);
			SET @Error = @@ERROR;
		END


	IF UPPER(@database_type) IS NULL
		BEGIN
			SET @database_type = 'USER';
		END

	IF UPPER(@database_type) NOT IN ('USER', 'SYSTEM')
		BEGIN
			SET @errmsg = 'The Database type specified ' + @database_type + ' is invalid';
			RAISERROR(@errmsg,16,1);
			SET @Error = @@ERROR;
		END

--IF UPPER(@compatibility_level2) NOT IN (8,9, 10)
--IF UPPER(@compatibility_level2) NOT IN (80,90, 100)
--BEGIN
--	SET @errmsg = 'The compatibility level specified ' + convert(varchar(10),@compatibility_level2) + ' is invalid'
--  RAISERROR(@errmsg,16,1)
--  SET @Error = @@ERROR
--END

	IF UPPER(@verify_backup) NOT IN ('Y')
		BEGIN
			SET @verify_backup = 'N';
		END


	IF UPPER(@check_sum) NOT IN ('Y')
		BEGIN
			SET @check_sum = 'N';
		END

-- number of stripes
	IF @num_stripes = 0 OR @num_stripes IS NULL
		BEGIN
			SET @num_stripes= 1;
		END


-- get the server name to be used in building the backup location.

-- check for instance name different than severname.
	SELECT @slash = CHARINDEX('\',@@servername);

	IF @slash > 0
		BEGIN
			SELECT @servername =  substring(@@servername, @slash + 1, LEN (@@servername));
		END

	ELSE
		BEGIN
			SELECT @servername =  @@servername;
		END

/* **** get the databases that are in full mode and are on-line **** */
		
	IF UPPER(@backup_type) = 'FULL'
		BEGIN
			IF @database_type = 'USER'
				BEGIN
					DECLARE db_cur CURSOR FOR
						SELECT d.name, d.database_id, d.compatibility_level
							FROM master.sys.databases d
								LEFT JOIN dbo.dba_database_expiration e ON (e.db_dbid = d.database_id)
						WHERE d.recovery_model in (1,2,3) and -- 1 full 2 bulk logged 3 simple
							d.state = 0 and  -- 0 online 6 offline 1 restoring
							d.database_id > 4 AND	-- user not system
							d.snapshot_isolation_state = 0 AND -- 0 off 1 on
							e.db_backup_db = 1;-- 0 no backup 1 yes backup
				END
			ELSE -- System databases
				BEGIN
					DECLARE db_cur CURSOR FOR
						SELECT d.name, d.database_id, d.compatibility_level
							FROM master.sys.databases d
						WHERE d.recovery_model in (1,2,3) and -- 1 full 2 bulk logged 3 simple
							d.state = 0 and  -- 0 online 6 offline 1 restoring
							d.database_id <= 4	AND
							d.database_id > 0 AND
							d.database_id <> 2 AND -- user not system
							d.snapshot_isolation_state = 0; -- 0 off 1 on
				END
		END
	ELSE -- log 
		IF @database_type = 'USER'
			BEGIN
				DECLARE db_cur CURSOR FOR
				SELECT d.name, d.database_id, d.compatibility_level
						FROM master.sys.databases d
							LEFT JOIN dbo.dba_database_expiration e ON (e.db_dbid = d.database_id)
				WHERE d.recovery_model = 1 and -- 1 full 2 bulk logged 3 simple
					d.state = 0 and  -- 0 online 6 offline 1 restoring
					d.database_id > 4 AND	-- user not system
					d.snapshot_isolation_state = 0 AND-- 0 off 1 on
					e.db_backup_db = 1;-- 0 no backup 1 yes backup

			END
		ELSE
			BEGIN
				DECLARE db_cur CURSOR FOR
				SELECT d.name, d.database_id, d.compatibility_level
						FROM master.sys.databases d
				WHERE d.recovery_model = 1 and -- 1 full 2 bulk logged 3 simple
					d.state = 0 and  -- 0 online 6 offline 1 restoring
					d.database_id <= 4	AND
					d.database_id > 0 AND
					d.database_id <> 2 AND -- user not system
					d.snapshot_isolation_state = 0; -- 0 off 1 on
			END
	
--GO
-- declare the local varibles for the cursor data ----		

-- open the cursor ----------------------------------
	OPEN db_cur;
--GO
-- fetch the data -----------------------------------
FETCH NEXT FROM db_cur 
	INTO @database_name, @database_id, @compatability_level;
--GO

			------SET @errmsg = 'Backup information ' + '''' + @database_name + '''' + 	 ' Error code is : ' + convert( varchar(100),@@error)
		 ------   raiserror(@errmsg, 16, 1)

WHILE (@@FETCH_STATUS = 0)
	BEGIN
	--print @database_name
/* **** get the backup date from current date **** */		
		SET @backupdate = getdate();

		SET @backup_date_text = convert(varchar(8),@backupdate,112);
		SET @backup_time_text = convert(varchar(8),@backupdate,108);
		SET @backup_time_text = substring(@backup_time_text,1,2) + SUBSTRING (@backup_time_text,4,2) + SUBSTRING (@backup_time_text,7,2);

--print @backup_time_text

		IF @backup_location is null or @backup_location = ''
		-- backup location not specified so use standard locations
		BEGIN
			IF  @compatability_level = 80
				BEGIN
					SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL\BACKUP\';
				END
			
			ELSE IF  @compatability_level = 90
					BEGIN
						SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\BACKUP\';
					END
			ELSE IF  @compatability_level = 100
					BEGIN
						SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL10_50.' +  @servername + '\mssql\MSSQL\BACKUP\';
					--SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL10.' +  QUOTENAME (@servername,'''') + '\mssql\MSSQL\BACKUP\'
				END
			ELSE IF  @compatability_level = 110
					BEGIN
						SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL11.' +  @servername + '\mssql\MSSQL\BACKUP\';
					--SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL10.' +  QUOTENAME (@servername,'''') + '\mssql\MSSQL\BACKUP\'
				END
		END
		
		IF UPPER(@backup_type) = 'FULL'
			BEGIN
				SET @filetype = 'bak'	;
				SET @backup_type2 = 'DATABASE';
			END
		ELSE IF UPPER(@backup_type) = 'LOG'
				BEGIN
					SET @filetype = 'trn'	;
					SET @backup_type2 = 'LOG';
				END


		SET @query_cmd = 'BACKUP ' + @backup_type2 + ' [' + @database_name + '] TO  ' + 
			'DISK = N' + '''' + 
				@backup_location + @database_name + '_backup_' + '1' + '_' 
			+	@backup_date_text + @backup_time_text + '.' + @filetype + ''''; 
	  --+
		 
		 -- SET UP multiple stripes if requested --

		 SET @stripecounter = 2;

		 IF @num_stripes > 1 
			BEGIN
				WHILE (@stripecounter <= @num_stripes)
					BEGIN
						SET @query_cmd = @query_cmd + 
							', DISK = N' + '''' + 
								@backup_location + @database_name + '_backup_' + CONVERT(varchar(2), @stripecounter) +  '_' 
							+	@backup_date_text + @backup_time_text + '.' + @filetype + ''''; 

						SET @stripecounter = @stripecounter + 1;

					END
			END

		SET @query_cmd = @query_cmd + 
			' WITH NOFORMAT, NOINIT,  NAME = N' + '''' +@database_name+ '_backup_';
			
			
			IF (@check_sum = 'Y')
				BEGIN
					--SET @query_cmd = @query_cmd + ' ' + @backup_date_text + @backup_time_text  + '''' + ', SKIP, REWIND, NOUNLOAD,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR'
					SET @query_cmd = @query_cmd +  @backup_date_text + @backup_time_text  + '''' + ', SKIP, REWIND, NOUNLOAD,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR';
				END
			ELSE
				BEGIN
					--SET @query_cmd = @query_cmd + ' ' + @backup_date_text + @backup_time_text  + '''' + ', SKIP, REWIND, NOUNLOAD,  STATS = 10'
					SET @query_cmd = @query_cmd + @backup_date_text + @backup_time_text  + '''' + ', SKIP, REWIND, NOUNLOAD,  STATS = 10';
				END
		 
		 print @query_cmd;
		 EXEC (@query_cmd);
		 
		 -- save the error number
		 SET @errcode = @@error
		 
		 IF @errcode <> 0 
			BEGIN
				SET @errmsg = 'testing ' + error_message();
					RAISERROR(@errmsg,10,1) WITH NOWAIT;
			END
		 
			------SET @errmsg = 'Backup information ' + '''' + @database_name + '''' + 	 ' Error code is : ' + convert( varchar(100),@@error)
		 ------   raiserror(@errmsg, 16, 1)



		IF @verify_backup = 'Y'
			BEGIN
				SET @query_cmd2 = 'RESTORE VERIFYONLY FROM  DISK = N' + '''' + 
					@backup_location + @database_name + '_backup_' + '1' + '_' +
	 				@backup_date_text + @backup_time_text + '.' + @filetype + '''' ;

				SET @stripecounter = 2;

				IF @num_stripes > 1 
					BEGIN
						WHILE (@stripecounter <= @num_stripes)
							BEGIN
								SET @query_cmd2 = @query_cmd2 + ' ,DISK = N' + '''' + 
									@backup_location + @database_name + '_backup_' + + CONVERT(varchar(2), @stripecounter) +  '_' +
		 							@backup_date_text + @backup_time_text + '.' + @filetype + '''' ;

								SET @stripecounter = @stripecounter + 1;
							END
					END

				SET @query_cmd2 = @query_cmd2 + ' WITH  FILE = ' + convert(varchar(25),@backupSetId) + ',  NOUNLOAD,  NOREWIND';
			
				PRINT 'verify = ' + @query_cmd2;
		
				EXEC (@query_cmd2);

			 -- save the error number
				SET @errcode = @@error;
		 
				IF @errcode <> 0 
					BEGIN
						SET @errmsg = 'testing ' + error_message();
						RAISERROR(@errmsg,10,1) WITH NOWAIT;
					END
	 
				SELECT @backupSetId = position
						FROM msdb..backupset
				WHERE database_name = @database_name and
					backup_set_id = (
						SELECT max(backup_set_id)
								FROM msdb..backupset
						  WHERE database_name = @database_name);
						  
				IF @backupSetId is null
					BEGIN
						SET @errmsg = 'Verify failed. Backup information for database ' + '''' + @database_name + '''' + ' not found.';
			
						RAISERROR(@errmsg, 16, 1);
					END
			END		 

		 -- fetch the data -----------------------------------
		FETCH NEXT FROM db_cur 
			INTO @database_name, @database_id, @compatability_level;

	END

	CLOSE db_cur;
	DEALLOCATE db_cur;

	IF @@ERROR <> 0 GOTO ErrorHandler;

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_mnt_DoBackupsMultiFile TO [db_proc_exec] AS [dbo]
GO
