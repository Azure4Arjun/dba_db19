SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_SearchStoredProcedureCode
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/01/2020   Aron E. Tekulsky    Initial Coding.
-- 05/01/2020   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @Cmd			nvarchar(4000)
	DECLARE @DBName			nvarchar(128)
	DECLARE @ObjectToFind	nvarchar(128)

	-- Initialize
	SET @ObjectToFind = 'system_config_values';
	SET @DBName = 'dba_db16';

	SET @Cmd = '
		SELECT p.name,
				p.object_id,
				p.schema_id,
				p.type,
				p.type_desc,
				p.create_date,
				p.modify_date,
				m.definition
			FROM [' + @DBName + '].[sys].[procedures] p
				JOIN [' + @DBName + '].[sys].[sql_modules] m ON (m.object_id = p.object_id)
		WHERE m.definition LIKE (' + '''' + '%' + @ObjectToFind + '%' + '''' + ');';

	PRINT @Cmd;

	EXEC @Cmd;


END
GO
