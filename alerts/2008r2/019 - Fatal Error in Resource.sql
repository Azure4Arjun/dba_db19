USE [msdb]
GO

/****** Object:  Alert [019 - Fatal Error in Resource]    Script Date: 3/5/2013 3:05:28 PM ******/
EXEC msdb.dbo.sp_delete_alert @name=N'019 - Fatal Error in Resource'
GO

/****** Object:  Alert [019 - Fatal Error in Resource]    Script Date: 3/5/2013 3:05:28 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'019 - Fatal Error in Resource', 
		@message_id=0, 
		@severity=19, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


