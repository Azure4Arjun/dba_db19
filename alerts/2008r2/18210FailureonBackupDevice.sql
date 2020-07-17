USE [msdb]
GO

/****** Object:  Alert [Backup_Failure_03]    Script Date: 04/02/2012 14:55:12 ******/
EXEC msdb.dbo.sp_add_alert @name=N'18210 Failure on Backup Device', 
		@message_id=18210, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


