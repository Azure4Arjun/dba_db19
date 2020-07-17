SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_GetCollationsWCounts
--
--
-- Calls:		None
--
-- Description:	Get a listing of collations used and counts for each database on the
--				server.
-- 
-- Date			Modified By			Changes
-- 11/15/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT --d.name, --d.database_id, d.create_date, 
		d.collation_name, COUNT(*)
		FROM sys.databases d
--	WHERE d.database_id > 4
	GROUP BY d.collation_name
	ORDER BY d.collation_name ASC;


END
GO
