USE [msdb]
GO

/****** Object:  Alert [Failover Alert]    Script Date: 08/25/2009 12:00:04 ******/
EXEC msdb.dbo.sp_add_alert @name=N'1480 Failover Alert', 
		@message_id=1480, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO



