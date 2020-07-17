USE [msdb]
GO

/****** Object:  Alert [Restore_Failure_12]    Script Date: 04/02/2012 15:14:02 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3012 Restore Failure', 
		@message_id=3012, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


