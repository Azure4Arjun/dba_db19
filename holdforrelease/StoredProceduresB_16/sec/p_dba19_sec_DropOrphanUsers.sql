SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sec_DropOrphanUsers
--
-- Arguments:	@username VARCHAR(25)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Find orphaned user ids and remove them.
-- 
-- Date			Modified By			Changes
-- 11/05/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 03/18/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sec_DropOrphanUsers 
	-- Add the parameters for the stored procedure here
	@username VARCHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	CREATE TABLE #temp
		(orphanuser varchar(25))

-- insert rows into temp table.
	INSERT INTO #temp 
		SELECT name 
			FROM sys.sysusers
		WHERE issqluser = 1
			AND (sid IS NOT NULL
			AND sid <> 0x00)
			AND SUSER_SNAME(sid) IS NULL
		ORDER BY name;

	SELECT * FROM #temp;

-- declare the cursor
	DECLARE check_orphan CURSOR FOR
		SELECT * FROM #temp;

-- open the cursor
	OPEN check_orphan;

-- fetch the first row
	FETCH NEXT FROM check_orphan 
		INTO @username;

	WHILE @@FETCH_STATUS = 0
		BEGIN

			IF @username='dbo'
-- remove dbo status form orphaned user
				EXEC sp_changedbowner 'sa';
			ELSE
-- drop orphaned user
				EXEC sp_dropuser @username;

			PRINT 'deleting ' +@username+ ' from database';

-- fetch the next row
			FETCH NEXT FROM check_orphan 
				INTO @username;

		END

	DROP TABLE #temp;

	CLOSE check_orphan;
	DEALLOCATE check_orphan;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON p_dba19_sec_DropOrphanUsers TO [db_proc_exec] AS [dbo]
GO
