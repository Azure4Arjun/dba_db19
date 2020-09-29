SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_TruncateAllTables
--
--
-- Calls:		None
--
-- Description:	Generate a list of truncate statements for all tables in the db.
-- 
-- Date			Modified By			Changes
-- 01/13/2010   Aron E. Tekulsky    Initial Coding.
-- 11/07/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @cmd			nvarchar(4000),
			@return_code	int,
			@tabl_name		nvarchar(128)
			


	DECLARE tr_table_cur CURSOR FOR
		SELECT o.name
			FROM sys.objects o
		 WHERE o.type = 'U' AND
			 o.name NOT LIKE ('sys%')
		ORDER BY o.name ASC;
  
	 OPEN tr_table_cur;
  
	FETCH NEXT FROM tr_table_cur
		INTO
			@tabl_name;
	
	WHILE (@@fetch_status = 0)
		BEGIN
	
		--SET @cmd = 'TRUNCATE TABLE dbo.' + @tabl_name + ';'
			SET @cmd = 'TRUNCATE TABLE ' + @tabl_name + ';'
		
			PRINT @cmd;
		
		 --EXEC @return_code = @cmd;
			 --EXEC (@cmd);
		
		  FETCH NEXT FROM tr_table_cur
			 INTO
				@tabl_name;
		END

	CLOSE tr_table_cur;

	DEALLOCATE tr_table_cur;

--GRANT EXECUTE ON [dbo].[p_dba_stealth_get_disabled_jobs] TO [db_proc_exec] AS [dbo]
--GO

END
GO
