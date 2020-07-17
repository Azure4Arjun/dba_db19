/****** Object:  Alert [Replication Warning: Slow merge over dialup connection (Threshold: mergeslowrunspeed)]    Script Date: 10/27/2015 1:48:34 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Replication Warning: Slow merge over dialup connection (Threshold: mergeslowrunspeed)', 
		@message_id=14165, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=30, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


