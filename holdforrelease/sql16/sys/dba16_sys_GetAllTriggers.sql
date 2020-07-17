SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetAllTriggers
--
--
-- Calls:		None
--
-- Description:	Get a listing of all triggers in teh databses.
-- 
-- Date			Modified By			Changes
-- 05/17/2012   Aron E. Tekulsky    Initial Coding.
-- 10/02/2017   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

-- get all triggers
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
