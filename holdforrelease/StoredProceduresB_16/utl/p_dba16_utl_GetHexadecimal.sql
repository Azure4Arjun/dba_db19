USE [dba_db16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_dba_CleanBadDBIid]    Script Date: 6/17/2019 11:33:53 AM ******/
DROP PROCEDURE [dbo].[p_dba16_dba_CleanBadDBIid]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_dba_CleanBadDBIid]    Script Date: 6/17/2019 11:33:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- p_dba16_dba_CleanBadDBIid
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Clean up rows in database expiration table with dbid not matching sys.databases.
-- 
-- Date			Modified By			Changes
-- 08/02/2011   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 02/15/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE [dbo].[p_dba16_dba_CleanBadDBIid] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @currentdb	nvarchar(128)
	DECLARE	@cmd		nvarchar(4000)

	DECLARE db_cur CURSOR FOR
		SELECT e.name --, e.db_dbid, e.db_cr_date, s.database_id
			FROM dbo.dba_database_expiration e
				JOIN sys.databases s ON (s.name = e.name)
		WHERE s.database_id <> e.db_dbid;

	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO @currentdb;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN

			PRINT 'DELETE FROM  dbo.dba_database_expiration WHERE name = ''' + @currentdb + '''';

			SET @cmd = 'DELETE FROM  dbo.dba_database_expiration WHERE name = ''' + @currentdb + '''';

			EXEC (@cmd);


			FETCH NEXT FROM db_cur
				INTO @currentdb;

		END

	CLOSE db_cur;
	DEALLOCATE db_cur;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON [dbo].[p_dba16_dba_CleanBadDBIid] TO [db_proc_exec] AS [dbo]
GO


