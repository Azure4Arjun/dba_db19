USE [msdb]
GO

/****** Object:  Alert [Restore_Failure_15]    Script Date: 04/02/2012 15:20:03 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3025 Restore Failure', 
		@message_id=3025, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


