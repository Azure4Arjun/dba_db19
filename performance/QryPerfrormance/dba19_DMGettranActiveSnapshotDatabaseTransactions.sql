SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_DMGettranActiveSnapshotDatabaseTransactions
--
--
-- Calls:		None
--
-- Description:	Get active snapshot transactions in databases.
-- 
-- Date			Modified By			Changes
-- 09/14/2018   Aron E. Tekulsky    Initial Coding.
-- 09/17/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT GETDATE() AS
			runtime,a.*,b.kpid,b.blocked,b.lastwaittype,b.waitresource,db_name(b.dbid)
			as database_name,
			b.cpu,b.physical_io,b.memusage,b.login_time,b.last_batch,b.open_tran,b.status,b.hostname,b.program_name,b.cmd,b.loginame,request_id
		FROM sys.dm_tran_active_snapshot_database_transactions a
			INNER JOIN sys.sysprocesses b ON a.session_id = b.spid
	WHERE open_tran > 0
		AND elapsed_time_seconds > 60;

END
GO
