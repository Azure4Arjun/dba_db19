/****** Object:  Alert [Replication: Subscriber has passed data validation]    Script Date: 10/27/2015 1:52:22 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Replication: Subscriber has passed data validation', 
		@message_id=20575, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


