USE [msdb]
GO

/****** Object:  Alert [025 - Fatal Error]    Script Date: 3/5/2013 3:09:27 PM ******/
EXEC msdb.dbo.sp_delete_alert @name=N'025 - Fatal Error'
GO

/****** Object:  Alert [025 - Fatal Error]    Script Date: 3/5/2013 3:09:27 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'025 - Fatal Error', 
		@message_id=0, 
		@severity=25, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


