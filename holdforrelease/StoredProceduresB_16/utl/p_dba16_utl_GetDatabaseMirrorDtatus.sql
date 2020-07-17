USE [dba_db16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_utl_GetDatabaseMirrorDtatus]    Script Date: 7/27/2019 1:42:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- p_dba16_utl_GetDatabaseMirrorDtatus
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	compare status in databse expiration table to actual database
--				 status. primary vs mirror.
-- 
-- Date			Modified By			Changes
-- 09/29/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 03/23/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE [dbo].[p_dba16_utl_GetDatabaseMirrorDtatus] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @hold_dbname			nvarchar(1000),
			@hold_dbid				int,
			@hold_dbstatus			char(1),
			@hold_mirror_state_desc	nvarchar(100),
			@new_dbstatus			char(1),
			@new_dbid				int,
			@new_name				nvarchar(1000)
		
    -- Insert statements for procedure here
	DECLARE mir_cur CURSOR FOR
		SELECT d.name, ISNULL(substring(a.mirroring_role_desc,1,1),'A') as db_status, 
			   a.mirroring_state_desc, d.database_id
			FROM sys.sysdatabases d 
				JOIN sys.sysdatabase_mirroring a on (d.database_id = a.database_id);
				--where a.mirroring_guid IS NOT NULL and
				--m.database_id = 6 and

-- open the cursor
	OPEN mir_cur;

-- fetch the first row
	FETCH NEXT FROM mir_cur INTO
		@hold_dbname, @hold_dbstatus, @hold_mirror_state_desc, @hold_dbid;
		
	WHILE(@@FETCH_STATUS = 0)
		BEGIN
			SELECT @new_name = e.name, @new_dbid = e.db_dbid, @new_dbstatus = e.db_status
				FROM dba_db16.dbo.dba_database_expiration e
			WHERE e.db_dbid = @hold_dbid;

			--SELECT @new_dbstatus = newdbstatus
			
		-- test for match on status
		IF @new_dbstatus <> @hold_dbstatus
			BEGIN
				PRINT @new_name + ' dbstatus = ' + ' ' + @new_dbstatus +  ' *** ' +
				' ' + @hold_dbname + ' hold db status = ' + @hold_dbstatus;
			END
		
			FETCH NEXT FROM mir_cur INTO
				@hold_dbname, @hold_dbstatus, @hold_mirror_state_desc, @hold_dbid;
		END
		
	CLOSE mir_cur;
	DEALLOCATE mir_cur;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON [dbo].[p_dba16_utl_GetDatabaseMirrorDtatus] TO [db_proc_exec] AS [dbo]
GO


