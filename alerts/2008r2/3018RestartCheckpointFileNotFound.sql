USE [msdb]
GO

/****** Object:  Alert [Backup_Failure_06]    Script Date: 04/02/2012 15:00:25 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3018 Restart Checkpoint File Not Found', 
		@message_id=3018, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


