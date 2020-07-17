USE [msdb]
GO

/****** Object:  Alert [SQL Server Blocked Processes]    Script Date: 11/11/2016 8:55:43 AM ******/
EXEC msdb.dbo.sp_delete_alert @name=N'SQL Server Blocked Processes'
GO

/****** Object:  Alert [SQL Server Blocked Processes]    Script Date: 11/11/2016 8:55:43 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'SQL Server Blocked Processes', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=300, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'General Statistics|Processes blocked||>|0', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


