SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_dba_UpdateDBOwners
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	update db owner
-- 
-- Date			Modified By			Changes
-- 09/17/2010	Aron E. Tekulsky	Initial Coding.
-- 05/04/2012	Aron E. Tekulsky	Update to v100.
-- 06/17/2019   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_dba_UpdateDBOwners 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.dba_database_expiration
		SET db_owner = 'sa'
		FROM sys.databases d
			JOIN dba_db16.dbo.dba_database_expiration a ON (a.db_dbid = d.database_id )
			LEFT JOIN sys.syslogins l ON (l.sid = d.owner_sid)
	WHERE a.db_owner <> l.name;

	--FROM sys.databases d
	--	LEFT JOIN sys.syslogins l ON (l.sid = d.owner_sid)
	--WHERE db_dbid = d.database_id AND
	--	  db_owner <> l.name

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_dba_UpdateDBOwners TO [db_proc_exec] AS [dbo]
GO
