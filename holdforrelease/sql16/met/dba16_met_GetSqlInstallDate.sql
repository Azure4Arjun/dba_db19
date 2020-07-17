SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_GetSqlInstallDate
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 09/01/2016   Aron E. Tekulsky    Initial Coding.
-- 03/04/2018   Aron E. Tekulsky    Update to V140.
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

	SELECT createdate, *
		FROM syslogins
	WHERE sid = 0x010100000000000512000000;

END
GO
