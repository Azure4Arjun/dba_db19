SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_idx_GetDetailedIndexColumnList
--
--
-- Calls:		None
--
-- Description:	Get a detailed listing of index columns
-- 
-- Date			Modified By			Changes
-- 06/19/2012   Aron E. Tekulsky    Initial Coding.
-- 10/16/2017   Aron E. Tekulsky    Update to Version 140.
-- 10/29/2019	Aron E. Tekulsky	Add to where clause to eliminate non key/indexes.
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

	SELECT o.name AS tablename, c.object_id, c.index_id, c.index_column_id, c.column_id,
               i.name AS pkname, o.type_desc, 
               s.name AS columnname, s.user_type_id,s.column_id,  t.name AS datatyp, o.type,
			   i.type_desc, i.type
		FROM sys.indexes i
			LEFT JOIN sys.index_columns c ON (c.object_id = i.object_id) AND
									(c.index_id = i.index_id)
--			LEFT JOIN sys.all_objects o ON (o.object_id = i.object_id)
			LEFT JOIN sys.objects o ON (o.object_id = i.object_id)
			LEFT JOIN sys.columns s ON ( c.object_id = s.object_id) AND
										(c.column_id = s.column_id)
			LEFT JOIN sys.types t ON (s.user_type_id = t.user_type_id)
	WHERE o.type = 'U'
		AND c.index_id IS NOT NULL
	--and o.name = 'ams_award_budget'
	ORDER BY o.name ASC, c.index_id ASC, c.index_column_id ASC;

END
GO
