USE [msdb]
GO

/****** Object:  Alert [Backup_Success_01]    Script Date: 04/02/2012 15:04:25 ******/
EXEC msdb.dbo.sp_add_alert @name=N'18264 Database Backed Up', 
		@message_id=18264, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

