/*
From "Working with TempDB in SQL 2005"

If you experience allocation bottlenecks, query the sysprocesses table. 
Any time you see tasks waiting to acquire latches on tempdb pages, 
you can analyze to see if this is due to PFS and SGAM pages. 
You can look for PFS and SGAM pages by using waitresource. 
For example  ‘2:1:1’ or ‘2:1:3’ refer to the first PFS page and the 
first SGAM page in file1 of the tempdb database (id=2). 
SGAM pages re-occur after every 511,232 pages and each PFS page occurs 
after every 8,088 pages. 
You can use this information to find all other PFS and SGAM pages across all files in tempdb.

SQLQueryStress by Adam Machanic
https://github.com/ErikEJ/SqlQueryStress


*/

DBCC SQLPERF('sys.dm_os_wait_stats',CLEAR) ;

--  Find PageLatch waits
SELECT w.session_id, w.wait_type, w.wait_duration_ms, w.resource_description, w.resource_address
FROM sys.dm_os_waiting_tasks AS w 
WHERE w.wait_type LIKE 'PAGELATCH%' ;

--  Adam Machanic's sp
EXEC dbo.sp_WhoIsActive

SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ('XE_TIMER_EVENT','REQUEST_FOR_DEADLOCK_SEARCH','SQLTRACE_BUFFER_FLUSH','LAZYWRITER_SLEEP','SLEEP_TASK','BROKER_TO_FLUSH','FT_IFTS_SCHEDULER_IDLE_WAIT','CHECKPOINT_QUEUE','LOGMGR_QUEUE','SP_SERVER_DIAGNOSTICS_SLEEP','XE_DISPATCHER_WAIT','HADR_FILESTREAM_IOMGR_IOCOMPLETION','SQLTRACE_INCREMENTAL_FLUSH_SLEEP','DIRTY_PAGE_POLL')
ORDER BY wait_time_ms DESC ;


