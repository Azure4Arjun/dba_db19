SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- db16_DMGettranActiveSnapshotDatabaseTransactions
--
--
-- Calls:		None
--
-- Description:	Get active snapshot transactions in databases.
-- 
-- Date			Modified By			Changes
-- 09/14/2018   Aron E. Tekulsky    Initial Coding.
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
