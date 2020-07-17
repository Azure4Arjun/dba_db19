SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetBufferMgrStats
--
--
-- Calls:		None
--
-- Description:	Get the buffer stats
-- 
--				NOTE:  requires VIEW SERVER STATE permission.
--
-- Date			Modified By			Changes
-- 07/27/2012   Aron E. Tekulsky    Initial Coding.
-- 02/01/2018   Aron E. Tekulsky    Update to V140.
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
	SELECT TOP 1000 [object_name],[counter_name],[instance_name],[cntr_value],[cntr_type]
		FROM [master].[sys].[dm_os_performance_counters]
	WHERE object_name LIKE ('%Buffer Manager%')
	ORDER BY [counter_name] ASC;


END
GO
