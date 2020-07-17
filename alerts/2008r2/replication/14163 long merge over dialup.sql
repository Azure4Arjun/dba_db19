/****** Object:  Alert [Replication Warning: Long merge over dialup connection (Threshold: mergeslowrunduration)]    Script Date: 10/27/2015 1:46:22 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Replication Warning: Long merge over dialup connection (Threshold: mergeslowrunduration)', 
		@message_id=14163, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=30, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


