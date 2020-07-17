SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_exe_BuildPowerShellDBCopy
--
--
-- Calls:		None
--
-- Description:	Build a script to load a db copy job in PowerShell.
-- 
-- Date			Modified By			Changes
-- 02/26/2018   Aron E. Tekulsky    Initial Coding.
-- 02/26/2018   Aron E. Tekulsky    Update to V140.
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

--
----------CREATE PROCEDURE p_dba16_utl_BuildSqlAgenJjob 
	-- Add the parameters for the stored procedure here
	DECLARE @CategoryName	varchar(128) 
	DECLARE @OwnerLogin		varchar(128)
	DECLARE @ServerNam		varchar(128)
	
	------------------ define participating servers.
	DECLARE @SourceServer	nvarchar(128)
	DECLARE @SourceShare	nvarchar(128)
	DECLARE @DestServer		nvarchar(128)
	DECLARE @DestShare		nvarchar(128)
	DECLARE @RestorDataPath	nvarchar(128)
	DECLARE @RestorLogPath	nvarchar(128)
	DECLARE @DestFullPath	nvarchar(128)

	DECLARE @DBName			nvarchar(128)
	DECLARE @JobName		nvarchar(128)
	DECLARE @NotifyEmail	nvarchar(128)

	DECLARE @Part1		nvarchar(4000)
	DECLARE @Part2		nvarchar(4000)
	DECLARE @Part3		nvarchar(4000)
	DECLARE @Part4		nvarchar(4000)
	DECLARE @Part5		nvarchar(4000)
	DECLARE @Part6		nvarchar(4000)
	DECLARE @rundat		varchar(20)
	----------------DECLARE @runtim		varchar(12)
	DECLARE @StepName	nvarchar(128)

	DECLARE @PkgName	varchar(128)
	DECLARE @CountNum	integer


	DECLARE db_cur CURSOR FOR
		SELECT Name
					FROM sys.databases
				WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb', 'SSISDB','ReportServer','ReportServerTempDB')
					AND state_desc = 'ONLINE'
					AND is_read_only <> 1 --means database=in read only mode
					----AND CHARINDEX('-',name) = 0 AND-- no dashes in dbname
					----[dba_db16].[dbo].[f_dba16_utl_GetDBRole] (name) = 1
				ORDER BY name ASC;

	-- Initialize
	SET @CategoryName	= 'Data Copy';
	SET @OwnerLogin		= 'tekular' ;
	SET @ServerNam		= 'local';
	SET @NotifyEmail	= 'dbservices';

	SET @JobName		= 'Copy and Restore DB on Other Server';
	SET @StepName		= '';
	SET @SourceServer	= 'E-Teknologies2';
	SET @SourceShare	= 'Backups';
	SET @DestServer		= 'E-Teknologies3';
	SET @DestShare		= 'Restore';
	SET @RestorDataPath	= 'M:\test\Data';
	SET @RestorLogPath	= 'M:\test\Log';
	SET @DestFullPath	= 'M:\Restore';

	-- get date and time
	SET @rundat =  convert(varchar(20),getdate() );
	
	SET @Part1 = '
		USE [msdb]
		GO';

	PRINT @Part1 ;

	SET @Part2 = '
				/****** Object:  Job ['  + '''' + @JobName + '''' + ']    Script Date: ' + '''' + @rundat + '''' + ' ******/
				BEGIN TRANSACTION
				DECLARE @ReturnCode INT
				SELECT @ReturnCode = 0
				/****** Object:  JobCategory [' + @CategoryName + ']    Script Date: ' + '''' + @rundat + '''' + ' ******/
				IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N' + '''' + @CategoryName + '''' + ' AND category_class=1)
				BEGIN
					EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N' + '''' + 'JOB' + '''' + ', @type=N' + '''' + 'LOCAL' + '''' + ', @name=N' + '''' + @CategoryName + '''' + '
					IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

				END';

-- ***** General Page *****

	SET @Part3 = '
				DECLARE @jobId BINARY(16)
				EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N' + '''' + @JobName + '''' + ', 
				@enabled=1, 
				@notify_level_eventlog=0, 
				@notify_level_email=1, 
				@notify_level_netsend=0, 
				@notify_level_page=0, 
				@delete_level=0, 
				@description=N' + '''' + 'Backup file copy and restore.' + '''' + ', 
				@category_name=N' + '''' + @CategoryName + '''' + ', 
				@owner_login_name=N' + '''' + @OwnerLogin + '''' + ', 
				@notify_email_operator_name=N' + '''' + @NotifyEmail + '''' + ',
				@job_id = @jobId OUTPUT
				IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
				';

	PRINT @Part2 + ' ' + @Part3 ;


	--***** Set up Directory listing *****
	
	SET @PkgName = 'Dir';

	--------PRINT @PkgName;

	SET @Part4 = '
		/****** Object:  Step [' + '''' + @PkgName + '''' + ']    Script Date: ' + '''' + @rundat + '''' + ' ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N' + '''' + @PkgName + '''' + ' , 
				@step_id=1, 
				@cmdexec_success_code=0, 
				@on_success_action=3, 
				@on_success_step_id=0, 
				@on_fail_action=2, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, @subsystem=N' + '''' + 'CmdExec' + '''' + ', 
				@command=N' + '''' + 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe get-childitem -Force \\' + @SourceServer + '\' + @SourceShare + '\' + '''' + ', 
				@flags=0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';
		
	PRINT @Part4;


	SET @PkgName = 'Clean up old files';


	SET @Part4 = '
		/****** Object:  Step [' + '''' + @PkgName + '''' + ']    Script Date: ' + '''' + @rundat + '''' + ' ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N' + '''' + @PkgName + '''' + ' , 
				@step_id=2, 
				@cmdexec_success_code=0, 
				@on_success_action=3, 
				@on_success_step_id=0, 
				@on_fail_action=2, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, @subsystem=N' + '''' + 'CmdExec' + '''' + ', 
				@command=N' + '''' + 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe remove-item -path ' + @DestFullPath + '\* -include *.bak' + '''' + ', 
				@flags=32
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';

		
	PRINT @Part4;


	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO @DBName;


	-- part 4 gets the PowerShell and executes copy commands

	SET @CountNum = 2;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN 

		-- ***** Set up all of the steps *****

			SET @PkgName = 'Copy ' + @DBName;

			SET @CountNum = @CountNum + 1;

			--action 1 = succes quit, 2 = fail quit, 3 = go to next step

			SET @Part4 = '
				/****** Object:  Step [' + '''' + @PkgName + '''' + ']    Script Date: ' + '''' + @rundat + '''' + ' ******/
				EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N' + '''' + @PkgName + '''' + ' , 
						@step_id=' + convert(varchar(10),@CountNum) + ', 
						@cmdexec_success_code=0, 
						@on_success_action=3, 
						@on_success_step_id=0, 
						@on_fail_action=3, 
						@on_fail_step_id=0, 
						@retry_attempts=0, 
						@retry_interval=0, 
						@os_run_priority=0, @subsystem=N' + '''' + 'CmdExec' + '''' + ', 
						@command=N' + '''' + 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Copy-Item -Path ' +  '\\' + @SourceServer + '\' + @SourceShare + '\' + @DBName + '.bak' + ' -Destination \\' + @DestServer + '\' + @DestShare + '\' + @DBName + '.bak' + '''' + ', 
						@flags=32
				IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
				EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = ' + convert(varchar(10),@CountNum) + '
				IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'

			PRINT ' ---- ';

			PRINT @Part4;


			FETCH NEXT FROM db_cur
				INTO @DBName;
		END

		CLOSE db_cur;


		-- ***** Part 5 Do the restore *****

	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO @DBName;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN 

		-- ***** Set up all of the steps *****

			SET @PkgName = 'Restore ' + @DBName;

			SET @CountNum = @CountNum + 1;

			--action 1 = succes quit, 2 = fail quit, 3 = go to next step

			SET @Part5 = '
				/****** Object:  Step [' + '''' + @PkgName + '''' + ']    Script Date: ' + '''' + @rundat + '''' + ' ******/
				EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N' + '''' + @PkgName + '''' + ' , 
						@step_id=' + convert(varchar(10),@CountNum) + ', 
						@cmdexec_success_code=0, 
						@on_success_action=3, 
						@on_success_step_id=0, 
						@on_fail_action=3, 
						@on_fail_step_id=0, 
						@retry_attempts=0, 
						@retry_interval=0, 
						@os_run_priority=0, @subsystem=N' + '''' + 'TSQL' + '''' + ', 
						@command=N' + '''' + 'USE [master] 
							ALTER DATABASE [' + @DBName + '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
							RESTORE DATABASE [' + @DBName + '] FROM  DISK = N' + '''' + '''' + @DestFullPath + '\' + @DBName + '.bak' + '''' + '''' + ' WITH  FILE = 1, 
								MOVE N' + '''' + '''' + @DBName + '''' + '''' + ' TO N' + '''' + '''' +  @RestorDataPath + '\' + @DBName + '.mdf'+ '''' + '''' + ',  
								MOVE N' + '''' + '''' + @DBName + '_log' + '''' + '''' + ' TO N' + '''' + '''' + @RestorLogPath + '\' + @DBName + '_log.ldf' + '''' + '''' + ',  NOUNLOAD,  REPLACE,  STATS = 5
							ALTER DATABASE [' + @DBName + '] SET MULTI_USER

							GO '  + '''' + ',' +
						'@database_name=N' + '''' + 'master' + '''' + ', 
						@flags=4
				IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';

		-- ***** Set UP starting Step *****

			----------SET @Part5 = @Part5 + ' ' +
				

				------------EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = ' + convert(varchar(10),@CountNum) + '
			--------PRINT ' ---- ';

			PRINT @Part5;


			FETCH NEXT FROM db_cur
				INTO @DBName;
		END

		CLOSE db_cur;

		DEALLOCATE db_cur;
		
		PRINT 'EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = ' + '1' + '
				IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';

		-- ***** Part 6 Finishing touches *****
		SET @Part6 = '
				EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N' + '''' + '(' + @ServerNam + ') ' + '''' +
				'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
				COMMIT TRANSACTION
				GOTO EndSave
				QuitWithRollback:
					IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
				EndSave:

				GO'

		PRINT @Part6;

	
	------------IF @@ERROR <> 0 GOTO ErrorHandler

	------------RETURN 1

	------------ErrorHandler:
	------------RETURN -1 
END
GO
------------GRANT EXECUTE ON p_dba16_utl_BuildSqlAgenJjob TO [db_proc_exec] AS [dbo]
------------GO

