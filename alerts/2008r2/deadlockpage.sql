USE [msdb]
GO

/****** Object:  Alert [Deadlock - Page]    Script Date: 06/13/2013 15:14:01 ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Deadlock - Page')
EXEC msdb.dbo.sp_delete_alert @name=N'Deadlock - Page'
GO

USE [msdb]
GO

/****** Object:  Alert [Deadlock - Page]    Script Date: 06/13/2013 15:14:01 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Deadlock - Page', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'SQLServer:Locks|Number of Deadlocks/sec|Page|>|0', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


