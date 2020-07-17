USE [msdb]
GO

/****** Object:  Alert [Backup_Failure_05]    Script Date: 04/02/2012 14:58:47 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3017 Restart Checkpoint File', 
		@message_id=3017, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


