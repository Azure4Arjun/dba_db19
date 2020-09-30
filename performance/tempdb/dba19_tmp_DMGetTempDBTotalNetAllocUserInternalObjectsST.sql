SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tmp_DMGetTempDBTotalNetAllocUserInternalObjectsST
--
--
-- Calls:		None
--
-- Description:	Show the total and net allocation of both user and internal
--				objects in tempdb.
--
-- https://www.mssqltips.com/sqlservertip/4356/track-sql-server-tempdb-space-usage/
-- 
-- Date			Modified By			Changes
-- 12/05/2018	Aron E. Tekulsky	Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT SS.session_id
			,SS.database_id
			,CAST(SS.user_objects_alloc_page_count / 128 AS DECIMAL(15, 2)) [Total Allocation User Objects MB]
			,CAST((SS.user_objects_alloc_page_count - SS.user_objects_dealloc_page_count) / 128 AS DECIMAL(15, 2)) [Net Allocation User Objects MB]
			,CAST(SS.internal_objects_alloc_page_count / 128 AS DECIMAL(15, 2)) [Total Allocation Internal Objects MB]
			,CAST((SS.internal_objects_alloc_page_count - SS.internal_objects_dealloc_page_count) / 128 AS DECIMAL(15, 2)) [Net Allocation Internal Objects MB]
			,CAST((SS.user_objects_alloc_page_count + internal_objects_alloc_page_count) / 128 AS DECIMAL(15, 2)) [Total Allocation MB]
			,CAST((SS.user_objects_alloc_page_count + SS.internal_objects_alloc_page_count - SS.internal_objects_dealloc_page_count - SS.user_objects_dealloc_page_count) / 128 AS DECIMAL(15, 2)) [Net Allocation MB]
			,T.TEXT [Query Text]
		FROM sys.dm_db_session_space_usage SS
			LEFT JOIN sys.dm_exec_connections CN ON CN.session_id = SS.session_id
			OUTER APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) T;

END
GO
