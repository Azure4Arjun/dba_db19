SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_mem_DMGetOSMemoryAmountsSS
--
--
-- Calls:		None
--
-- Description:	Good basic information about OS memory amounts and state.
-- 
-- https://www.dropbox.com/s/p1urkrq5v01cuw3/SQL%20Server%202019%20Diagnostic%20Information%20Queries.sql?dl=0
--
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

	SELECT 'OS Memory Amounts' AS ReportName,total_physical_memory_kb/1024 AS [Physical Memory (MB)], 
			   available_physical_memory_kb/1024 AS [Available Memory (MB)], 
			   total_page_file_kb/1024 AS [Total Page File (MB)], 
			   available_page_file_kb/1024 AS [Available Page File (MB)], 
			   system_cache_kb/1024 AS [System Cache (MB)],
			   system_memory_state_desc AS [System Memory State]
		FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);
END
GO
