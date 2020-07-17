SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_SetAGCreateScript
--
--
-- Calls:		None
--
-- Description:	Build a script to run and set up an AG.
--				*** YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE ***
-- 
-- Date			Modified By			Changes
-- 03/17/2018   Aron E. Tekulsky    Initial Coding.
-- 03/17/2018   Aron E. Tekulsky    Update to V140.
-- 09/11/2018	Aron E. Tekulsky	Include automatic seeding.
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
	DECLARE @Primary		nvarchar(128)
	DECLARE @Secondary		nvarchar(128)
	DECLARE @Listener		nvarchar(128)
	DECLARE @PriLogin		nvarchar(128)
	DECLARE @SecLogin		nvarchar(128)
	DECLARE @LoginFlag		int
	DECLARE @ListenerPort	int
	DECLARE @EncryptAlg		varchar(10)
	DECLARE @MirrorRole		varchar(10)
	DECLARE @AGName			nvarchar(128)
	DECLARE @DBName			nvarchar(128)
	DECLARE @PrimarySrvr	nvarchar(128)
	DECLARE @SecondarySrvr	nvarchar(128)
	DECLARE @FailoverMode	varchar(128)
	DECLARE @AvMode			varchar(128)
	DECLARE @BackupPrtyp	int
	DECLARE @BackupPrtys	int
	DECLARE @PrimaryCon		varchar(128)
	DECLARE @SecondaryCon	varchar(128)
	DECLARE @AutoSeeding	varchar(9)
	----DECLARE @SQLVersion		varchar(15)
	DECLARE @SQLVersion		int

	-- initialize values
	-- replace these values with appropriate values for your server.

	SET @Primary		= 'WCDCBPMDBP01A\PROD';
	SET @Secondary		= 'WADCBPMDBP01B\PROD';
	SET @Listener		= '';
	SET @PriLogin		= 'nam\seacct2';
	SET @SecLogin		= 'nam\seacct2';
	SET @LoginFlag		= 1; -- 0 do NOT create a connection login.  1 Create the connection login
	SET @ListenerPort	= 5022; -- 5022 is default
	SET @EncryptAlg		= 'AES';
	SET @MirrorRole		= 'ALL';
	SET @AGName			= 'AGBPMP1';
	SET @DBName			= 'test1';
	SET @PrimarySrvr	= 'wcdcbpmdbp01a.nam.ent.duke-energy.com'; -- Use FQDN
	SET @SecondarySrvr	= 'wadcbpmdbp01b.nam.ent.duke-energy.com'; -- Use FQDN
	SET @FailoverMode	= 'AUTOMATIC'; -- AUTOMATIC or MANUAL
	SET @AvMode			= 'SYNCHRONOUS_COMMIT'; --SYNCHRONOUS_COMMIT or ASYNCHRONOUS_COMMIT 
	SET @BackupPrtyp	= 0;
	SET @BackupPrtys	= 50;
	SET @PrimaryCon		= 'NO';
	SET @SecondaryCon	= 'ALL';
	SET @AutoSeeding	= 'AUTOMATIC'; -- AUTOMATIC or MANUAL


	SET @SQLVersion = convert(int,substring(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar),1,2));

	IF @SQLVersion >= 16
		SET @AutoSeeding	= 'AUTOMATIC';
	ELSE
		SET @AutoSeeding	= 'MANUAL';
	-- end initialize

	PRINT '*** YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE ***' + CHAR(13);
	
	
	PRINT '***************************************'
	PRINT '***    Create the Endpoint IDs      ***'
	PRINT '***************************************' + CHAR(13);


	-- set up the connection to the Primary

	SET @Cmd = ':Connect ' + @Primary + char(13) + 
		' USE [master] ' + char(13) + 
		' GO ' + CHAR(13);

	PRINT @Cmd;

	-- create the connection login on the Primary if needed

	SET @Cmd = 'CREATE LOGIN [' + @PriLogin + ']  FROM WINDOWS ' + CHAR(13) +
				'GO '+ CHAR(13);

	IF @LoginFlag = 1
		PRINT @Cmd;

	-- set up the connection to the Secondary

	SET @Cmd = ':Connect ' + @Secondary + char(13) + 

		' USE [master] ' + char(13) + 
		' GO ' + CHAR(13);

	PRINT @Cmd;

	-- create the connection login on the Secondary if needed

	SET @Cmd = 'CREATE LOGIN [' + @SecLogin + ']  FROM WINDOWS ' + CHAR(13) +
				'GO ' + CHAR(13);

	IF @LoginFlag = 1
		PRINT @Cmd;

			-- Create the Endpoint on Primary

	PRINT '***************************************'
	PRINT '*** Create the Endpoint on Primary  ***'
	PRINT '***************************************' + CHAR(13);

	SET @Cmd = ':Connect ' + @Primary + char(13) + 
		' USE [master] ' + char(13) + 
		' GO ' + CHAR(13);

	PRINT @Cmd;


	SET @Cmd = 'CREATE ENDPOINT [Hadr_endpoint]  
				AS TCP (LISTENER_PORT = ' + CAST(@ListenerPort AS char(4)) + ') 
					FOR DATA_MIRRORING (ROLE = ' + @MirrorRole + ', ENCRYPTION = REQUIRED ALGORITHM ' + @EncryptAlg + ') ' + CHAR(13) + 
					'GO' + CHAR(13);
	PRINT @Cmd;


	SET @Cmd = 'IF (SELECT state FROM sys.endpoints WHERE name = N' + '''' + 'Hadr_endpoint' + '''' + ') <> 0
		BEGIN
			ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
		END ' + CHAR(13) + 
		' GO' + CHAR(13);

	PRINT @Cmd;

	SET @Cmd = 'USE [master] ' + CHAR(13) + 
		' GO' + CHAR(13);

	PRINT @Cmd;

	SET @Cmd = 'GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [' + @PriLogin + '] ' + CHAR(13) + 
		' GO ' + CHAR(13);

	PRINT @Cmd;

	-- Create the Endpoint on Secondary

	PRINT '***************************************'
	PRINT '***Create the Endpoint on Secondary ***'
	PRINT '***************************************' + CHAR(13);

		SET @Cmd = ':Connect ' + @Secondary + char(13) + 
		' USE [master] ' + char(13) + 
		' GO ' + CHAR(13);

	PRINT @Cmd;

	SET @Cmd = 'CREATE ENDPOINT [Hadr_endpoint]  
				AS TCP (LISTENER_PORT = ' + CAST(@ListenerPort AS char(4)) + ') 
					FOR DATA_MIRRORING (ROLE = ' + @MirrorRole + ', ENCRYPTION = REQUIRED ALGORITHM ' + @EncryptAlg + ') ' + CHAR(13) + 
					'GO' + CHAR(13);
	PRINT @Cmd;


	SET @Cmd = 'IF (SELECT state FROM sys.endpoints WHERE name = N' + '''' + 'Hadr_endpoint' + '''' + ') <> 0
		BEGIN
			ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
		END ' + CHAR(13) + 
		' GO' + CHAR(13);

	PRINT @Cmd;

	SET @Cmd = 'USE [master] ' + CHAR(13) + 
		' GO' + CHAR(13);

	PRINT @Cmd;

	SET @Cmd = 'GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [' + @SecLogin + '] ' + CHAR(13) + 
		' GO ' + CHAR(13);

	PRINT @Cmd;

	PRINT '***************************************'
	PRINT '***  Start the Endpoint on Primary  ***'
	PRINT '***************************************' + CHAR(13);

	SET @Cmd = ':Connect ' + @Primary + char(13)  ;

	PRINT @Cmd;
		
	SET @Cmd = 'IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name=' + '''' + 'AlwaysOn_health' + '''' + ')
		BEGIN
			ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
		END' + CHAR(13);

	PRINT @Cmd;

	SET @Cmd = 'IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name=' + '''' + 'AlwaysOn_health' + '''' + ')
		BEGIN
			ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
		END' + CHAR(13) + 
		' GO ' + CHAR(13);

	PRINT @Cmd;


	PRINT '***************************************'
	PRINT '*** Start the Endpoint on Secondary ***'
	PRINT '***************************************' + CHAR(13);

	SET @Cmd = ':Connect ' + @Secondary + char(13)  ;

	PRINT @Cmd;
		
	SET @Cmd = 'IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name=' + '''' + 'AlwaysOn_health' + '''' + ')
		BEGIN
			ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
		END' + CHAR(13);

	PRINT @Cmd;

	SET @Cmd = 'IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name=' + '''' + 'AlwaysOn_health' + '''' + ')
		BEGIN
			ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
		END' + CHAR(13) + 
		' GO ' + CHAR(13);

	PRINT @Cmd;


	
	PRINT '***************************************'
	PRINT '***      Create AG on Primary       ***'
	PRINT '***************************************' + CHAR(13);

	SET @Cmd = ':Connect ' + @Primary + char(13)  ;

	PRINT @Cmd;
		
	SET @Cmd = 'USE [master] ' + CHAR(13) + 
		' GO' + CHAR(13);

	PRINT @Cmd;

	SET @Cmd = 'CREATE AVAILABILITY GROUP [' + @AGName + ']
		WITH (AUTOMATED_BACKUP_PREFERENCE = NONE)
			FOR DATABASE [' + @DBName + ']
		REPLICA ON N' + '''' + @Secondary + '''' + ' WITH (ENDPOINT_URL = N' + '''' + 'TCP://' + 
			@SecondarySrvr + ':' + CAST(@ListenerPort AS char(4)) + '''' + ', FAILOVER_MODE = ' + @FailoverMode + ',
		AVAILABILITY_MODE = ' + @AvMode + ', BACKUP_PRIORITY = ' + CAST(@BackupPrtys AS varchar(3)) + ', SECONDARY_ROLE
		(ALLOW_CONNECTIONS = ' + @SecondaryCon + ')' + 
		 ',SEEDING_MODE = ' + @AutoSeeding + ')),
			N' + '''' + @Primary + '''' + ' WITH (ENDPOINT_URL = N' + '''' + 'TCP://' + 
		@PrimarySrvr + ':' + CAST(@ListenerPort AS char(4)) + ', FAILOVER_MODE = ' + @FailoverMode + ',
		AVAILABILITY_MODE = ' + @AvMode + ', BACKUP_PRIORITY = ' + CAST(@BackupPrtyp AS varchar(3)) + ', SECONDARY_ROLE
		(ALLOW_CONNECTIONS = ' + @PrimaryCon + ')'  + 
		',SEEDING_MODE = ' + @AutoSeeding + ')' + CHAR(13);

	PRINT @Cmd;

	SET @Cmd = ' GO' + CHAR(13);

	PRINT @Cmd;

	
	PRINT '***************************************'
	PRINT '***  Join the Secondary to the AG   ***'
	PRINT '***************************************' + CHAR(13);

	SET @Cmd = ':Connect ' + @Secondary + char(13);

	PRINT @Cmd;

	SET @Cmd = 'ALTER AVAILABILITY GROUP [' + @AGName + '] JOIN;' + CHAR(13) + 
		'GO ' + CHAR(13);

	PRINT @Cmd;

	SET @Cmd = ':Connect ' + @Secondary + char(13);

	PRINT @Cmd;

-- Wait for the replica to start communicating

	SET @Cmd = 'begin try
			DECLARE @conn		bit
			DECLARE @count		int
			DECLARE @replica_id uniqueidentifier
			DECLARE @group_id	uniqueidentifier

			SET @conn	= 0;
			SET @count	= 30; -- wait for 5 minutes

			IF (SERVERPROPERTY(' + '''' + 'IsHadrEnabled' + '''' + ') = 1)
				AND (ISNULL((SELECT member_state 
								FROM master.sys.dm_hadr_cluster_members
							WHERE UPPER(member_name COLLATE Latin1_General_CI_AS) = 
									UPPER(cast(SERVERPROPERTY(' + '''' + 'ComputerNamePhysicalNetBIOS' + '''' + ') AS nvarchar(256)) COLLATE
								Latin1_General_CI_AS)), 0) <> 0)
								AND (ISNULL((SELECT state 
												FROM master.sys.database_mirroring_endpoints), 1) = 0) ' + CHAR(13) + '
				BEGIN
					SELECT @group_id = ags.group_id 
							FROM master.sys.availability_groups AS ags
					WHERE name = N' + '''' + @AGName + '''' + ';' + CHAR(13) + '

					SELECT @replica_id = replicas.replica_id 
							FROM master.sys.availability_replicas AS replicas
					WHERE UPPER (replicas.replica_server_name COLLATE Latin1_General_CI_AS) = 
							UPPER(@@SERVERNAME COLLATE Latin1_General_CI_AS) AND group_id = @group_id;' + --CHAR(13) + 

					'WHILE @conn <> 1 AND @count > 0
						BEGIN
							SET @conn = ISNULL((SELECT connected_state 
													FROM master.sys.dm_hadr_availability_replica_states AS states 
												WHERE states.replica_id = @replica_id), 1);
							IF @conn = 1
								BEGIN
									--EXIT loop when the replica is connected, or if the query cannot
									--find the replica status
									BREAK;
								END' + CHAR(13) + '

								WAITFOR DELAY ' + '''' + '00:00:10' + '''' + ';' + CHAR(13) + '

								SET @count = @count - 1;
						END
				END
	END TRY' + CHAR(13) + '

	BEGIN CATCH
		-- If the wait loop fails, do not stop execution of the alter database
		--statement
	END CATCH' + CHAR(13)

	PRINT @Cmd;

	
	PRINT '***************************************'
	PRINT '***           Set the AG            ***'
	PRINT '***************************************' + CHAR(13);

	SET @Cmd = 'ALTER DATABASE [' + @DBName + '] SET HADR AVAILABILITY GROUP = [' + @AGName + ']; ' + CHAR(13) 

	PRINT @Cmd;

	SET @Cmd = ' GO ' 

	PRINT @Cmd;

END
GO
