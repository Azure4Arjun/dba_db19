SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetStartup_proceduresOnOffST
--
--
-- Calls:		None
--
-- Description:	Scan for startup procedures.
--
-- https://www.mssqltips.com/sqlservertip/1574/automatically-running-stored-procedures-at-sql-server-startup/
-- 
-- Date			Modified By			Changes
-- 08/14/2020   Aron E. Tekulsky    Initial Coding.
-- 08/14/2020   Aron E. Tekulsky    Update to Version 150.
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

	------USE MASTER
	
	SELECT VALUE, VALUE_IN_USE, DESCRIPTION 
		FROM SYS.CONFIGURATIONS 
	WHERE NAME = 'scan for startup procs';
	
END
GO
