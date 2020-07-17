USE [msdb]
GO

/****** Object:  Alert [016 - Miscellaneous User Error]    Script Date: 5/6/2013 12:37:07 PM ******/
EXEC msdb.dbo.sp_delete_alert @name=N'016 - Miscellaneous User Error'
GO

/****** Object:  Alert [016 - Miscellaneous User Error]    Script Date: 5/6/2013 12:37:07 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'016 - Miscellaneous User Error', 
		@message_id=0, 
		@severity=16, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


