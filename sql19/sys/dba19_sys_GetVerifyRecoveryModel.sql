SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetVerifyRecoveryModel
--
--
-- Calls:		None
--
-- Description:	Get a listing of each database and its recovery model.
-- 
-- Date			Modified By			Changes
-- 05/16/2013   Aron E. Tekulsky    Initial Coding.
-- 11/05/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT s.name , s.recovery_model, s.recovery_model_desc, r.last_log_backup_lsn,
		CASE
			WHEN s.recovery_model = 1 AND (r.last_log_backup_lsn IS NOT NULL) THEN
		'*** Really Full Recovery Model ***'
		END
		FROM sys.database_recovery_status r
			JOIN sys.databases s ON (s.database_id = r.database_id );

END
GO
