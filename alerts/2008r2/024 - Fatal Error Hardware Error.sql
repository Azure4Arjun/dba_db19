USE [msdb]
GO

/****** Object:  Alert [024 - Fatal Error: Hardware Error]    Script Date: 3/5/2013 3:08:58 PM ******/
EXEC msdb.dbo.sp_delete_alert @name=N'024 - Fatal Error: Hardware Error'
GO

/****** Object:  Alert [024 - Fatal Error: Hardware Error]    Script Date: 3/5/2013 3:08:58 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'024 - Fatal Error: Hardware Error', 
		@message_id=0, 
		@severity=24, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


