SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_idx_GetDetailedNonClusteredIndexColumnList
--
--
-- Calls:		None
--
-- Description:	Get a detailed listing of non cllustered index.
-- 
-- Date			Modified By			Changes
-- 06/19/2012   Aron E. Tekulsky    Initial Coding.
-- 10/16/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/11/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT o.name as tablename, c.object_id, c.index_id, c.index_column_id, c.column_id,
               i.name as pkname, o.type_desc, 
               s.name as columnname, s.user_type_id,s.column_id,  t.name as datatyp, o.type,
			   i.type_desc, i.type
		FROM sys.indexes i
			LEFT JOIN sys.index_columns c on (c.object_id = i.object_id) AND
											(c.index_id = i.index_id)
--			LEFT JOIN sys.all_objects o on (o.object_id = i.object_id)
			LEFT JOIN sys.objects o on (o.object_id = i.object_id)
			LEFT JOIN sys.columns s on ( c.object_id = s.object_id) AND
										(c.column_id = s.column_id)
			LEFT JOIN sys.types t on (s.user_type_id = t.user_type_id)
	WHERE o.type = 'U' AND
		i.type <> 1
--and o.name = 'eft_payments'
	ORDER BY o.name ASC, c.index_id ASC, c.index_column_id asc;

END
GO
