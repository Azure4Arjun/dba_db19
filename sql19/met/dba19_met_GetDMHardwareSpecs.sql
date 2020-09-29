SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_GetDMHardwareSpecs
--
--
-- Calls:		None
--
-- Description:	Get a listing of all the Hardware Specs for the server.
-- 
-- Date			Modified By			Changes
-- 01/09/2016   Aron E. Tekulsky    Initial Coding.
-- 01/09/2016   Aron E. Tekulsky    Update to Version 140.
-- 08/24/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio]
			,cpu_count/hyperthread_ratio AS [Physical CPU Count]
			,physical_memory_kb/1048576 AS [Physical Memory (MB)]
			,sqlserver_start_time
		FROM sys.dm_os_sys_info;

END
GO
