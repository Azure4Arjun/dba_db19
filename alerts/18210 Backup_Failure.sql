USE [msdb]
GO
EXEC msdb.dbo.sp_update_alert @name=N'18210 Backup_Failure', 
		@message_id=18210, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@database_name=N'', 
		@notification_message=N'', 
		@event_description_keyword=N'', 
		@performance_condition=N'', 
		@wmi_namespace=N'', 
		@wmi_query=N'', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'18210 Backup_Failure', @operator_name=N'dbservices', @notification_method = 1
GO
