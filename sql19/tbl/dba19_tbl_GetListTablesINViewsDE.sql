SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GetListTablesINViewsDE
--
--
-- Calls:		None
--
-- Description:	Get a list of all of the views in a database and each table that
--				is a part of the view.
--
-- https://dataedo.com/kb/query/sql-server/list-tables-used-by-a-view
-- 
-- Date			Modified By			Changes
-- 09/24/2020   Aron E. Tekulsky    Initial Coding.
-- 09/24/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT DISTINCT schema_name(v.schema_id) AS schema_name,
		   v.name AS view_name,
		   schema_name(o.schema_id) AS referenced_schema_name,
		   o.name AS referenced_entity_name,
		   o.type_desc AS entity_type
		FROM sys.views v
			JOIN sys.sql_expression_dependencies d ON( d.referencing_id = v.object_id)
												AND (d.referenced_id IS NOT NULL)
			JOIN sys.objects o ON (o.object_id = d.referenced_id)
	 ORDER BY schema_name, view_name;


END
GO
