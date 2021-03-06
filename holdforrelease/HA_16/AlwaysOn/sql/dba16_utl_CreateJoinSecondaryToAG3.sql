SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_CreateJoinSecondaryToAG3
--
--
-- Calls:		None
--
-- Description:	join the Secondary replicas to the AG.
--				Note: run this on the Secondary.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- join the Secondary replicas to the AG.
		------:CONNECT ETEK-NODE16-2\ETEKSQL16B

		ALTER AVAILABILITY GROUP [test1AGSeeding] JOIN -- On Secondary Replica
		GO

		ALTER AVAILABILITY GROUP [test1AGSeeding] GRANT CREATE ANY DATABASE  
		GO

END
GO
