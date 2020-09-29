SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_GetAllNonSADbo
--
--
-- Calls:		None
--
-- Description:	get a listing of all dbo's htat are not set to SA.
-- 
-- Date			Modified By			Changes
-- 03/14/2016   Aron E. Tekulsky    Initial Coding.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT name AS Database_Name, suser_sname(owner_sid) AS Database_Owner 
		FROM sys.databases
	WHERE suser_sname(owner_sid) <> 'sa';

END
GO
