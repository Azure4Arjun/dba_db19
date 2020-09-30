CREATE EVENT SESSION [FailedQueries] ON SERVER
ADD EVENT sqlserver.error_reported(
ACTION(sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_name, sqlserver.session_id, sqlserver.sql_text, sqlserver.username)
WHERE ([package0].[greater_than_int64]([severity],(10))))
ADD TARGET package0.event_file(SET filename=N'L:\ExtendedEvents\FailedQueries.xel', max_file_size=(5), max_rollover_files=(10), metadatafile=N'L:\ExtendedEvents\FailedQueries.xem')
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, TRACK_CAUSALITY=OFF, STARTUP_STATE=ON)
GO