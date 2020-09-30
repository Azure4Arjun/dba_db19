SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_wat_DMTop10WawitStatesSE
--
--
-- Calls:		None
--
-- Description:	List the top 10 wait states.
--
-- https://dba.stackexchange.com/questions/96333/how-to-resolve-resource-semaphore-and-resource-semaphore-query-compile-wait-type
-- 
-- Date			Modified By			Changes
-- 05/06/2019   Aron E. Tekulsky    Initial Coding.
-- 05/06/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT TOP 10
			s.wait_type , s.max_wait_time_ms , s.wait_time_ms , s.signal_wait_time_ms , 
			s.wait_time_ms - s.signal_wait_time_ms  AS resource_wait_time_ms,
			100.0 * s.wait_time_ms  / SUM(s.wait_time_ms) OVER () AS percent_total_signal_wait,
			100.0 * s.wait_time_ms  / SUM(s.wait_time_ms) OVER () AS percent_total_signal_wait,
			100.0 * (s.wait_time_ms - s.signal_wait_time_ms) /  SUM(s.wait_time_ms) OVER () 
				AS percent_total_resource_waits
		FROM sys.dm_os_wait_stats s 
	WHERE s.wait_time_ms > 0  -- remove zero wait times
		AND s.wait_type  NOT IN  -- filter out other irrelevant waits.
		('SLEEP_TASK', 'BROKER_TASK_STOP', 'BROKER_TO_PLUSH', 
		'SQLTRACE_BUFFER_FLUSH', 'CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT', 
		'LAZYWRITER_SLEEP', 'SLEEP_SYSTEMTASK','SLEEP_BPOOL_FLUSH',
		'BROKER_EVENTHANDLER','XE_DISPATCHER_WAIT', 'FT_IFTSHC_MUTEX',
		'CHECKPOINT_QUEUE', 'FT_IFTS_SCHEDULER_IDLE_WAIT', 
		'BROKER_TRANSMITTER','FT_IFTSHC_MUTEX','KSOURCE_MUTEX')  -- MORE MAY BE MISSING FROm THE LIST.
	ORDER BY resource_wait_time_ms DESC;

END
GO
