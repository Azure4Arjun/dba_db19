--
-- Scheduled every 15 mins  for 24 hrs every day
--

EXEC sp_blitzfirst@OutputDatabaseName = 'dba_db16',
@OutputSchemaName = 'dbao',
@OutputTableName = 'BlitzFirst',
@OutputTableNameFileStats = 'BlitzFirst_FileStats',
@OutputTableNamePerfmonStats = 'BlitzFirst_PerfmonStats',
@OutputTableNameWaitStats = 'BlitzFirst_WaitStats',
@OutputTableRetentionDays = 60,
@OutputTableNameBlitzCache = 'BlitzCache';