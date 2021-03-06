SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetAllDatabaseRestoresDevices
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get a listing of restored done on all databases
--				including devices restored to. 
-- 
-- Date			Modified By			Changes
-- 11/19/2008   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 03/18/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2018   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetAllDatabaseRestoresDevices 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT h.restore_history_id, h.restore_date, h.destination_database_name, h.user_name, h.backup_set_id,
			h.restore_type, h.replace, h.recovery, h.restart, h.stop_at, h.device_count, h.stop_at_mark_name,
			h.stop_before, f.destination_phys_drive, f.destination_phys_name
		FROM msdb.dbo.restorehistory h
			JOIN msdb.dbo.restorefile f ON (h.restore_history_id = f.restore_history_id)
	ORDER BY h.destination_database_name ASC, restore_date DESC;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetAllDatabaseRestoresDevices TO [db_proc_exec] AS [dbo]
GO
