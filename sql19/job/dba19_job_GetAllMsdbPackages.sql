SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_job_GetAllMsdbPackages
--
--
-- Calls:		None
--
-- Description:	Get a list of all of the packages stored in msdb.
-- 
-- Date			Modified By			Changes
-- 01/25/2013   Aron E. Tekulsky    Initial Coding.
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

	SELECT f.foldername, 
		p.name, p.description, p.createdate, p.ownersid, p.packagetype, p.vermajor, p.verminor, p.verbuild,
		l.loginname
	FROM msdb.dbo.sysssispackagefolders f
		JOIN msdb.dbo.sysssispackages p ON (p.folderid = f.folderid)
		JOIN msdb.sys.syslogins l ON (p.ownersid = l.sid)
	ORDER BY f.foldername ASC, p.name ASC;

END
GO
