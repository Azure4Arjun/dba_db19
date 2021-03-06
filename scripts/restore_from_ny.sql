USE [msdb]
GO
/****** Object:  Job [restore_from_ny]    Script Date: 11/17/2008 11:13:39 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 11/17/2008 11:13:39 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'restore_from_ny', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'IIE\dbservices', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore NY databases]    Script Date: 11/17/2008 11:13:39 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore NY databases', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @Result int
DECLARE @zipdate varchar(32)
DECLARE @cmd varchar(200)


SET @zipdate = convert(varchar(32), CURRENT_TIMESTAMP -1, 101)
-- 	  EXEC @Result = xp_cmdshell ''xcopy  u:\*.zip \\192.168.1.189\gms_zip\*.zip  /Y /d:@zipdate  /i /s'' + '' ''
--set @cmd = ''xcopy  \\192.168.2.4\gms_zip\*.zip \\192.168.1.189\gms_zip\*.zip  /Y /d:'' + @zipdate + ''  /i /s''
--remove date limitation at Donovan''s request

--set @cmd = ''xcopy  \\192.168.2.4\gms_zip\*.zip \\192.168.1.189\gms_zip\*.zip  /Y   /i /s''
set @cmd = ''f:\scripts\admin\disaster_recovery\restore_master2 iiesqlcluster2 f:\restore s:\iieenterprise usnysqlcl2_dbzip_ent> f:\scripts\admin\disaster_recovery\log\restore_master.log''

/* copy the files from the server */
-- 	  EXEC @Result = xp_cmdshell ''copy /Y  u:\*.zip \\192.168.1.189\gms_zip\*.zip''

 	  EXEC @Result = xp_cmdshell @cmd 

--  IF @Result <> 0
 --    BEGIN
  --        DECLARE @DateText as varchar(32), @TimeText as varchar(32), @Msg as varchar(512)
   --       SET @DateText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 101)
    --      SET @TimeText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 114)
--
 --         SET @Msg = ''Unable to copy GMS zip files '' + @DateText + '' at '' + @TimeText 
  --        RAISERROR (@Msg, 18, 1)
   --  END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
