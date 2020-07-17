SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_GetRingBuffersSchedulerMonitor
--
--
-- Calls:		None
--
-- Description:	Get the ring buffers.
-- 
-- Date			Modified By			Changes
-- 03/01/2019   Aron E. Tekulsky    Initial Coding.
-- 03/01/2019   Aron E. Tekulsky    Update to Version 140.
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
	SELECT TOP 1
			rx.record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle
		FROM (
				SELECT CONVERT(XML, record) AS record
					FROM sys.dm_os_ring_buffers 
				WHERE ring_buffer_type = 'RINF_BUFFER_SCHEDULER_MONITOR' AND
					record LIKE '%<SystemHealth>%') AS rx;

END
GO
