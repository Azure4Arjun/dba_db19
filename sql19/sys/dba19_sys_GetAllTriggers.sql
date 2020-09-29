SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetAllTriggers
--
--
-- Calls:		None
--
-- Description:	Get a listing of all triggers in the databases.
-- 
-- Date			Modified By			Changes
-- 05/17/2012   Aron E. Tekulsky    Initial Coding.
-- 10/02/2017   Aron E. Tekulsky    Update to Version 140.
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

	DECLARE @cmd	nvarchar(4000)
	DECLARE @dbname	nvarchar(128)

	DECLARE db_cur CURSOR FOR
		SELECT name
			FROM sys.databases
		WHERE database_id > 4
		ORDER BY name ASC;
		
	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@dbname;
	
	
	WHILE (@@fetch_status = 0)
		BEGIN
	
			SET @cmd = 'select ' + '''' + @dbname + '''' + ',name, parent_class, parent_class_desc, type, type_desc, create_date, modify_date, is_disabled
							from ' + @dbname + '.sys.triggers ' + 
						'ORDER BY name ASC;'
					
			EXEC (@cmd);

			FETCH NEXT FROM db_cur INTO
				@dbname;
		END
	
	CLOSE db_cur;
	DEALLOCATE db_cur;

END
GO
