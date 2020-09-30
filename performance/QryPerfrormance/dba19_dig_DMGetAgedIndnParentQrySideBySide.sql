SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_dig_DMGetAgedIndnParentQrySideBySide
--
--
-- Calls:		None
--
-- Description:	Get a listing of the aged queries indvs parent side by side.
-- 
-- Date			Modified By			Changes
-- 05/06/2019   Aron E. Tekulsky    Initial Coding.
-- 05/06/2019   Aron E. Tekulsky    Update to Version 140.
-- 05/07/2019	Aron E. Tekulsky	Switch to all dmv's.
-- 10/04/2019	Aron E. Tekulsky	Add query plan to both.
-- 08/12/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT er.session_Id AS [Spid]
			, sp.ecid
			, er.start_time
			, DATEDIFF(SS,er.start_time,GETDATE()) as [Age Seconds]
			, sp.nt_username
			, er.status
			, er.wait_type
			, SUBSTRING (qt.text, (er.statement_start_offset/2) + 1,
			((CASE WHEN er.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
					ELSE er.statement_end_offset
			END - er.statement_start_offset)/2) + 1) AS [Individual Query]
			, qt.text AS [Parent Query]
			, sp.program_name
			, sp.Hostname
			, sp.nt_domain
			, er.command
			, er.cpu_time
			,er.total_elapsed_time
			,qp.query_plan
		FROM sys.dm_exec_requests er
			INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
			CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
			CROSS APPLY sys.dm_exec_query_plan (er.plan_handle ) as qp
	WHERE session_Id > 50
		AND session_Id NOT IN (@@SPID)
	ORDER BY session_Id, ecid;

		SELECT er.session_Id AS [Spid]
			------, sp.ecid -- ***
			,sp.open_transaction_count 
			, er.start_time
			, DATEDIFF(SS,er.start_time,GETDATE()) as [Age Seconds]
			, sp.nt_user_name-- ***
			, er.status
			, er.wait_type
			, SUBSTRING (qt.text, (er.statement_start_offset/2) + 1,
			((CASE WHEN er.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
					ELSE er.statement_end_offset
			END - er.statement_start_offset)/2) + 1) AS [Individual Query]
			, qt.text AS [Parent Query]
			, sp.program_name-- ***
			, sp.host_name   ---Hostname-- ***
			, sp.nt_domain-- ***
			, er.command
			, er.cpu_time
			,er.total_elapsed_time
			,qp.query_plan
		FROM sys.dm_exec_requests er
			------INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
			INNER JOIN sys.dm_exec_sessions  sp ON er.session_id = sp.session_id
			CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
			CROSS APPLY sys.dm_exec_query_plan (er.plan_handle ) as qp
	WHERE er.session_Id > 50
		AND er.session_Id NOT IN (@@SPID)
	ORDER BY er.session_Id;--, ecid;

END
GO
