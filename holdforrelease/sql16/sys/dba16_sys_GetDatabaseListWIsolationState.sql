SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- db16_sys_GetDatabaseListWIsolationState
--
--
-- Calls:		None
--
-- Description:	Get a listing of all databases including the isolation level.
-- 
-- Date			Modified By			Changes
-- 08/27/2013   Aron E. Tekulsky    Initial Coding.
-- 08/16/2018   Aron E. Tekulsky    Update to Version 140.
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

	SELECT 
			d.name , d.create_date , d.compatibility_level , d.collation_name , d.recovery_model_desc , d.snapshot_isolation_state_desc , d.is_read_committed_snapshot_on 
		FROM sys.databases d
	WHERE d.database_id > 5
;

END
GO
