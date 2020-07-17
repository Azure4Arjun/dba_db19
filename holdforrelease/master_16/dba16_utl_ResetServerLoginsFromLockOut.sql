SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_ResetServerLoginsFromLockOut
--
--
-- Calls:		None
--
-- Description:	Reset the server from lockout and create a dba emergency account.
--
--	EMERGENCY RESET SA                 
--	                                   
--	1 - stop sql server.
--	2 - set to -m flag in config manager
--		single user mode.
--	3 start sqlserver only.
--	4 - alter sa to reenable.
--	5 - reset sa pw.
--	6 - create dbaemergencyid.
--
--	*** Run in SQLCMD mode ***
-- 
-- Date			Modified By			Changes
-- 08/03/2016   Aron E. Tekulsky    Initial Coding.
-- 02/05/2018   Aron E. Tekulsky    Update to V140.
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
