SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_idx_GetDetailedPKIndexColumnList
--
--
-- Calls:		None
--
-- Description:	Get a detailed listing of all primary key indexes.
-- 
-- Date			Modified By			Changes
-- 11/15/2013   Aron E. Tekulsky    Initial Coding.
-- 08/11/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT o.name AS tablename, i.type_desc, i.type, c.object_id, c.index_id,
			c.index_column_id, c.column_id,
			i.name AS pkname, o.type_desc,
			s.name AS columnname, s.user_type_id,s.column_id, t.name AS
			datatyp, o.type
		FROM sys.indexes i
			LEFT JOIN sys.index_columns c ON (c.object_id = i.object_id) AND
											(c.index_id = i.index_id)
		-- LEFT JOIN sys.all_objects o ON (o.object_id = i.object_id)
			LEFT JOIN sys.objects o ON (o.object_id = i.object_id)
			LEFT JOIN sys.columns s ON ( c.object_id = s.object_id) AND
										(c.column_id = s.column_id)
			LEFT JOIN sys.types t ON (s.user_type_id = t.user_type_id)
	WHERE o.type = 'U' --AND
		----------i.type = 1
		--and o.name = 'svs_program_action_remarks'
	ORDER BY i.type_desc ASC, o.name ASC, c.index_id ASC, c.index_column_id ASC;

END
GO
