SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tmp_DMGetTempDBSpaceUsed
--
--
-- Calls:		None
--
-- Description:	Determine how much of tempdb was used.
-- 
-- https://dbtut.com/index.php/2018/06/25/which-queries-fill-the-tempdb/
--
-- Date			Modified By			Changes
-- 03/06/2020   Aron E. Tekulsky    Initial Coding.
-- 03/06/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT SUM(unallocated_extent_page_count) AS [free pages], 
			(SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
		FROM sys.dm_db_file_space_usage;
 
END
GO
