USE [dba_db19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_dba_UpdateDatabaseExpirationRestore]    Script Date: 6/17/2019 9:49:35 AM ******/
DROP PROCEDURE [dbo].[p_dba19_dba_UpdateDatabaseExpirationRestore]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_dba_UpdateDatabaseExpirationRestore]    Script Date: 6/17/2019 9:49:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- p_dba19_dba_UpdateDatabaseExpirationRestore
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	update the restore information in the database 
--				expiration table.
-- 
-- Date			Modified By			Changes
-- 02/24/2010	Aron E. Tekulsky	Initial Coding.
-- 05/04/2012	Aron E. Tekulsky	Update to v100.
-- 06/17/2019   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE [dbo].[p_dba19_dba_UpdateDatabaseExpirationRestore] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    UPDATE dba_db19.dbo.dba_database_expiration
		SET db_restore_date = l.max_restore_date
    --SELECT e.name, e.db_restore_date, l.max_restore_date
    --SELECT e.name, e.db_restore_date, l.max_restore_date
    FROM dba_db19.dbo.dba_database_expiration e
		LEFT JOIN dbo.v_dba19_sys_LastRestore l ON (l.destination_database_name = e.name)
	WHERE e.db_restore_date <> l.max_restore_date

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON [dbo].[p_dba19_dba_UpdateDatabaseExpirationRestore] TO [db_proc_exec] AS [dbo]
GO


