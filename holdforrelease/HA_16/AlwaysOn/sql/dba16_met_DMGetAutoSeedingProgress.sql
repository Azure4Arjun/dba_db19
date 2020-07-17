SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_DMGetAutoSeedingProgress
--
--
-- Calls:		None
--
-- Description:	Monitor the seeding progress.
-- 
-- Date			Modified By			Changes
-- 01/26/2018   Aron E. Tekulsky    Initial Coding.
-- 01/26/2018   Aron E. Tekulsky    Update to V140.
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

	SELECT start_time,
			ag.name,
			db.database_name,
			current_state,
			performed_seeding,
				failure_state,
		failure_state_desc
		FROM sys.dm_hadr_automatic_seeding autos 
			JOIN sys.availability_databases_cluster db  ON autos.ag_db_id = db.group_database_id
			JOIN sys.availability_groups ag ON autos.ag_id = ag.group_id;
END
GO
