USE [msdb]
GO

-- All Notifications for Alerts

EXEC msdb.dbo.sp_add_notification @alert_name=N'1101 New Page Allocation Failure for database', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'1105 Object Space Allocation Failure', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'1205 Transaction Process Deadlock', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'1408 Failover Alert', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'3012 Restore Failure', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'3016 Backup Not Permitted', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'3017 Restart Checkpoint File', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'3018 Restart Checkpoint File Not Found', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'3019 Restart Checkpoint File previous Restore', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'3021 Restore_Failure', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'3023 Restore Failure', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'3024 Restore Failure', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'3025 Restore Failure', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'8631 Internal Stack Limit', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'8645 Timeout Memory Resources', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'8651 Minimum Query Memory', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'9002Transaction Log Full', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'18204 Backup Device Failure', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'18210 Failure on Backup Device', @operator_name=N'dbservices', @notification_method = 1
GO

--EXEC msdb.dbo.sp_add_notification @alert_name=N'18264 Database Backed Up', @operator_name=N'dbservices', @notification_method = 1
--GO

--EXEC msdb.dbo.sp_add_notification @alert_name=N'18265 Restore Success', @operator_name=N'dbservices', @notification_method = 1
--GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'18486 Acct locked out', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'Deadlock - Database', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'Deadlock - Keys', @operator_name=N'dbservices', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'Deadlock - Page', @operator_name=N'dbservices', @notification_method = 1
GO
