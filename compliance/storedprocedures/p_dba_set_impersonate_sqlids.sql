USE [dba_db]
GO

/****** Object:  StoredProcedure [dbo].[p_dba_set_impersonate_sqlids]    Script Date: 9/7/2012 12:26:25 PM ******/
DROP PROCEDURE [dbo].[p_dba_set_impersonate_sqlids]
GO

/****** Object:  StoredProcedure [dbo].[p_dba_set_impersonate_sqlids]    Script Date: 9/7/2012 12:26:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- p_dba_set_impersonate_sqlids
--
-- Arguments:	None
--				None
--
-- Called BY:	None
--
-- Description:	Find all sql id's and grant impersonate on soxuser for them.
-- 
-- Date			Modified By			Changes
-- 09/07/2012   Aron E. Tekulsky    Initial Coding.
-- =============================================
CREATE PROCEDURE [dbo].[p_dba_set_impersonate_sqlids] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @cmd	nvarchar(4000)
	DECLARE @name	nvarchar(128)
	
	DECLARE db_cur CURSOR FOR
			SELECT p.name
				FROM sys.server_principals p
			WHERE p.type = 'S' AND
				p.name <> 'soxuser' and
				is_disabled = 0
			ORDER BY p.type, p.name ASC;
		
	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@name;
	
	WHILE (@@fetch_status = 0)
		BEGIN




			SET @cmd = 'use [master] ; '  
			
			SET @cmd = @cmd + 'GRANT IMPERSONATE ON login::[soxuser] TO ['  + @name + '];'
			
			print @cmd
			
			EXEC (@cmd);
			
			FETCH NEXT FROM db_cur INTO
				@name;
		END
	
	CLOSE db_cur;
	DEALLOCATE db_cur;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END

GO

GRANT EXECUTE ON [dbo].[p_dba_set_impersonate_sqlids] TO [db_proc_exec] AS [dbo]
GO


