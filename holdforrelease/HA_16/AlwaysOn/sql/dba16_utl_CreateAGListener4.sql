SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_CreateAGListener4
--
--
-- Calls:		None
--
-- Description:	Set up the listener.
--
--	***** Run in SQL Command Mode. *****
-- 
-- Date			Modified By			Changes
-- 01/26/2018   Aron E. Tekulsky    Initial Coding.
-- 01/26/2018   Aron E. Tekulsky    Update to V140.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

-- set up the listener
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		ALTER AVAILABILITY GROUP [test1AGSeeding]
			ADD LISTENER N'test1AGListener' (
			WITH IP ((N'192.168.1.79', N'255.255.255.0')), PORT=1433)

		GO

END
GO
