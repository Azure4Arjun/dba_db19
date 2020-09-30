USE [msdb]
GO

/****** Object:  Job [Restore 3 CRM Databases from Prod]    Script Date: 7/21/2016 3:00:09 PM ******/
EXEC msdb.dbo.sp_delete_job @job_id=N'585f134f-b67d-4966-9b49-bea62f305de8', @delete_unused_schedule=1
GO

/****** Object:  Job [Restore 3 CRM Databases from Prod]    Script Date: 7/21/2016 3:00:09 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [CRM DATA COPY]    Script Date: 7/21/2016 3:00:09 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'CRM DATA COPY' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'CRM DATA COPY'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Restore 3 CRM Databases from Prod', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'CRM DATA COPY', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'dbservices', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [dir]    Script Date: 7/21/2016 3:00:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dir', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe get-childitem -Force \\PNG-SQLPRD-P\BACKUP01\', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clean up old files]    Script Date: 7/21/2016 3:00:10 PM ******/
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
		@command=N'Del T:\restore\*.bak', 
		@flags=32
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [COPY CRMDATA]    Script Date: 7/21/2016 3:00:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'COPY CRMDATA', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Copy-Item -Path \\PNG-SQLPRD-P\BACKUP01\CRMDATA.bak -Destination \\PNG-SQLTST-T\restore2\CRMDATA.bak

', 
		@flags=32
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [COPY MSCRM_CONFIG]    Script Date: 7/21/2016 3:00:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'COPY MSCRM_CONFIG', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Copy-Item -Path \\PNG-SQLPRD-P\BACKUP01\MSCRM_CONFIG.bak 	-Destination T:\restore\MSCRM_CONFIG.bak
', 
		@flags=32
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [COPY PNGCRM_MSCRM]    Script Date: 7/21/2016 3:00:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'COPY PNGCRM_MSCRM', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Copy-Item -Path \\PNG-SQLPRD-P\BACKUP01\PNGCRM_MSCRM.bak 	-Destination T:\restore\PNGCRM_MSCRM.bak
', 
		@flags=32
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore CRMDATA]]    Script Date: 7/21/2016 3:00:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore CRMDATA]', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
ALTER DATABASE [CRMDATA] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
RESTORE DATABASE [CRMDATA] FROM  DISK = N''T:\restore\CRMDATA.bak'' WITH  FILE = 1,  MOVE N''CRMDATA'' TO N''S:\Data\CRMDATA.mdf'',  MOVE N''CRMDATA_log'' TO N''T:\Logs\CRMDATA_log.ldf'',  NOUNLOAD,  REPLACE,  STATS = 5
ALTER DATABASE [CRMDATA] SET MULTI_USER

GO

', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore MSCRM_CONFIG]    Script Date: 7/21/2016 3:00:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore MSCRM_CONFIG', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
ALTER DATABASE [MSCRM_CONFIG] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
RESTORE DATABASE [MSCRM_CONFIG] FROM  DISK = N''T:\restore\MSCRM_CONFIG.bak'' WITH  FILE = 1,  MOVE N''MSCRM_CONFIG'' TO N''S:\Data\MSCRM_CONFIG.mdf'',  MOVE N''MSCRM_CONFIG_log'' TO N''T:\Logs\MSCRM_CONFIG_log.LDF'',  NOUNLOAD,  REPLACE,  STATS = 5
ALTER DATABASE [MSCRM_CONFIG] SET MULTI_USER

GO


', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore PNGCRM_MSCRM]    Script Date: 7/21/2016 3:00:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore PNGCRM_MSCRM', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
ALTER DATABASE [PNGCRM_MSCRM] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
RESTORE DATABASE [PNGCRM_MSCRM] FROM  DISK = N''T:\restore\PNGCRM_MSCRM.bak'' WITH  FILE = 1,  MOVE N''mscrm'' TO N''S:\Data\PNGCRM_MSCRM.mdf'',  MOVE N''mscrm_log'' TO N''T:\Logs\PNGCRM_MSCRM_log.LDF'',  NOUNLOAD,  REPLACE,  STATS = 5
ALTER DATABASE [PNGCRM_MSCRM] SET MULTI_USER

GO', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore User Acess]    Script Date: 7/21/2016 3:00:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore User Acess', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [CRMDATA]
GO
CREATE USER [PIEDMONT\DixonJa] FOR LOGIN [PIEDMONT\DixonJa]
GO
USE [CRMDATA]
GO
ALTER ROLE [db_datareader] ADD MEMBER [PIEDMONT\DixonJa]
GO
USE [MSCRM_CONFIG]
GO
CREATE USER [PIEDMONT\DixonJa] FOR LOGIN [PIEDMONT\DixonJa]
GO
USE [MSCRM_CONFIG]
GO
ALTER ROLE [db_datareader] ADD MEMBER [PIEDMONT\DixonJa]
GO
USE [PNGCRM_MSCRM]
GO
CREATE USER [PIEDMONT\DixonJa] FOR LOGIN [PIEDMONT\DixonJa]
GO
USE [PNGCRM_MSCRM]
GO
ALTER ROLE [db_datareader] ADD MEMBER [PIEDMONT\DixonJa]
GO

CREATE USER [PIEDMONT\ColliKa] FOR LOGIN [PIEDMONT\ColliKa]
GO
USE [CRMDATA]
GO
ALTER ROLE [db_datareader] ADD MEMBER [PIEDMONT\ColliKa]
GO
USE [MSCRM_CONFIG]
GO
CREATE USER [PIEDMONT\ColliKa] FOR LOGIN [PIEDMONT\ColliKa]
GO
USE [MSCRM_CONFIG]
GO
ALTER ROLE [db_datareader] ADD MEMBER [PIEDMONT\ColliKa]
GO
USE [PNGCRM_MSCRM]
GO
CREATE USER [PIEDMONT\ColliKa] FOR LOGIN [PIEDMONT\ColliKa]
GO
USE [PNGCRM_MSCRM]
GO
ALTER ROLE [db_datareader] ADD MEMBER [PIEDMONT\ColliKa]
GO
', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Monthly Restore', 
		@enabled=1, 
		@freq_type=32, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=16, 
		@freq_recurrence_factor=1, 
		@active_start_date=20160721, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid=N'ddf45c7c-fac7-4258-a565-13d5785e7794'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Muiltiple Day Restore', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=32, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20160721, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid=N'abc52a34-4a6b-40ff-a39c-1d7634b59144'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


