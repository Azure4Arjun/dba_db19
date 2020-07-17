USE [msdb]
GO

/****** Object:  Alert [Restore_Success_08]    Script Date: 04/02/2012 15:21:02 ******/
EXEC msdb.dbo.sp_add_alert @name=N'18265 Restore Success', 
		@message_id=18265, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

