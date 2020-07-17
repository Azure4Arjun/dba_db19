SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_mnt_SetLogFullBackup
--
-- Arguments:	@dbname		nvarchar(128)
--				None
--
-- CallS:		f_dba19_utl_GetAlwaysOnNumeric
--				f_dba19_utl_GetDBRole
-- 
-- Called BY:	p_dba19_alt_GetAlertResponse
--
-- Description:	Create an emergency backup to clear a full log.  
--				Chose the appropriate type base don teh recovery model of the db.
-- 
-- Date			Modified By			Changes
-- 08/22/2016   Aron E. Tekulsky    Initial Coding.
-- 08/22/2016	Aron E. Tekulsky	V120.
-- 02/18/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_mnt_SetLogFullBackup 
	-- Add the parameters for the stored procedure here
	@dbname		nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @alwayson				int
	DECLARE @backup_location		nvarchar(1000)
	DECLARE @backup_type2			nvarchar(10)
	DECLARE @database_name			nvarchar(1000)
	DECLARE @backup_date_text		nvarchar(8)
	DECLARE @backup_time_text		nvarchar(8)
	DECLARE @backupdate				datetime
	DECLARE @compatability_level	tinyint -- 80 sql 2000, 90 sql 2005, 100 sql 2008, 110 sql 2012, 120 sql 2014
	DECLARE @filetype				char(3)
	DECLARE @query_cmd				nvarchar(4000)
	DECLARE @RecoveryModel			tinyint
	DECLARE @servername				nvarchar(100)
	--DECLARE @RecoveryModel2			sql_variant

	--DECLARE @db_backup_location		nvarchar(2000)

	-- initialize
	SET @alwayson = 0;
	SET @database_name = substring(@dbname,2,(len(@dbname)));


	-- find whether always on is runing
	IF [dbo].[f_dba19_utl_GetAlwaysOnNumeric]() = 1 
		SET @alwayson = 1;

	IF @alwayson = 1
		BEGIN
			SET @compatability_level = (SELECT d.compatibility_level
				FROM master.sys.databases d
			WHERE d.name = @database_name AND 
				d.state = 0 AND  -- 0 online 6 offline 1 restoring
				d.snapshot_isolation_state = 0 -- 0 off 1 on
				AND CHARINDEX('-',name) = 0 AND-- no dashes in dbname
				[dbo].[f_dba19_utl_GetDBRole](name) = 1);
		END
	ELSE
		BEGIN
			SET @compatability_level = (SELECT d.compatibility_level
				FROM master.sys.databases d  --WITH (READUNCOMMITTED)
			WHERE d.name = @database_name AND 
				d.state = 0 AND  -- 0 online 6 offline 1 restoring
				d.snapshot_isolation_state = 0 -- 0 off 1 on
				AND CHARINDEX('-',name) = 0);-- AND-- no dashes in dbname
		END

	-- get recovery model

	IF @alwayson = 1
		BEGIN
			 SET @RecoveryModel = (SELECT d.recovery_model
				FROM master.sys.databases d
			WHERE d.name = @database_name AND 
				d.state = 0 AND  -- 0 online 6 offline 1 restoring
				d.snapshot_isolation_state = 0 -- 0 off 1 on
				AND CHARINDEX('-',name) = 0 AND-- no dashes in dbname
				[dbo].[f_dba19_utl_GetDBRole](name) = 1);
		END
	ELSE
		BEGIN

			 SET @RecoveryModel = (SELECT d.recovery_model
				FROM master.sys.databases d
			WHERE d.name = @database_name AND 
				d.state = 0 AND  -- 0 online 6 offline 1 restoring
				d.snapshot_isolation_state = 0 -- 0 off 1 on
				AND CHARINDEX('-',name) = 0);-- AND-- no dashes in dbname
		END


-- get the backup location by registry
	EXEC p_dba19_sys_GetRegistryValue 1,@backup_location OUTPUT

	-- get the backup location
	IF @backup_location is null or @backup_location = ''
		-- backup location not specified so use standard locations
		BEGIN
			IF  @compatability_level = 80
				BEGIN
					SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL\BACKUP\'
				END
			
			ELSE IF  @compatability_level = 90
					BEGIN
						SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\BACKUP\'
					END
			ELSE IF  @compatability_level = 100
					BEGIN
						SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL10.' +  @servername + '\MSSQL\BACKUP\'
					--SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL10.' +  QUOTENAME (@servername,'''') + '\mssql\MSSQL\BACKUP\'
				END
			ELSE IF  @compatability_level = 110
					BEGIN
						SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL11.' +  @servername + '\MSSQL\BACKUP\'
					END
			ELSE IF  @compatability_level = 120
					BEGIN
						SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL12.' +  @servername + '\MSSQL\BACKUP\'
				END
		END

	-- get the backup date and time
	SET @backupdate = getdate()

	SET @backup_date_text = convert(varchar(8),@backupdate,112)
	SET @backup_time_text = convert(varchar(8),@backupdate,108)
	SET @backup_time_text = substring(@backup_time_text,1,2) + SUBSTRING (@backup_time_text,4,2) + SUBSTRING (@backup_time_text,7,2)

	SET @backup_location = @backup_location + '\' + @database_name

	-- determine type of backup.
	IF @RecoveryModel = 1 -- Full
		BEGIN
			-- do a transaction log backup
			SET @filetype = 'TRN'
			SET @backup_type2 = 'LOG'

			SET @query_cmd = 'BACKUP ' + @backup_type2 + ' [' + @database_name + '] TO  DISK = N' + '''' + 
				@backup_location + '\' + @database_name + '_backup_' + 
		 +		@backup_date_text + @backup_time_text + '.' + @filetype + '''' +
				' WITH NOFORMAT, NOINIT,  NAME = N' + '''' + @database_name+ '_backup_'
		END

	ELSE IF @RecoveryModel = 3 -- Simple
			BEGIN
				-- do a differential backup
				SET @filetype = 'DIF'
				SET @backup_type2 = 'DATABASE'

				SET @query_cmd = 'BACKUP ' + @backup_type2 + ' [' + @database_name + '] TO  DISK = N' + '''' + 
					@backup_location + '\' +  @database_name + '_backup_' + 
			 +		@backup_date_text + @backup_time_text + '.' + @filetype + '''' +
					' WITH DIFFERENTIAL, NOFORMAT, NOINIT,  NAME = N' + '''' + @database_name+ '_backup_'
			END
		ELSE -- Bulk. 2
			BEGIN
				SET @filetype = 'TRN'
				SET @backup_type2 = 'LOG'

				SET @query_cmd = 'BACKUP ' + @backup_type2 + ' [' + @database_name + '] TO  DISK = N' + '''' + 
					@backup_location + '\' + @database_name + '_backup_' + 
			 +		@backup_date_text + @backup_time_text + '.' + @filetype + '''' +
					' WITH NOFORMAT, NOINIT,  NAME = N' + '''' + @database_name+ '_backup_'

			END


	SET @query_cmd = @query_cmd + @backup_date_text + @backup_time_text  + '''' + ', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR'

	print @query_cmd

   EXEC (@query_cmd);


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_mnt_SetLogFullBackup TO [db_proc_exec] AS [dbo]
GO
