CREATE EVENT SESSION [sql_batch_completed_by_database] ON SERVER
ADD EVENT sqlserver.sql_batch_completed(
	ACTION(sqlserver.database_name))
ADD TARGET package0.histogram(SET filtering_event_name=N'sqlserver.sql_batch_completed',source=N'sqlserver.database_name')
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, TRACK_CAUSALITY=OFF, STARTUP_STATE=ON)
GO