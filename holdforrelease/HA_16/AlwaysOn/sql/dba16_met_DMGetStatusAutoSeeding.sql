SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_DMGetStatusAutoSeeding
--
--
-- Calls:		None
--
-- Description:	Check the status of the automatic seeding process.
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
			completion_time
			is_source,
			current_state,
			failure_state,
			failure_state_desc
		FROM sys.dm_hadr_automatic_seeding;
END
GO
