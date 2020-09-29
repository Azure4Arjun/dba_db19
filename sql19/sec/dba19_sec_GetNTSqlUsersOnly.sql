SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sec_GetNTSqlUsersOnly
--
--
-- Calls:		None
--
-- Description:	Get a listing of all of the NT sql users.
-- 
-- Date			Modified By			Changes
-- 11/24/2010   Aron E. Tekulsky    Initial Coding.
-- 10/25/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT l.name, l.sid, l.status, l.loginname,
			u.name, u.status, u.*
		FROM sys.syslogins l
			JOIN sys.sysusers u ON (u.sid = l.sid)
	WHERE u.isntuser = 1 or u.issqluser=1 or u.isntgroup=1;

END
GO
