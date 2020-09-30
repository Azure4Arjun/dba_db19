SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_rep_GetAllReplicationCommands
--
--
-- Calls:		None
--
-- Description:	Get a listing of all of the replication commands in the MSrepl_commands 
--				table in the distributor database.
--				Diagnostic step 1.
-- 
-- Date			Modified By			Changes
-- 07/20/2018   Aron E. Tekulsky    Initial Coding.
-- 03/04/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
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

	USE distribution;

	SELECT * 
		FROM MSrepl_commands;

END
GO
