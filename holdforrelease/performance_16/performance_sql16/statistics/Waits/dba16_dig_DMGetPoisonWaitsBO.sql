SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetPoisonWaitsBO
--
--
-- Calls:		None
--
-- Description:	query the waits tables to get overall bottleneck data over time.
--				Some waits are what we call poison: any occurrence of them means 
--				your SQL Server may feel unusable while this wait type is happening. 
--				You might only have a few minutes of this wait type, out of hours or 
--				days of uptime, but a few minutes of inaccessibility sure seems like 
--				a total outage to your end users.
--
-- https://www.brentozar.com/blitz/poison-wait-detected/
-- 
-- Date			Modified By			Changes
-- 05/06/2019   Aron E. Tekulsky    Initial Coding.
-- 05/06/2019   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT w.wait_type, w.waiting_tasks_count, w.wait_time_ms, w.max_wait_time_ms, w.signal_wait_time_ms 
	FROM sys.dm_os_wait_stats  w
WHERE w.wait_type IN (
	'CMEMTHREAD', 'IO_QUEUE_LIMIT', 'IO_RETRY', 'LOG_RATE_GOVERNOR', 'POOL_LOG_RATE_GOVERNOR', 'PREEMPTIVE_DEBUG', 'RESMGR_THROTTLED', 
	'RESOURCE_SEMAPHORE', 'RESOURCE_SEMAPHORE_QUERY_COMPILE', 'SE_REPL', 'THREADPOOL')
ORDER BY w.wait_time_ms DESC;

END
GO
