SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys__GetDatabaseListWCrdate
--
--
-- Calls:		None
--
-- Description:	List all DB with their creation dates.
-- 
-- Date			Modified By			Changes
-- 11/15/2016   Aron E. Tekulsky    Initial Coding.
-- 10/07/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT d.name, d.database_id, d.create_date, d.collation_name
		FROM sys.databases d
	WHERE d.database_id > 4
	ORDER BY d.name ASC

END
GO
