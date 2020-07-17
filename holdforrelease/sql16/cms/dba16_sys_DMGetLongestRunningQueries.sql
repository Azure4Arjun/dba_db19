SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_DMGetLongestRunningQueries
--
--
-- Calls:		None
--
-- Description:	get longest running queries.
-- 
-- Date			Modified By			Changes
-- 07/26/2011   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 01/02/2018   Aron E. Tekulsky    Update to V140.
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
	SELECT TOP 100
			qs.total_elapsed_time / qs.execution_count / 1000000.0 AS average_seconds,
		 qs.total_elapsed_time / 1000000.0 AS total_seconds,
			qs.execution_count,
			SUBSTRING (qt.text,qs.statement_start_offset/2, 
				   (CASE WHEN qs.statement_end_offset = -1 
					 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
					ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) AS individual_query,
			o.name AS object_name,
			DB_NAME(qt.dbid) AS database_name, 
			qt.dbid
		FROM sys.dm_exec_query_stats qs
			CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
			LEFT OUTER JOIN sys.objects o ON qt.objectid = o.object_id
	ORDER BY average_seconds DESC;


END
GO
