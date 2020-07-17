USE [msdb]
GO

/****** Object:  Alert [Could not allocate a new page for database]    Script Date: 04/02/2012 15:06:09 ******/
EXEC msdb.dbo.sp_add_alert @name=N'1101 New Page Allocation Failure for database', 
		@message_id=1101, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


