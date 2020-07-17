SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_CRMirroringEndPoints1
--
--
-- Calls:		None
--
-- Description:	Create the database mirroring endpolints neeeded for DB mirroring or AG.
--				perform this on each node.  this is Step 1.
--
--	***** Run in SQL Command Mode. *****
-- 
-- Date			Modified By			Changes
-- 01/25/2018   Aron E. Tekulsky    Initial Coding.
-- 01/25/2018   Aron E. Tekulsky    Update to V140.
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

	CREATE ENDPOINT [Hadr_endpoint] 
		STATE=STARTED
			AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
		FOR DATA_MIRRORING (
			ROLE = ALL, 
			AUTHENTICATION = WINDOWS NEGOTIATE, 
			ENCRYPTION = REQUIRED ALGORITHM AES
        )

END
GO
