SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetPLE
--
--
-- Calls:		None
--
-- Description:	Get the Page Life Expectancy of ther DB server.
-- 
-- Date			Modified By			Changes
-- 02/18/2018   Aron E. Tekulsky    Initial Coding.
-- 02/18/2018   Aron E. Tekulsky    Update to V140.
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

	SELECT [object_name],
			[counter_name],
			[cntr_value] 
		FROM sys.dm_os_performance_counters
	WHERE [object_name] LIKE '%Manager%'
		AND [counter_name] = 'Page life expectancy';
END
GO
