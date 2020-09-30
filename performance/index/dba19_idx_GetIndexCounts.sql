SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_idx_GetIndexCounts
--
--
-- Calls:		None
--
-- Description:	Get a listing of indexes and counts.
-- 
-- Date			Modified By			Changes
-- 06/14/2012   Aron E. Tekulsky    Initial Coding.
-- 10/22/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT o.name AS tablename,  count(c.index_id) AS indexcnt
		FROM sys.indexes i
			LEFT JOIN sys.index_columns c on (c.object_id = i.object_id)
			LEFT JOIN sys.objects o on (o.object_id = i.object_id)
	WHERE o.type = 'U'
	GROUP BY o.name
	HAVING count(c.index_id) > 0; 

END
GO
