USE [msdb]
GO

/****** Object:  Alert [AG Data Movement Resumed]    Script Date: 4/18/2016 2:53:01 PM ******/
EXEC msdb.dbo.sp_delete_alert @name=N'35265 - AG Data Movement Resumed'
GO

/****** Object:  Alert [AG Data Movement Resumed]    Script Date: 4/18/2016 2:53:01 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'35265 - AG Data Movement Resumed', 
		@message_id=35265, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


