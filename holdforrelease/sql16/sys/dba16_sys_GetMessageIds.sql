SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetMessageIds
--
--
-- Calls:		None
--
-- Description:	Get a listing of the system messagers
-- 
-- Date			Modified By			Changes
-- 04/23/2012   Aron E. Tekulsky    Initial Coding.
-- 10/25/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT name, message_id, performance_condition, has_notification, Enabled
		FROM msdb.dbo.sysalerts 
	ORDER BY message_id ASC;

END
GO
