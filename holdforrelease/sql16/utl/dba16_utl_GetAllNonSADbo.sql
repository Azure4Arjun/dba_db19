SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_GetAllNonSADbo
--
--
-- Calls:		None
--
-- Description:	get a listing of all dbo's htat are not set to SA./
-- 
-- Date			Modified By			Changes
-- 03/14/2016   Aron E. Tekulsky    Initial Coding.
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

	SELECT name AS Database_Name, suser_sname(owner_sid) AS Database_Owner 
		FROM sys.databases
	WHERE suser_sname(owner_sid) <> 'sa'

END
GO
