USE [msdb]
GO
EXEC master.dbo.sp_MSsetalertinfo @failsafeoperator=N'dbservices', 
		@notificationmethod=1
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1, 
		@databasemail_profile=N'CONSQLUATL', 
		@use_databasemail=1
GO
