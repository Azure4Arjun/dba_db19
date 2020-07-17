/****** Object:  Alert [Replication: agent retry]    Script Date: 10/27/2015 1:50:55 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Replication: agent retry', 
		@message_id=14152, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


