USE [msdb]
GO

/****** Object:  Job [DBA Backup Job Status Report]    Script Date: 08/13/2010 15:45:37 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBA Reporting]    Script Date: 08/13/2010 15:45:37 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBA Reporting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBA Reporting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA Backup Job Status Report', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'list most recent backup jobs on all servers.', 
		@category_name=N'DBA Reporting', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'dbservices', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run the report]    Script Date: 08/13/2010 15:45:37 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run the report', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'C:\Program Files (x86)\Microsoft SQL Server\100\DTS\Binn\DTExec.exe /FILE "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\Packages\dbinfrastructurestatus\get_backup_jobs.dtsx" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [e-mail the report]    Script Date: 08/13/2010 15:45:37 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'e-mail the report', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @rec_ip varchar(1000), @subj nvarchar(255)
DECLARE @attch nvarchar(4000), @pro_file nvarchar(2000)
DECLARE @R_C int
DECLARE @DateText varchar(50)
DECLARE @TimeText varchar(50)
DECLARE @Msg  varchar(1000)

SET @pro_file  = ''usnypdba01''
SET @rec_ip = '' atekulsky@nyehealth.org''
SET @subj = '' Backup Job Status report''
SET @attch = ''''
SET @Msg = ''**** Database Backup Job Status reports can now be found on the N drive @ N:\203 - Information Technology Shared Data\databaseadministration\xls\backupjobstatus\''

EXEC @R_C  = msdb.dbo.sp_send_dbmail @profile_name=@pro_file, @recipients=@rec_ip, @subject=@subj , @file_attachments=@attch  , @body=@msg

	IF @R_C < 0

		BEGIN
	  	        SET @DateText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 101)
	     	        SET @TimeText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 114)

		         SET @Msg = ''Unable to send dbmail'' + @DateText + '' at '' + @TimeText
	          	        RAISERROR (@Msg, 16, 1)
 

		DECLARE @MsgTitle varchar(50)

		  SET @MsgTitle = @Msg + CONVERT(varchar(30), CURRENT_TIMESTAMP)

		END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [copy file]    Script Date: 08/13/2010 15:45:37 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'copy file', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @Result int

/* Delete the files from the server */
	  EXEC @Result = xp_cmdshell ''  copy /y \\usnypdba01\ssis_errors\testemail\backupjob_status_template.xls \\usnypdba01\ssis_errors\testemail\backupjob_status.xls ''

  IF @Result = 1
     BEGIN
          DECLARE @DateText as varchar(32), @TimeText as varchar(32), @Msg as varchar(512)
          SET @DateText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 101)
          SET @TimeText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 114)

          SET @Msg = ''There are no i files to copy as of '' + @DateText + '' at '' + @TimeText
        RAISERROR (@Msg, 18, 1)
     END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBA Backup Job Status Report', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=127, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20081024, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


