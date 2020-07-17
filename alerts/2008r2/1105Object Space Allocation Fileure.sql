USE [msdb]
GO

/****** Object:  Alert [could not allocate space for object]    Script Date: 04/02/2012 15:07:48 ******/
EXEC msdb.dbo.sp_add_alert @name=N'1105 Object Space Allocation Failure', 
		@message_id=1105, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


