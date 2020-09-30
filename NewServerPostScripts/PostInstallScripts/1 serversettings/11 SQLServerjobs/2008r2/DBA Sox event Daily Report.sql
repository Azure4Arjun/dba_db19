USE [msdb]
GO

/****** Object:  Job [DBA Sox event Daily Report]    Script Date: 6/27/2012 4:28:33 PM ******/
EXEC msdb.dbo.sp_delete_job @job_id=N'a2193246-659b-4938-8425-216a7dfc5a39', @delete_unused_schedule=1
GO

/****** Object:  Job [DBA Sox event Daily Report]    Script Date: 6/27/2012 4:28:33 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBA Reporting]    Script Date: 6/27/2012 4:28:33 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBA Reporting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBA Reporting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA Sox event Daily Report', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'List all of the past 25 hours database events on all servers.', 
		@category_name=N'DBA Reporting', 
		@owner_login_name=N'IIE\dbservices', 
		@notify_email_operator_name=N'aron', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run the report]    Script Date: 6/27/2012 4:28:33 PM ******/
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
		@command=N'C:\Program Files (x86)\Microsoft SQL Server\90\DTS\Binn\DTExec.exe /FILE "C:\Program Files (x86)\Microsoft SQL Server\90\DTS\Packages\sox\pkg_dba_sox_daily_report.dtsx" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E', 
		@flags=32
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [e-mail the report]    Script Date: 6/27/2012 4:28:33 PM ******/
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
SET @rec_ip = '' atekulsky@iie.org;''
SET @subj = '' DBA Sox event Daily Report''
SET @attch = ''''
SET @Msg = ''**** Database Sox All Events Reports can now be found on the N drive @ N:\203 - Information Technology Shared Data\databaseadministration\xls\sox\''

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
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBA Sox event Daily Report', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=127, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20081024, 
		@active_end_date=99991231, 
		@active_start_time=61500, 
		@active_end_time=235959, 
		@schedule_uid=N'43f713d3-c1c3-4252-8aaf-da0e6cce38cf'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


