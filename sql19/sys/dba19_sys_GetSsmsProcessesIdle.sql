SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetSsmsProcessesIdle
--
--
-- Calls:		None
--
-- Description:	Get a list of all ssms processes that are idle.
-- 
-- Date			Modified By			Changes
-- 05/11/2016   Aron E. Tekulsky    Initial Coding.
-- 10/31/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
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

    SELECT spid, lastwaittype, dbid, uid, login_time, last_batch,
     status, hostname, program_name, hostprocess, cmd,net_address, loginame
		FROM sys.sysprocesses
    WHERE lower(status) = 'sleeping' and
			lower(cmd) = 'awaiting command' AND
			lower(program_name) = 'microsoft sql server management studio'
			and
	        (datediff(hour, last_batch,current_timestamp)  > .5);

END
GO
