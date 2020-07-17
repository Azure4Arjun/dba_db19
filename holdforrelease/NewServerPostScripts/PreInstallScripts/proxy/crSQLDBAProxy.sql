USE [msdb]
GO

/****** Object:  ProxyAccount [SQLDBAProxy]    Script Date: 5/9/2016 11:36:30 AM ******/
EXEC msdb.dbo.sp_delete_proxy @proxy_name=N'SQLDBAProxy'
GO

/****** Object:  ProxyAccount [SQLDBAProxy]    Script Date: 5/9/2016 11:36:30 AM ******/
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'SQLDBAProxy',@credential_name=N'SQLDBACredential', 
		@enabled=1
GO

EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'SQLDBAProxy', @subsystem_id=12
GO


