USE [msdb]
GO
EXEC msdb.dbo.sp_add_operator @name=N'dbservices', 
		@enabled=1, 
		@pager_days=0, 
		@email_address=N'aron.tekulsky@E-TEKnologies.net'
GO
