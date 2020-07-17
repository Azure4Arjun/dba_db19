SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_tbl_GetTablesWFileGroups
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 04/24/2018 Aron E. Tekulsky Initial Coding..
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

	SELECT tbl.name AS [Table Name],
			CASE
				WHEN dsidx.type='FG' THEN dsidx.name
				ELSE '(Partitioned)' END AS [File Group]
		FROM sys.tables AS tbl
			JOIN sys.indexes AS idx ON idx.object_id = tbl.object_id
										AND idx.index_id <= 1
			LEFT JOIN sys.data_spaces AS dsidx ON dsidx.data_space_id = idx.data_space_id
	ORDER BY [File Group], [Table Name];

END
GO
