SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetWaitTypes
--
--
-- Calls:		None
--
-- Description:	Get the wait types.
-- 
-- Date			Modified By			Changes
-- 05/03/2012   Aron E. Tekulsky    Initial Coding.
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

	SELECT wait_type, waiting_tasks_count, wait_time_ms, max_wait_time_ms, signal_wait_time_ms
		FROM sys.dm_os_wait_stats
	ORDER BY wait_time_ms desc
--wait_type ASC
--wait_time_ms desc

END
GO
