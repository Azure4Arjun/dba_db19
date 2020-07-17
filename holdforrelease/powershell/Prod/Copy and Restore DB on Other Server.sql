USE [msdb]
GO
/****** Object: Job [Copy and Restore DB on Other Server] Script Date: 2/20/2019
11:20:47 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object: JobCategory [Data Copy] Script Date: 2/20/2019 11:20:47 AM
******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Copy' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Copy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
DECLARE @jobId BINARY(16)
EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name=N'Copy and Restore DB on Other Server',
@enabled=0,
@notify_level_eventlog=0,
@notify_level_email=0,
@notify_level_netsend=0,
@notify_level_page=0,
@delete_level=0,
@description=N'Backup file copy and restore.',
@category_name=N'Data Copy',
@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object: Step [Dir] Script Date: 2/20/2019 11:20:47 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Dir',
@step_id=1,
@cmdexec_success_code=0,
@on_success_action=3,
@on_success_step_id=0,
@on_fail_action=2,
@on_fail_step_id=0,
@retry_attempts=0,
@retry_interval=0,
@os_run_priority=0, @subsystem=N'CmdExec',
@command=N'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe getchilditem -Force \\MySourceServer\Backup\',
@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object: Step [Clean up old files] Script Date: 2/20/2019 11:20:47 AM
******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clean up old files',
@step_id=2,
@cmdexec_success_code=0,
@on_success_action=3,
@on_success_step_id=0,
@on_fail_action=2,
@on_fail_step_id=0,
@retry_attempts=0,
@retry_interval=0,
@os_run_priority=0, @subsystem=N'CmdExec',
@command=N'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe removeitem -path E:\MSSQL_PROD\backup\Restore\* -include *.bak', 
@flags=32
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object: Step [Copy test7] Script Date: 2/20/2019 11:20:47 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy test7',
@step_id=3,
@cmdexec_success_code=0,
@on_success_action=3,
@on_success_step_id=0,
@on_fail_action=3,
@on_fail_step_id=0,
@retry_attempts=0,
@retry_interval=0,
@os_run_priority=0, @subsystem=N'CmdExec',
@command=N'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Copy-Item -Path \\MySourceServer\Backup\test7*.bak -Destination \\MyDestinationServer\backup\Restore\',
@flags=32
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object: Step [Restore test7] Script Date: 2/20/2019 11:20:47 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore test7',
@step_id=4,
@cmdexec_success_code=0,
@on_success_action=3,
@on_success_step_id=0,
@on_fail_action=3,
@on_fail_step_id=0,
@retry_attempts=0,
@retry_interval=0,
@os_run_priority=0, @subsystem=N'TSQL',
@command=N'USE [master]
ALTER DATABASE [test7] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
RESTORE DATABASE [test7] FROM DISK = N''E:\MSSQL_PROD\backup\Restore\test7.bak'' WITH FILE = 1,
, NOUNLOAD, REPLACE, STATS = 5
ALTER DATABASE [test7] SET MULTI_USER
GO ',
@database_name=N'master',
@flags=4
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
GO