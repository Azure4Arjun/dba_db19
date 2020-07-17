SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_SetAGSessionTimeout
--
--
-- Calls:		None
--
-- Description:	Set the timeout vcvalue of the AG.
-- 
-- Date			Modified By			Changes
-- 08/06/2018   Aron E. Tekulsky    Initial Coding.
-- 02/16/2019   Aron E. Tekulsky    Update to Version 140.
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

	ALTER AVAILABILITY GROUP AccountsAG
		MODIFY REPLICA ON 'INSTANCE09' WITH (SESSION_TIMEOUT = 15);

END
GO
