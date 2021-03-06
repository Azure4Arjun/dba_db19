SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetMemoryStatusBasicSS
--
--
-- Calls:		None
--
-- Description:	Get basic memory status.
--
-- https://www.sqlskills.com/blogs/glenn/category/dmv-queries/
-- 
-- Date			Modified By			Changes
-- 10/17/2019   Aron E. Tekulsky    Initial Coding.
-- 10/17/2019   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
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

	SELECT total_physical_memory_kb/1024 AS [Physical Memory (MB)], 
		   available_physical_memory_kb/1024 AS [Available Memory (MB)], 
		   total_page_file_kb/1024 AS [Total Page File (MB)], 
		   available_page_file_kb/1024 AS [Available Page File (MB)], 
		   system_cache_kb/1024 AS [System Cache (MB)],
		   system_memory_state_desc AS [System Memory State]
		FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);

END
GO
