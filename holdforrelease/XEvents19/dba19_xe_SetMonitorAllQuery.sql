CREATE EVENT SESSION [MonitorAllQuery] ON SERVER
ADD EVENT sqlserver.error_reported(
	ACTION(sqlserver.client_app_name, sqlserver.client_pid, sqlserver.database_id, sqlserver.database_name, sqlserver.query_hash, sqlserver.sql_text, sqlserver.username)
	WHERE ([package0].[greater_than_int64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.module_end(SET collect_statement=(1)
	ACTION(sqlserver.client_app_name, sqlserver.client_pid, sqlserver.database_id, sqlserver.database_name, sqlserver.query_hash,  sqlserver.sql_text, sqlserver.username)
	WHERE ([package0].[greater_than_int64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.rpc_completed(
	ACTION(sqlserver.client_app_name, sqlserver.client_pid, sqlserver.database_id, sqlserver.database_name, sqlserver.query_hash,  sqlserver.sql_text, sqlserver.username)
	WHERE ([package0].[greater_than_int64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.sp_statement_completed(SET collect_object_name=(1)
	ACTION(sqlserver.client_app_name, sqlserver.client_pid, sqlserver.database_id, sqlserver.database_name, sqlserver.query_hash, sqlserver.session_id, sqlserver.sql_text, sqlserver.username)
	WHERE ([package0].[greater_than_int64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.sql_batch_completed(
	ACTION(sqlserver.client_app_name, sqlserver.client_pid, sqlserver.database_id, sqlserver.database_name, sqlserver.query_hash, sqlserver.sql_text, sqlserver.username)
	WHERE ([package0].[greater_than_int64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.sql_statement_completed(
	ACTION(sqlserver.client_app_name, sqlserver.client_pid, sqlserver.database_id, sqlserver.database_name, sqlserver.query_hash, sqlserver.session_id, sqlserver.sql_text, sqlserver.username)
	WHERE ([package0].[greater_than_int64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0))))
ADD TARGET package0.ring_buffer(SET max_event_limit=(1000))
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, TRACK_CAUSALITY=OFF, STARTUP_STATE=ON)
GO