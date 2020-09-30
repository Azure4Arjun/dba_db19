SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_lis_SetCreateAGNoDB2
--
--
-- Calls:		None
--
-- Description:	Creates the AG with nodb.  
--				This is step 2.
--
--				Note: Set trace flag 9567 on the primary replica to enable compression 
--				of the data stream during automatic seeding. This can significantly 
--				reduce the transfer time of automatic seeding, however it also 
--				increases the CPU usage. For more information, see Tune compression 
--
--	***** Run in SQL Command Mode. *****
-- 
-- Date			Modified By			Changes
-- 01/23/2018   Aron E. Tekulsky    Initial Coding.
-- 01/23/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/07/2020   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	CREATE AVAILABILITY GROUP [test1AGSeeding]
		WITH (AUTOMATED_BACKUP_PREFERENCE = SECONDARY
				,DB_FAILOVER = OFF
				,DTC_SUPPORT = NONE
			)
		FOR DATABASE [test1] REPLICA ON -- Primary Replica
			N'ETEK-NODE16-1\ETEKSQL16A'	WITH (ENDPOINT_URL = N'TCP://ETEK-NODE16-1.E-TEKnologies.net:5022' -- Primary Replica Endpoint
				,FAILOVER_MODE = MANUAL
				,AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT
				,BACKUP_PRIORITY = 50
				,SECONDARY_ROLE(ALLOW_CONNECTIONS = NO)
				,SEEDING_MODE = AUTOMATIC
			), -- Secondary Replica
			N'ETEK-NODE16-2\ETEKSQL16B'	WITH (ENDPOINT_URL = N'TCP://ETEK-NODE16-2.E-TEKnologies.net:5022' -- Secondary Replica Endpoint
				,FAILOVER_MODE = MANUAL
				,AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT
				,BACKUP_PRIORITY = 50
				,SECONDARY_ROLE(ALLOW_CONNECTIONS = NO)
				,SEEDING_MODE = AUTOMATIC;
			)



END
GO
