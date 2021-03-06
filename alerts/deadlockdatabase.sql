USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Deadlock Database', 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@performance_condition=N'SQLServer:Locks|Number of Deadlocks/sec|Database|>|0', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
