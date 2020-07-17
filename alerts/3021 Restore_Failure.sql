USE [msdb]
GO

/****** Object:  Alert [3021 Restore_Failure]    Script Date: 4/23/2012 2:34:05 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'3021 Restore_Failure', 
		@message_id=3021, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


