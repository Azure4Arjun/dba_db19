USE [msdb]
GO

/****** Object:  Alert [Restore_Failure_13]    Script Date: 04/02/2012 15:16:21 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3023 Restore Failure', 
		@message_id=3023, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


