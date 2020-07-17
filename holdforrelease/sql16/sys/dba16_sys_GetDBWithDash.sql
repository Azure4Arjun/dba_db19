SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetDBWithDash
--
--
-- Calls:		None
--
-- Description:	Get list of databse nmaes with dash in them.
-- 
-- Date			Modified By			Changes
-- 05/17/2019   Aron E. Tekulsky    Initial Coding.
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- find db's with dashes

	SELECT d.name 
		FROM sys.databases d
	WHERE Charindex('-',d.name ) <> 0;

END
GO
