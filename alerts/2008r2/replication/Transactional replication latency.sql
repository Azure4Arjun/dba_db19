/****** Object:  Alert [Replication Warning: Transactional replication latency (Threshold: latency)]    Script Date: 10/27/2015 1:49:35 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Replication Warning: Transactional replication latency (Threshold: latency)', 
		@message_id=0, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=30, 
		@include_event_description_in=1, 
		@category_name=N'Replication', 
		@performance_condition=N'SQLServer:Replication Dist.|Dist:Delivery Latency|ALVMNRCORPMES01-MES_ALV-MES_ALV-prddatTransPu-ALVSAFSQLPRD01-290|>|100', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


