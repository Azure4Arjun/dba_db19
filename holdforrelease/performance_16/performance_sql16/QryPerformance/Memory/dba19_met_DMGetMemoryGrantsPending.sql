SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_DMGetMemoryGrantsPending
--
--
-- Calls:		None
--
-- Description:	This query determines Memory Grants Pending value for current instance.
--				SQL Server Customer Advisory Team recommends that the value of this 
--				measurement should always be less or equal to 1. Anything above that 
--				indicates that there are processes waiting for memory and that you 
--				should probably increase the memory allocated to SQL Server.
-- 
--				Memory Grants Pending above zero for a sustained period is a very 
--				strong indicator of internal memory pressure.
--
-- https://malapatidatabase.wordpress.com/2018/04/29/memory-grants-pending/
**
-- Date			Modified By			Changes
-- 10/08/2019   Aron E. Tekulsky    Initial Coding.
-- 10/08/2019   Aron E. Tekulsky    Update to Version 150.
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

	SELECT 'Memory Grants Pending', @@SERVERNAME AS [Server Name], RTRIM([object_name]) AS [Object Name],
			cntr_value AS [Memory Grants Pending]                                                                                                      
		FROM sys.dm_os_performance_counters WITH (NOLOCK)
	WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
		AND counter_name = N'Memory Grants Pending' OPTION (RECOMPILE);
END
GO
