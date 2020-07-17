SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetAgedRunningQry
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/06/2019   Aron E. Tekulsky    Initial Coding.
-- 05/06/2019   Aron E. Tekulsky    Update to Version 140.
-- 10/04/2019	Aron E. Tekulsky	Add query plan.
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

------USE master
------GO

	SELECT er.session_Id AS [Spid]
			,sp.ecid
			,er.start_time
			,DATEDIFF(SS, er.start_time, GETDATE()) AS [Age Seconds]
			,sp.nt_username
			,er.STATUS
			,er.wait_type
			,SUBSTRING(qt.TEXT, (er.statement_start_offset / 2) + 1, (
			(
				CASE 
					WHEN er.statement_end_offset = - 1
						THEN LEN(CONVERT(NVARCHAR(MAX), qt.TEXT)) * 2
					ELSE er.statement_end_offset
					END - er.statement_start_offset
				) / 2
			) + 1) AS [Individual Query]
			,qt.TEXT AS [Parent Query]
			,sp.program_name
			,sp.Hostname
			,sp.nt_domain
			,er.command
			,er.cpu_time
			,er.total_elapsed_time
			,qp.query_plan
		FROM sys.dm_exec_requests er
			INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
			CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
			CROSS APPLY sys.dm_exec_query_plan  (er.plan_handle) as qp
	WHERE session_Id > 50
		AND session_Id NOT IN (@@SPID)
	ORDER BY session_Id,ecid;
END
GO
