USE [msdb]
GO

/****** Object:  Alert [MDF file alert]    Script Date: 11/14/2016 2:23:30 PM ******/
EXEC msdb.dbo.sp_delete_alert @name=N'MDF file alert'
GO

/****** Object:  Alert [MDF file alert]    Script Date: 11/14/2016 2:23:30 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'MDF file alert', 
		@message_id=911421, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=1800, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]'--, 
		--@job_id=N'00000000-0000-0000-0000-000000000000'
GO


