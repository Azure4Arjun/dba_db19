SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetOsNetworkWaitType
--
--
-- Calls:		None
--
-- Description:	get OS network wait types.
-- 
-- Date			Modified By			Changes
-- 07/27/2012   Aron E. Tekulsky    Initial Coding.
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

	/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT TOP 1000 [wait_type],[waiting_tasks_count],[wait_time_ms],[max_wait_time_ms],[signal_wait_time_ms]
		FROM [master].[sys].[dm_os_wait_stats]
	WHERE wait_type like ('ASYNC%')
	 ORDER BY wait_type ASC


END
GO
