USE [msdb]
GO

/****** Object:  Alert [Restore_Failure_14]    Script Date: 04/02/2012 15:17:30 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3024 Restore Failure', 
		@message_id=3024, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


