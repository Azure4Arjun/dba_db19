USE [msdb]
GO

/****** Object:  Alert [017 - Insufficient Resources]    Script Date: 5/6/2013 12:36:48 PM ******/
EXEC msdb.dbo.sp_delete_alert @name=N'017 - Insufficient Resources
GO

/****** Object:  Alert [017 - Insufficient Resources]    Script Date: 5/6/2013 12:36:48 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'017 - Insufficient Resources', 
		@message_id=0, 
		@severity=17, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


