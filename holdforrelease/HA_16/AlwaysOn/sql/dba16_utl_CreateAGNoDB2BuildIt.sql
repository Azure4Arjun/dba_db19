SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_CreateAGNoDB2BuildIt
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
--				for availability group.
--
--	***** Run in SQL Command Mode. *****
-- 
-- Date			Modified By			Changes
-- 01/23/2018   Aron E. Tekulsky    Initial Coding.
-- 01/23/2018   Aron E. Tekulsky    Update to V140.
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

	DECLARE @Cmd			nvarchar(4000)
	DECLARE @DatabaseName	nvarchar(128)
	DECLARE @DomainName		nvarchar(128)
	DECLARE @Instance1Name	nvarchar(128)
	DECLARE @Instance2Name	nvarchar(128)
	DECLARE @ListenerName	nvarchar(128)
	DECLARE @NodeName1		nvarchar(128)
	DECLARE @NodeName2		nvarchar(128)
	DECLARE @SeedingCmd		nvarchar(128)

	SET @ListenerName	= 'Test1AGSeeding';
	SET @DomainName		= 'E-TEKnologies.net';
	SET @NodeName1		= 'ETEK-NODE16-1';
	SET @NodeName2		= 'ETEK-NODE16-2';
	SET @Instance1Name	= 'ETEKSQL16A'
	SET @Instance2Name	= 'ETEKSQL16B'
	SET @DatabaseName	= 'test1';
	SET @SeedingCmd		= 'AUTOMATIC';


-- Create the AG.


	SET @Cmd = 
		'CREATE AVAILABILITY GROUP [' + @ListenerName  + ']
			WITH (AUTOMATED_BACKUP_PREFERENCE = SECONDARY
					,DB_FAILOVER = OFF
					,DTC_SUPPORT = NONE
				)
			FOR DATABASE [' +@DatabaseName + '] REPLICA ON -- Primary Replica
				N' + '''' + @NodeName1 + '\' + @Instance1Name + '''' + '	WITH (ENDPOINT_URL = N' + '''' + 'TCP://' + @NodeName1 + '.' + @DomainName + ':5022' + '''' +  -- Primary Replica Endpoint
					',FAILOVER_MODE = MANUAL
					,AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT
					,BACKUP_PRIORITY = 50
					,SECONDARY_ROLE(ALLOW_CONNECTIONS = NO)
					,SEEDING_MODE = AUTOMATIC
				), -- Secondary Replica
				N' + '''' + @NodeName2 + '\' + @Instance2Name + '''' + '	WITH (ENDPOINT_URL = N' + '''' + 'TCP://' + @NodeName2 + '.' + @DomainName + ':5022' + '''' +  -- Secondary Replica Endpoint
					',FAILOVER_MODE = MANUAL
					,AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT
					,BACKUP_PRIORITY = 50
					,SECONDARY_ROLE(ALLOW_CONNECTIONS = NO)
					,SEEDING_MODE = ' + @SeedingCmd + '
				)'

				PRINT @Cmd;



END
GO
