USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1
GO
EXEC msdb.dbo.sp_purge_jobhistory  @oldest_date='2016-01-26T14:48:52'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=100000, 
		@email_save_in_sent_folder=1
GO
