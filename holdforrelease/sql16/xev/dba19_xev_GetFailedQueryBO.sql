SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_xev_GetFailedQueryBO
--
--
-- Calls:		None
--
-- Description:	to query high severity errors from System Health.
-- 
-- https://www.brentozar.com/archive/2013/08/what-queries-are-failing-in-my-sql-server/
--
-- Date			Modified By			Changes
-- 11/12/2019   Aron E. Tekulsky    Initial Coding.
-- 11/12/2019   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT CAST(target_data AS XML) AS targetdata
			INTO #system_health_data
		FROM sys.dm_xe_session_targets xet
			 JOIN sys.dm_xe_sessions xe ON xe.address = xet.event_session_address
	WHERE name = 'system_health'
		  AND xet.target_name = 'ring_buffer';
	SELECT DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP), 
			xevents.event_data.value('(@timestamp)[1]', 'datetime2'))							AS [err timestamp], 
			xevents.event_data.value('(data[@name="severity"]/value)[1]', 'bigint')				AS [err severity], 
			xevents.event_data.value('(data[@name="error_number"]/value)[1]', 'bigint')			AS [err number], 
			xevents.event_data.value('(data[@name="message"]/value)[1]', 'nvarchar(512)')		AS [err message], 
			xevents.event_data.value('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)')	AS [query text], 
			xevents.event_data.query('.')														AS [event details]
	FROM #system_health_data
		 CROSS APPLY targetdata.nodes('//RingBufferTarget/event') AS xevents(event_data)
	WHERE xevents.event_data.value('(@name)[1]', 'nvarchar(256)') = 'error_reported';

	DROP TABLE #system_health_data;
	----GO

END
GO
