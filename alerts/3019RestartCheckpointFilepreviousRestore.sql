USE [msdb]
GO

/****** Object:  Alert [Backup_Failure_07]    Script Date: 04/02/2012 15:02:40 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3019 Restart Checkpoint File previous Restore', 
		@message_id=3019, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


