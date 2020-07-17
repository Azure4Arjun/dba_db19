USE [msdb]
GO

/****** Object:  Alert [022 - Fatal Error: Table Integrity Suspect]    Script Date: 3/5/2013 3:07:30 PM ******/
EXEC msdb.dbo.sp_delete_alert @name=N'022 - Fatal Error: Table Integrity Suspect'
GO

/****** Object:  Alert [022 - Fatal Error: Table Integrity Suspect]    Script Date: 3/5/2013 3:07:30 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'022 - Fatal Error: Table Integrity Suspect', 
		@message_id=0, 
		@severity=22, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


