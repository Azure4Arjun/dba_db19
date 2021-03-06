SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_FindDuplicateLogicalNames
--
--
-- Calls:		None
--
-- Description:	find duplicate logical names on multiple db's.
-- 
-- Date			Modified By			Changes
-- 05/31/2005   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT d.name as dbname, a.dbid, a.name, a.filename, b.name, b.filename
		FROM sysaltfiles a 
			LEFT JOIN sysdatabases d ON (a.dbid = d.dbid)
			LEFT JOIN sysaltfiles b ON (a.name = b.name) AND
									   (a.dbid <> b.dbid)
	WHERE b.name is NOT NULL
	ORDER BY a.name;

END
GO
