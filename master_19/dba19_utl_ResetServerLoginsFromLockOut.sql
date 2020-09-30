SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_ResetServerLoginsFromLockOut
--
--
-- Calls:		None
--
-- Description:	Reset the server from lockout and create a dba emergency account.
--
--				EMERGENCY RESET SA                 
--	                                   
--				1 - stop sql server.
--				2 - set to -m flag in config manager
--					single user mode.
--				3 - start sqlserver only.
--				4 - alter sa to reenable.
--				5 - reset sa pw.
--				6 - create dbaemergencyid.
--
--				*** Run in SQLCMD mode ***
-- 
-- Date			Modified By			Changes
-- 08/03/2016   Aron E. Tekulsky    Initial Coding.
-- 02/05/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
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

	USE [master]
	GO

	ALTER LOGIN [sa] ENABLE
	GO

	ALTER LOGIN [sa] WITH PASSWORD=N'@Password1'
	GO

	USE [master]
	GO

	CREATE LOGIN [dbaemergency] WITH PASSWORD=N'@Password1', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
	GO

	ALTER SERVER ROLE [sysadmin] ADD MEMBER [dbaemergency]
	GO


END
GO
