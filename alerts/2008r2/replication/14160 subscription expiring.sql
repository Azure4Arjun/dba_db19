/****** Object:  Alert [Replication Warning: Subscription expiration (Threshold: expiration)]    Script Date: 10/27/2015 1:49:16 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Replication Warning: Subscription expiration (Threshold: expiration)', 
		@message_id=14160, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=30, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


