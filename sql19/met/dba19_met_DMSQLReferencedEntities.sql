SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_DMSQLReferencedEntitiesMS
--
--
-- Calls:		None
--
-- Description:	Returns one row for each user-defined entity that is referenced by 
--				name in the definition of the specified referencing entity in SQL Server
-- 
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-sql-referenced-entities-transact-sql?view=sql-server-ver15
--
-- Date			Modified By			Changes
-- 02/07/2020   Aron E. Tekulsky    Initial Coding.
-- 02/07/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd				nvarchar(4000)
	DECLARE	@ClassToGet			nvarchar(128)	-- OBJECT, DATABASE_DDL_TRIGGER, SERVER_DDL_TRIGGER
	DECLARE @ReferencingEntity	nvarchar(128)	-- table, sp, function
	DECLARE @ReferencingSchema	nvarchar(128)

	-- Initialize

	SET @ReferencingSchema	=	'dbo';
	SET @ReferencingEntity	=	'Table_1';
	SET @ClassToGet			=	'OBJECT';

	SET @Cmd = '
			SELECT ' +
				'referenced_server_name, 
				referenced_database_name,
				referenced_schema_name,
				referenced_entity_name,
				referenced_minor_name,
				referenced_minor_id,
				referenced_class_desc,
				is_caller_dependent,
				is_ambiguous,
				is_select_all--,
				----is_insert_all,
				----is_incomplete
				FROM sys.dm_sql_referenced_entities (' + '''' + @ReferencingSchema + 
					'.' + @ReferencingEntity + '''' + ' , ' + '''' + @ClassToGet + '''' + ')' + 
					' ORDER BY referenced_server_name, referenced_entity_name ASC' + ';';

	PRINT @Cmd;

	EXEC SP_EXECUTESQL @Cmd;

END
GO
