SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_GetRefrencedAll
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 10/12/2012   Aron E. Tekulsky    Initial Coding.
-- 10/25/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/24/2020   Aron E. Tekulsky    Update to Version 150.
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

	SET ANSI_NULLS ON;
	SET QUOTED_IDENTIFIER ON;


	DECLARE @cmd			nvarchar(4000)
	DECLARE @object_to_find nvarchar(517)


	DECLARE sp_cur CURSOR FOR
		SELECT o.name
			FROM sys.objects o
		--GROUP by o.type_desc
		WHERE o.type_desc = 'SQL_STORED_PROCEDURE';
	
	OPEN sp_cur;

	FETCH NEXT FROM sp_cur
		INTO @object_to_find;
	
	WHILE(@@fetch_status = 0)
		BEGIN
	
			SET @cmd = '
			SELECT referenced_schema_name, referenced_entity_name, referenced_minor_name, 
					referenced_minor_id, referenced_class_desc
				FROM sys.dm_sql_referenced_entities (' + '''' + 'dbo.' + @object_to_find + '''' + ', ' + '''' + 'OBJECT' + '''' + ')
			WHERE referenced_minor_id = 0 ;'--AND
			--referenced_schema_name IS NOT NULL;'
		
		--	PRINT @cmd
		
			EXEC (@cmd);
		
			IF @@ERROR <> 0 GOTO ErrorHandler

			goto nxtone

ErrorHandler:
				PRINT @cmd
				PRINT @@fetch_status

nxtone:
			FETCH NEXT FROM sp_cur
				INTO @object_to_find;

		END
	
	CLOSE sp_cur;

	DEALLOCATE sp_cur;

END
GO
