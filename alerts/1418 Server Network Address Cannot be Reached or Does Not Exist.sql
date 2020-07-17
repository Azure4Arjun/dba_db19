USE [msdb]
GO

/****** Object:  Alert [1418 Server Network Address Cannot be Reached or Does Not Exist]    Script Date: 06/25/2012 16:19:36 ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'1418 Server Network Address Cannot be Reached or Does Not Exist')
EXEC msdb.dbo.sp_delete_alert @name=N'1418 Server Network Address Cannot be Reached or Does Not Exist'
GO

USE [msdb]
GO

/****** Object:  Alert [1418 Server Network Address Cannot be Reached or Does Not Exist]    Script Date: 06/25/2012 16:19:36 ******/
EXEC msdb.dbo.sp_add_alert @name=N'1418 Server Network Address Cannot be Reached or Does Not Exist', 
		@message_id=1418, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


