USE [msdb]
GO

/****** Object:  Alert [Timeout Memory Resources]    Script Date: 04/02/2012 15:22:35 ******/
EXEC msdb.dbo.sp_add_alert @name=N'8645 Timeout Memory Resources', 
		@message_id=8645, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


