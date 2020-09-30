SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_wat_DMGetOSNetworkWaitTypePAGELATCH
--
--
-- Calls:		None
--
-- Description:	get OS network wait types.
-- 
-- Date			Modified By			Changes
-- 07/27/2012   Aron E. Tekulsky    Initial Coding.
-- 02/16/2018	Aron E. Tekulsky	Update to V120.
-- 02/24/2018	Aron E. Tekulsky	Update to V140.
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

	SELECT TOP 1000 [wait_type],[waiting_tasks_count],[wait_time_ms],[max_wait_time_ms],[signal_wait_time_ms]
		FROM [master].[sys].[dm_os_wait_stats]
	WHERE wait_type like ('PAGELATCH%')
	 ORDER BY wait_type ASC;

END
GO
