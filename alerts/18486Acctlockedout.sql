USE [msdb]
GO

/****** Object:  Alert [A/c locked out]    Script Date: 4/17/2012 9:52:59 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'18486 Acct locked out', 
		@message_id=18486, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


