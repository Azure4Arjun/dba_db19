USE [msdb]
GO

/****** Object:  Alert [Internal Stack Limit]    Script Date: 04/02/2012 15:10:36 ******/
EXEC msdb.dbo.sp_add_alert @name=N'8631 Internal Stack Limit', 
		@message_id=8631, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


