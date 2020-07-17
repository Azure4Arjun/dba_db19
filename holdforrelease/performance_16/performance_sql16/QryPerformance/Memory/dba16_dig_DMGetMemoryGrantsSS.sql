SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetMemoryGrantsSS
--
--
-- Calls:		None
--
-- Description:	Get pending memory grants
--
--  https://www.sqlskills.com/blogs/glenn/category/dmv-queries/
-- 
-- Date			Modified By			Changes
-- 10/17/2019   Aron E. Tekulsky    Initial Coding.
-- 10/17/2019   Aron E. Tekulsky    Update to Version 140.
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

	-- Memory Grants Pending value for current instance  (Query 31) (Memory Grants Pending)
	-- Memory Grants Pending above zero for a sustained period is a very strong indicator of memory pressure
	SELECT @@SERVERNAME AS [Server Name], [object_name], cntr_value AS [Memory Grants Pending]                                                                                                       
		FROM sys.dm_os_performance_counters WITH (NOLOCK)
	WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
	AND counter_name = N'Memory Grants Pending' OPTION (RECOMPILE);

END
GO
