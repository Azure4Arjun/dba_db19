SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetIndexCountsFixed
--
--
-- Calls:		None
--
-- Description:	Get a listing of index counts with details.
-- 
-- Date			Modified By			Changes
-- 06/18/2012   Aron E. Tekulsky    Initial Coding.
-- 10/22/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT o.name as tablename, i.name as pkname, i.index_id, o.type_desc, 
		o.type, i.type, i.type_desc, i.is_unique, i.is_primary_key
		FROM sys.indexes i
			LEFT JOIN sys.objects o on (o.object_id = i.object_id)
	WHERE o.type = 'U'
	ORDER BY o.name ASC;
END
GO
