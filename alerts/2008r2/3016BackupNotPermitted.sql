USE [msdb]
GO

/****** Object:  Alert [Backup_Failure_04]    Script Date: 04/02/2012 14:57:07 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3016 Backup Not Permitted', 
		@message_id=3016, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


