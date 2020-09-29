SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_DMGetSQLRowCounts
--
--
-- Calls:		None
--
-- Description:	Get a list of tables and their row counts.
-- 
-- Date			Modified By			Changes
-- 12/19/2017   Aron E. Tekulsky    Initial Coding.
-- 12/25/2017   Aron E. Tekulsky    Update to Version 140.
-- 09/14/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT @@ServerName AS ServerName, c.name AS SchemaName , t.name AS TableName,s.row_count AS RowCnt,
			s.used_page_count AS UsedPageCount, s.reserved_page_count AS ReservedPageCount ,
			(s.used_page_count*8)/1024 AS UsedTableSizeMbytes, (s.reserved_page_count*8)/ 1024 AS ReservedTableSizeMBytes,
			s.in_row_data_page_count AS InRowDataPageCount , s.in_row_used_page_count AS InRowUsedPageCount,
			s.in_row_reserved_page_count AS InRowReservedPageCount,
			t.is_replicated, t.lock_escalation_desc 
		FROM sys.tables t
			INNER JOIN [sys].[schemas] c ON (c.schema_id = t.schema_id )
			INNER JOIN [sys].[dm_db_partition_stats] s ON	(s.object_id = t.object_id ) AND
															(s.index_id < 2)
		ORDER BY c.name ASC, t.name ASC;

END
GO
