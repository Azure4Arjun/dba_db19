USE [msdb]
GO

/****** Object:  Alert [18204 Backup_Failure]    Script Date: 4/23/2012 2:55:56 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'18204 Backup_Failure', 
		@message_id=18204, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


