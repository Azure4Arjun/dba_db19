SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_xev_StopTracesBO
--
--
-- Calls:		None
--
-- Description:	To stop and remove your trace, you’ll need to run queries like this.
--
-- https://www.brentozar.com/archive/2013/08/what-queries-are-failing-in-my-sql-server/
-- 
-- Date			Modified By			Changes
-- 11/19/2019   Aron E. Tekulsky    Initial Coding.
-- 11/19/2019   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Stop your Extended Events session
ALTER EVENT SESSION what_queries_are_failing ON SERVER
STATE = STOP;
GO

-- Clean up your session from the server
DROP EVENT SESSION what_queries_are_failing ON SERVER;
GO
END
GO
