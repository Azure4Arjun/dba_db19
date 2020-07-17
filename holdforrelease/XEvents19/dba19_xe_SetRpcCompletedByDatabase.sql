CREATE EVENT SESSION [RpcCompletedByDatabase] ON SERVER
ADD EVENT sqlserver.rpc_completed(
	ACTION(sqlserver.database_name))
ADD TARGET package0.histogram(SET filtering_event_name=N'sqlserver.rpc_completed',source=N'sqlserver.database_name')
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, TRACK_CAUSALITY=OFF, STARTUP_STATE=ON)
GO