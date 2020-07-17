SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba14_dm_met_GetSQLRowCounts
--
--
-- Calls:		None
--
-- Description:	Get a list of tables and their row counts.
-- 
-- Date			Modified By			Changes
-- 12/19/2017   Aron E. Tekulsky    Initial Coding.
-- 12/25/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT c.name AS SchemaName , t.name AS TableName,s.row_count,
			s.used_page_count, s.reserved_page_count ,
			s.in_row_data_page_count , s.in_row_used_page_count ,
			s.in_row_reserved_page_count
		FROM sys.tables t
			INNER JOIN [sys].[schemas] c ON (c.schema_id = t.schema_id )
			INNER JOIN [sys].[dm_db_partition_stats] s ON	(s.object_id = t.object_id ) AND
															(s.index_id < 2)
		ORDER BY c.name ASC, t.name ASC;
END
GO
