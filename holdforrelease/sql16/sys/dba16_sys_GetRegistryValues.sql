-- ======================================================================================
-- dba16_sys_GetRegistryValues
--
--
-- Calls:		None
--
-- Description:	Dump out all of the registry settings for a SQL server.
-- 
-- Date			Modified By			Changes
-- 03/15/2016   Aron E. Tekulsky    Initial Coding.
-- 03/15/2018	Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Declaration local variables
	DECLARE	@rootkey				nvarchar(1000),
			@key					nvarchar(500),
			@value_name				nvarchar(500),
			@value					nvarchar(1000),
			@returnValue			nvarchar(1000),
			@returnValuei			integer,
			@keyplus				nvarchar(500),
			@key1					nvarchar(500)

	DECLARE @error					int
	DECLARE @SSASFlag				smallint,
			@SSRSFlag				smallint,
			@SSRSspFlag				smallint,
			@SSISFlag				smallint,
			@FTSRCFlag				smallint

-- Current Control Set
	DECLARE @FTSServiceAcct			nvarchar(1000)
	DECLARE @FTSImagePath			nvarchar(1000)
	DECLARE @ImagePath				nvarchar(1000)
	DECLARE	@instancename			nvarchar(500)
	DECLARE @InstanceNam			nvarchar(500)
	DECLARE @SSASInstanceNam		nvarchar(500)
	DECLARE @SSRSInstanceNam		nvarchar(500)
	DECLARE @SSRSSPInstanceNam		nvarchar(500)
	DECLARE @SQLServiceAcct			nvarchar(128)
	DECLARE @SQLAgentServiceAcct	nvarchar(1000)
	DECLARE @SQLAGENTImagePath		nvarchar(1000)
	DECLARE @SSASServiceAcct		nvarchar(1000)
	DECLARE @SSASImagePath			nvarchar(1000)
	DECLARE @SSRSServiceAcct		nvarchar(1000)
	DECLARE @SSRSImagePath			nvarchar(1000)
	DECLARE @SSISServiceAcct		nvarchar(1000)
	DECLARE @SSISImagePath			nvarchar(1000)


-- MSSQL12.SQL2014\MSSQLServer
--DECLARE @NumErrorLogs			nvarchar(128)
	DECLARE @NumErrorLogs			integer
--DECLARE @AuditLevel				nvarchar(128)
	DECLARE @AuditLevel				integer
	DECLARE @BackupDirectory		nvarchar(128)
	DECLARE @DefaultData			nvarchar(500)
	DECLARE @DefaultLog				nvarchar(500)



-- MSSQL12.SQL2014\MSSQLServer\Parameters
	DECLARE @SQLArg0				nvarchar(128) 
	DECLARE @SQLArg1				nvarchar(128)
	DECLARE @SQLArg2				nvarchar(128)

-- MSSQL12.SQL2014\MSSQLServers\HADR
--DECLARE @HADR_Enabled			nvarchar(128)
	DECLARE @HADR_Enabled			integer

-- MSSQL12.SQL2014\SQLServerAgent
	DECLARE @DatabaseMailProfile	nvarchar(200)
	DECLARE @ErrorLogFile			nvarchar(500)
--DECLARE @ErrorLoggingLevel		nvarchar(128)
	DECLARE @ErrorLoggingLevel		integer
	DECLARE @WorkingDirectory		nvarchar(500)

-- MSSQL12.SQL2014\CPE
	DECLARE @ErrorDumpDir			nvarchar(500)


-- MSSQL12.SQL2014\Setup
	DECLARE @Collation				nvarchar(128)
	DECLARE @Edition				nvarchar(128)
	DECLARE @EditionType			nvarchar(128)
	DECLARE @FeatureList			nvarchar(500)
	DECLARE @SP						nvarchar(128)
	DECLARE @SQLBinRoot				nvarchar(500)
	DECLARE @SQLDataRoot			nvarchar(500)
	DECLARE @SQLPath				nvarchar(500)
	DECLARE @SQLProgramDir			nvarchar(500)
	DECLARE @Version				nvarchar(128)	

--
-- ************************
--          SSAS            --
-- ************************

-- MSAS12.SQL2014\Setup
	DECLARE @SSASDataDir			nvarchar(500),
			@SSASEdition			nvarchar(128),
			@SSASEditionType		nvarchar(128),
			@SSASFeatureList		nvarchar(128),
			@SSASPatchLevel			nvarchar(128),
			@SSASSqlBinRoot			nvarchar(500),
			@SSASPath				nvarchar(500),
			@SSASSqlProgramDir		nvarchar(500),
			@SSASVersion			nvarchar(128)

-- MSAS12.SQL2014\CPE
	DECLARE @SSASErrorDumpDir		nvarchar(500)

-- ************************
-- *         SSRS         *
-- ************************

-- MSRS12.SQL2014\Setup
	DECLARE --@SSRSDataDir			nvarchar(500),
			@SSRSEdition			nvarchar(128),
			@SSRSEditionType		nvarchar(128),
			@SSRSFeatureList		nvarchar(128),
			@SSRSPatchLevel			nvarchar(128),
			--@SSRSSqlBinRoot			nvarchar(500),
			@SSRSPath				nvarchar(500),
			@SSRSSqlProgramDir		nvarchar(500),
			@SSRSVersion			nvarchar(128)

-- MSRS12.SQL2014\CPE
	DECLARE @SSRSErrorDumpDir		nvarchar(500)

-- ************************
--       SharePoint       *
-- ************************

-- MSRS12.@Sharepoint\Setup
	DECLARE @RSSPVirtualRootServer	nvarchar(500),
			@RSSPConfiguration		nvarchar(500)

-- MSRS12.@Sharepoint\CPE
	DECLARE @RSSPErrorDumpDir		nvarchar(500)

-- MSRS12.ReportServerSharePointAddin
	DECLARE @SSRSSPAPatchLevel		nvarchar(128),
			@SSRSSPAVersion			nvarchar(128)


-- Networking
	DECLARE @TcpPort				integer
-----------------------------

	DECLARE @regtable TABLE (
		instancename			nvarchar(200),
		InstanceNam				nvarchar(128),
		--AuditLevel				nvarchar(128),
		AuditLevel				integer,
		BackupDirectory			nvarchar(128),
		DefaultData				nvarchar(128),
		DefaultLog				nvarchar(128),
	--NumErrorLogs			nvarchar(128),
		NumErrorLogs			integer,
		SQLBinRoot				nvarchar(128),
		SQLDataRoot				nvarchar(128),
		SQLPath					nvarchar(500),
		SQLProgramDir			nvarchar(128),
		SqlVersion				nvarchar(128),	
		ErrorDumpDir			nvarchar(128),
		SQLServiceAcct			nvarchar(128),
		ImagePath				nvarchar(500),
		SQLAgentServiceAcct		nvarchar(500),
		SQLAGENTImagePath		nvarchar(500),
		Edition					nvarchar(128),
		EditionType				nvarchar(128),
		Collation				nvarchar(128),
		FeatureList				nvarchar(500),
		SP						nvarchar(128),
		SQLArg0					nvarchar(128),
		SQLArg1					nvarchar(128),
		SQLArg2					nvarchar(128),
		--HADR_Enabled			nvarchar(128),
		HADR_Enabled			integer,
		ErrorLogFile			nvarchar(500),
		DatabaseMailProfile		nvarchar(200),
		--ErrorLoggingLevel		nvarchar(128),
		ErrorLoggingLevel		integer,
		WorkingDirectory		nvarchar(500),
		SSASInstanceNam			nvarchar(500),
		SSASDataDir				nvarchar(500),
		SSASEdition				nvarchar(128),
		SSASEditionType			nvarchar(128),
		SSASFeatureList			nvarchar(128),
		SSASPatchLevel			nvarchar(128),
		SSASSqlBinRoot			nvarchar(500),
		SSASPath				nvarchar(500),
		SSASSqlProgramDir		nvarchar(500),
		SSASVersion				nvarchar(128),
		SSASErrorDumpDir		nvarchar(500),
		SSASServiceAcct			nvarchar(1000),
		SSASImagePath			nvarchar(1000),
		SSRSInstanceNam			nvarchar(500),
		--SSRSDataDir				nvarchar(500),
		SSRSEdition				nvarchar(128),
		SSRSEditionType			nvarchar(128),
		SSRSFeatureList			nvarchar(128),
		SSRSPatchLevel			nvarchar(128),
		--SSRSSqlBinRoot			nvarchar(500),
		SSRSPath				nvarchar(500),
		SSRSSqlProgramDir		nvarchar(500),
		SSRSVersion				nvarchar(128),
		SSRSErrorDumpDir		nvarchar(500),
		SSRSServiceAcct			nvarchar(1000),
		SSRSImagePath			nvarchar(1000),
		SSASFlag				smallint,
		SSRSFlag				smallint,
		SSRSSPFlag				smallint,
		SSRSSPInstanceNam		nvarchar(500),
		RSSPVirtualRootServer	nvarchar(500),
		RSSPConfiguration		nvarchar(500),
		RSSPErrorDumpDir		nvarchar(500),
		SSRSSPAPatchLevel		nvarchar(128),
		SSRSSPAVersion			nvarchar(128),
		FTSServiceAcct			nvarchar(1000),
		FTSImagePath			nvarchar(1000),
		SSISFlag				smallint,
		FTSRCFlag				smallint,
		SSISServiceAcct			nvarchar(1000),
		SSISImagePath			nvarchar(1000),
		TcpPort					integer
)

	DECLARE	@instancenameprop	nvarchar(200)

--'REG_SZ' --'REG_DWORD' -- 

-- initialization of flags
	SET @SSASFlag   = 0;	-- Analysis Services
	SET @SSRSFlag   = 0;	-- Reporting Services
	SET @SSRSSPFlag = 0;	-- SharePoint SSSS SharePoint Addin
	SET @SSISFlag   = 0;	-- SharePoint SSSS SharePoint Addin
	SET @FTSRCFlag  = 0;	-- SharePoint SSSS SharePoint Addin

	SET @instancename = convert(nvarchar(128),ISNULL(serverproperty('instancename'), 'default'))

	print 'it is ' + @instancename

	IF @instancename = 'default' 
		SET @instancename = 'MSSQLSERVER';
	
	    SET @rootkey      = N'HKEY_LOCAL_MACHINE';
	    SET @key1          = N'SOFTWARE\\Microsoft\\Microsoft SQL Server';
	    SET @KEY = @key1

-- get instance name
		SET @keyplus	= '\\Instance Names\\SQL'
		SET @key = @key1 + @keyplus
		--SET @value_name	= 'SQL2014'
		SET @value_name	= @instancename
		--SET @value_name	= 'MSSQLSERVER'

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output


	SET @InstanceNam = @returnValue

	PRINT '@InstanceNam ' + @InstanceNam

-- SSAS

--initialize @returnValue
	SET @returnValue = ''

-- get instance name
	SET @keyplus	= '\\Instance Names\\OLAP'
	SET @key = @key1 + @keyplus
	SET @value_name	= @instancename

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output


	SET @SSASInstanceNam = @returnValue

	IF @SSASInstanceNam = '' OR @SSASInstanceNam IS NULL
		SET @SSASFlag = 0;
	ELSE
		SET @SSASFlag = 1;


	PRINT '@SSASInstanceNam ' + @SSASInstanceNam

-- SSRS

--initialize @returnValue
	SET @returnValue = ''

-- get instance name
	SET @keyplus	= '\\Instance Names\\RS'
	SET @key = @key1 + @keyplus
	SET @value_name	= @instancename

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output


	SET @SSRSInstanceNam = @returnValue

	IF @SSRSInstanceNam = '' OR @SSRSInstanceNam IS NULL
		SET @SSRSFlag = 0;
	ELSE 
		SET @SSRSFlag = 1;


	PRINT '@SSRSInstanceNam ' + @SSRSInstanceNam

--SSRS SharePoint

--initialize @returnValue
	SET @returnValue = ''

-- get instance name
	SET @keyplus	= '\\Instance Names\\RS'
	SET @key = @key1 + @keyplus
	SET @value_name	= '@Sharepoint'

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output


	SET @SSRSSPInstanceNam = @returnValue

	IF @SSRSSPInstanceNam = '' OR @SSRSSPInstanceNam IS NULL
		SET @SSRSSPFlag = 0;
	ELSE 
		SET @SSRSSPFlag = 1;


	PRINT '@SSRSSPInstanceNam ' + @SSRSSPInstanceNam


--
-- ** get default items **
-- 
	SET @keyplus	= '\\' + @InstanceNam + '\\MSSQLServer'
	print @keyplus
	SET @key = @key1 + @keyplus
	SET @value_name	= 'AuditLevel'

	print 'key plus is ' + @keyplus
	print ' * ' + @key

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValuei output

--SELECT @returnValue;


	SET @AuditLevel = @returnValuei

	print 'audit level is ' + convert(varchar(128),@AuditLevel)

	SET @value_name	= 'BackupDirectory'

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output


	SET @BackupDirectory = @returnValue
--SELECT @returnValue;

	SET @value_name	= 'DefaultData'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		

	SET @DefaultData = @returnValue

--SELECT @returnValue;
 
	SET @value_name	= 'DefaultLog'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		

	SET @DefaultLog = @returnValue

 	SET @value_name	= 'NumErrorLogs'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValuei output
		

	SET @NumErrorLogs = @returnValuei

--SELECT @returnValue;

	SET @keyplus	= '\\' + @InstanceNam + '\\MSSQLServer\\Parameters'
	print @keyplus
	SET @key = @key1 + @keyplus
	SET @value_name	= 'SQLArg0'

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		
	SET @SQLArg0 = '"' + @returnValue + '"'

	SET @value_name	= 'SQLArg1'

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		
	SET @SQLArg1 = '"'  + @returnValue + '"' 

		SET @value_name	= 'SQLArg2'

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		
	SET @SQLArg2 = '"'  + @returnValue + '"' 

	SET @keyplus	= '\\' + @InstanceNam + '\\MSSQLServer\\HADR'
	print @keyplus
	SET @key = @key1 + @keyplus
	SET @value_name	= 'HADR_Enabled'

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValuei output

		
	SET @HADR_Enabled = @returnValuei


-- ** Setup 
--
	SET @keyplus	= '\\' + @InstanceNam + '\\Setup'
	SET @key = @key1 + @keyplus
	SET @value_name	= 'SQLBinRoot'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		


	SET @SQLBinRoot = @returnValue

	PRINT 'sqlbinroot***'

--SELECT @returnValue;

 		SET @value_name	= 'SQLDataRoot'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		


	SET @SQLDataRoot = @returnValue

--SELECT @returnValue;

 		SET @value_name	= 'SQLPath'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		


	SET @SQLPath = @returnValue

	PRINT 'path is '  + @SQLPath

--SELECT @returnValue;

	SET @value_name	= 'SQLProgramDir'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output


	SET @SQLProgramDir = @returnValue



--SELECT @returnValue;

 		SET @value_name	= 'Version'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		


	SET @Version = @returnValue

 	SET @value_name	= 'Edition'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		


	SET @Edition = @returnValue

 		SET @value_name	= 'EditionType'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		


	SET @EditionType = @returnValue

	SET @value_name	= 'Collation'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		


	SET @Collation = @returnValue


	SET @value_name	= 'FeatureList'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		


	SET @FeatureList = @returnValue

 	SET @value_name	= 'SP'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		


	SET @SP = @returnValue

--SELECT @returnValue;

	PRINT 'CPE***'
--
-- ** CPE
--
	SET @keyplus	= '\\' + @InstanceNam + '\\CPE'
	SET @key = @key1 + @keyplus
	SET @value_name	= 'ErrorDumpDir'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		


	SET @ErrorDumpDir = @returnValue

--**********************--
-- SQL Agent Parameters --
--**********************--

	PRINT '888 ' + @InstanceNam + '  SQL Agent Parameters' 
-- SQL Agent
	SET @keyplus	= '\\' + @InstanceNam + '\\SQLServerAgent'
	SET @key = @key1 + @keyplus
 	SET @value_name	= 'ErrorLogFile'

	PRINT 'Key 1 is ' + @key1
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		
	SET @ErrorLogFile = @returnValue

	PRINT 'error log file ' + @ErrorLogFile

		--SET @keyplus	= '\\' + @InstanceNam + '\\SQLServerAgent'
	SET @key = @key1 + @keyplus
 	SET @value_name	= 'DatabaseMailProfile'
 
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output

	SET @DatabaseMailProfile = @returnValue

	SET @key = @key1 + @keyplus
 	SET @value_name	= 'WorkingDirectory'
 
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output

	SET @WorkingDirectory = @returnValue

		--SET @keyplus	= '\\' + @InstanceNam + '\\SQLServerAgent'
	SET @key = @key1 + @keyplus
 	SET @value_name	= 'ErrorLoggingLevel'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValuei output

		--	IF @@ERROR = 0
		--BEGIN
		--	SET @error = @@ERROR;
		--	END
	SET @ErrorLoggingLevel = @returnValuei

--SELECT @returnValue;

	IF @SSASFlag = 1
		BEGIN
		
-- *************************
-- *        SSAS           *
-- *************************

-- initialize @keyplua
			SET @keyplus	  = ''

		--SET @keyplus	  = '\\' + 'MSAS12.' + @InstanceName + '\\Setup'
			SET @keyplus	  = '\\' + @SSASInstanceNam + '\\Setup'
			SET @key = @key1 + @keyplus
 			SET @value_name	  = 'DataDir'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output

			PRINT ' ****** no ssas ****** ' + Convert(varchar(128), @@ERROR)
		
			PRINT 'ssas key plus ' + @keyplus
			PRINT '@SSASDataDir ' + @returnValue

			SET @SSASDataDir = @returnValue

	 		SET @value_name	  = 'Edition'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSASEdition ' + @returnValue

			SET @SSASEdition = @returnValue

 			SET @value_name	  = 'EditionType'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSASEditionType ' + @returnValue

			SET @SSASEditionType = @returnValue

 			SET @value_name	  = 'FeatureList'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSASFeatureList ' + @returnValue

			SET @SSASFeatureList = @returnValue

 			SET @value_name	  = 'PatchLevel'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSASPatchLevel ' + @returnValue

			SET @SSASPatchLevel = @returnValue

 			SET @value_name	  = 'SqlBinRoot'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSASSqlBinRoot ' + @returnValue

			SET @SSASSqlBinRoot = @returnValue

 			SET @value_name	  = 'Path'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSASPath ' + @returnValue

			SET @SSASPath = @returnValue

	 		SET @value_name	  = 'SqlProgramDir'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSASSqlProgramDir ' + @returnValue

			SET @SSASSqlProgramDir = @returnValue

	 		SET @value_name	  = 'Version'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSASVersion ' + @returnValue

			SET @SSASVersion = @returnValue

-- ********************
-- *       CPE        *
-- ********************

			SET @returnValue   = ''
			SET @rootkey       = N'HKEY_LOCAL_MACHINE';
			SET @key1          = N'SOFTWARE\\Microsoft\\Microsoft SQL Server';

-- initialize @keyplua
			SET @keyplus	  = ''

		--SET @keyplus	  = '\\' + 'MSAS12.' + @InstanceName + '\\CPE'
			SET @keyplus	  = '\\' +  @SSASInstanceNam + '\\CPE'
			SET @key = @key1 + @keyplus
 			SET @value_name	  = 'ErrorDumpDir'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT 'ssas key plus ' + @keyplus
			PRINT 'erorr dump dir ' + @returnValue

			SET @SSASErrorDumpDir = @returnValue
		END

	IF @SSRSFlag = 1
		BEGIN
-- *************************
-- *         SSRS          *
-- *************************

-- initialize @keyplua
			SET @keyplus	  = ''

		--SET @keyplus	  = '\\' + 'MSAS12.' + @InstanceName + '\\Setup'
			SET @keyplus	  = '\\' + @SSRSInstanceNam + '\\Setup'
			SET @key = @key1 + @keyplus
 --		SET @value_name	  = 'DataDir'
		
	--EXEC master.dbo.xp_regread
	--	@rootkey,
	--	@key,
	--	@value_name,
	--	@value        = @returnValue output
		
			PRINT 'ssRs key plus ' + @keyplus
--PRINT '@SSRSDataDir ' + @returnValue

--SET @SSRSDataDir = @returnValue

 			SET @value_name	  = 'Edition'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSRSEdition ' + @returnValue

			SET @SSRSEdition = @returnValue

 			SET @value_name	  = 'EditionType'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSRSEditionType ' + @returnValue

			SET @SSRSEditionType = @returnValue

 			SET @value_name	  = 'FeatureList'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSRSFeatureList ' + @returnValue

			SET @SSRSFeatureList = @returnValue

 			SET @value_name	  = 'PatchLevel'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSRSPatchLevel ' + @returnValue

			SET @SSRSPatchLevel = @returnValue

-- 		SET @value_name	  = 'SqlBinRoot'
		
--	EXEC master.dbo.xp_regread
--		@rootkey,
--		@key,
--		@value_name,
--		@value        = @returnValue output
		
--PRINT '@SSRSSqlBinRoot ' + @returnValue

--SET @SSRSSqlBinRoot = @returnValue

 			SET @value_name	  = 'SQLPath'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSRSSQLPath ' + @returnValue

			SET @SSRSPath = @returnValue

 			SET @value_name	  = 'SqlProgramDir'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSRSSqlProgramDir ' + @returnValue

			SET @SSRSSqlProgramDir = @returnValue

 			SET @value_name	  = 'Version'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT '@SSRSVersion ' + @returnValue

			SET @SSRSVersion = @returnValue

-- ********************
-- *       CPE        *
-- ********************
	
		   SET @returnValue   = ''
		   SET @rootkey       = N'HKEY_LOCAL_MACHINE';
		   SET @key1          = N'SOFTWARE\\Microsoft\\Microsoft SQL Server';

-- initialize @keyplua
			SET @keyplus	  = ''

		--SET @keyplus	  = '\\' + 'MSAS12.' + @InstanceName + '\\CPE'
			SET @keyplus	  = '\\' +  @SSRSInstanceNam + '\\CPE'
			SET @key = @key1 + @keyplus
 			SET @value_name	  = 'ErrorDumpDir'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output
		
			PRINT 'ssRs key plus ' + @keyplus
			PRINT 'erorr dump dir ' + @returnValue

			SET @SSRSErrorDumpDir = @returnValue

		END

-- sp
	IF @SSRSSPFlag = 1
		BEGIN
-- *************************
-- *    SSRS SharePoint    *
-- *************************

-- initialize @keyplua
			SET @keyplus	  = ''

		--SET @keyplus	  = '\\' + 'MSAS12.' + @InstanceName + '\\Setup'
			SET @keyplus	  = '\\' + @SSRSSPInstanceNam + '\\Setup'
			SET @key = @key1 + @keyplus
 --		SET @value_name	  = 'DataDir'
		
	--EXEC master.dbo.xp_regread
	--	@rootkey,
	--	@key,
	--	@value_name,
	--	@value        = @returnValue output
		
		PRINT 'ssRsSP key plus ' + @keyplus
--PRINT '@SSRSDataDir ' + @returnValue

--SET @SSRSDataDir = @returnValue

 		SET @value_name	  = 'RSConfiguration'
		
		EXEC master.dbo.xp_regread
			@rootkey,
			@key,
			@value_name,
			@value        = @returnValue output
		
		PRINT '@RSSPConfiguration ' + @returnValue

		SET @RSSPConfiguration = @returnValue

 		SET @value_name	  = 'RSVirtualRootServer'
		
		EXEC master.dbo.xp_regread
			@rootkey,
			@key,
			@value_name,
			@value        = @returnValue output
		
		PRINT '@RSSPVirtualRootServer ' + @returnValue

		SET @RSSPVirtualRootServer = @returnValue


-- ********************
-- *       CPE        *
-- ********************

	   SET @returnValue   = ''
       SET @rootkey       = N'HKEY_LOCAL_MACHINE';
       SET @key1          = N'SOFTWARE\\Microsoft\\Microsoft SQL Server';

-- initialize @keyplua
		SET @keyplus	  = ''

		--SET @keyplus	  = '\\' + 'MSAS12.' + @InstanceName + '\\CPE'
		SET @keyplus	  = '\\' +  @SSRSSPInstanceNam + '\\CPE'
		SET @key = @key1 + @keyplus
 		SET @value_name	  = 'ErrorDumpDir'
		
		EXEC master.dbo.xp_regread
			@rootkey,
			@key,
			@value_name,
			@value        = @returnValue output
		
		PRINT 'ssRsSP key plus ' + @keyplus
		PRINT 'SP erorr dump dir ' + @returnValue

		SET @RSSPErrorDumpDir = @returnValue

-- ***********************************
-- * Report Server SharePoint Addin  *
-- ***********************************

	   SET @returnValue   = ''
       SET @rootkey       = N'HKEY_LOCAL_MACHINE';
       SET @key1          = N'SOFTWARE\\Microsoft\\Microsoft SQL Server';

-- initialize @keyplua
		SET @keyplus	  = ''

		--SET @keyplus	  = '\\' + 'MSAS12.' + @InstanceName + '\\CPE'
		SET @keyplus	  = '\\' +  'Report Server SharePoint Addin\\CurrentVersion'
		SET @key = @key1 + @keyplus
 		SET @value_name	  = 'PatchLevel'
		
		EXEC master.dbo.xp_regread
			@rootkey,
			@key,
			@value_name,
			@value        = @returnValue output
		
		PRINT 'Report Server SharePoint Addin key plus ' + @keyplus
		PRINT 'rs SP addin PatchLevel ' + @returnValue

		SET @SSRSSPAPatchLevel = @returnValue


 		SET @value_name	  = 'Version'
		
		EXEC master.dbo.xp_regread
			@rootkey,
			@key,
			@value_name,
			@value        = @returnValue output
		
		PRINT 'Report Server SharePoint Addin key plus ' + @keyplus
		PRINT 'rs SP addin SSRSSPAVersion ' + @returnValue

		SET @SSRSSPAVersion = @returnValue


	END
-- end sp

-- *************************
-- *  Current Control Set  *
-- *************************

-- *************************
--       SQL Server        *
-- *************************

	PRINT 'Switching to current control set '
	PRINT ' SQL Sever info'

-- initialize @keyplua
	SET @keyplus	= ''

-- get sql service act
 	SET @keyplus	= '\\MSSQL$' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));

redo1:

	SET @returnValue   = ''
    SET @rootkey       = N'HKEY_LOCAL_MACHINE';
    SET @key1          = N'SYSTEM\\CurrentControlSet\\Services';
	SET @KEY = @key1;
		--SET @keyplus	= '\\MSSQL$SQL2014';
		--SET @keyplus	= '\\MSSQLSERVER';@InstanceNam
	SET @key = @key1 + @keyplus;
	SET @value_name	= 'ObjectName';


	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		
	--IF @@ERROR = 0

	IF (@returnValue IS NULL) OR (@returnValue = '')
	--IF @Value IS NULL
		BEGIN
			SET @error = @@ERROR;

			SET @keyplus	= '\\' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
			SET @key = @key1 + @keyplus;

			PRINT 'key is ' + @key
			PRINT 'keyplus is ' + @keyplus

			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output;

			------------GOTO redo1
		END

	IF (@returnValue IS NULL) OR (@returnValue = '')
	--IF @Value IS NULL
		BEGIN
			SET @error = @@ERROR;

			SET @keyplus	= '\\' + 'MSSQLSERVER';
			SET @key = @key1 + @keyplus;

			PRINT 'key is ' + @key
			PRINT 'keyplus is ' + @keyplus

			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output;

			------------GOTO redo1
		END

	SET @SQLServiceAcct = @returnValue;
		
	print 'sql service acct is ' + @key

----SELECT @returnValue;;


		--SET @keyplus	= '\\MSSQL$SQL2014';
	SET @key = @key1 + @keyplus;
	SET @value_name	= 'ImagePath';

		--print @key

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		
		SET @ImagePath = @returnValue;
----SELECT @returnValue;;

-- **********************
-- *      SQL Agent     *
-- **********************

	PRINT 'SQLAgent info '


	SET @returnValue = '';

		--SET @keyplus	= '\\SQLAGENT$SQL2014';
	SET @keyplus	= '\\SQLAGENT$' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
	SET @key = @key1 + @keyplus;
	SET @value_name	= 'ObjectName';

		--print @key

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;

	----------IF (@returnValue IS NULL) OR (@returnValue = '')
	----------------------IF @Value IS NULL
	----------	BEGIN
	----------	--
	----------	-- path for a default installation
	----------	--
	----------		SET @error = @@ERROR;

	----------		SET @keyplus	= '\\' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
	----------		SET @key = @key1 + @keyplus;

	----------		PRINT 'key is ' + @key
	----------		PRINT 'keyplus is ' + @keyplus

	----------		EXEC master.dbo.xp_regread
	----------			@rootkey,
	----------			@key,
	----------			@value_name,
	----------			@value        = @returnValue output;

	----------		------------GOTO redo1
	----------	END
		
	IF (@returnValue IS NULL) OR (@returnValue = '')
	------------IF @Value IS NULL
		BEGIN
		--
		-- path for a default installation
		--
			SET @error = @@ERROR;

			SET @keyplus	= '\\' + 'SQLSERVERAGENT';
			SET @key = @key1 + @keyplus;

			PRINT 'key is ' + @key
			PRINT 'keyplus is ' + @keyplus

			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output;

			------------GOTO redo1
		END

	SET @SQLAgentServiceAcct = @returnValue;
----SELECT @returnValue;;

		--SET @keyplus	= '\\SQLAGENT$SQL2014';
	SET @key = @key1 + @keyplus;
	SET @value_name	= 'ImagePath';

		--print @key

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		

		SET @SQLAGENTImagePath = @returnValue;
----SELECT @returnValue;;

	IF @SSASFlag = 1

		BEGIN
-- ***********************
-- *         SSAS        *
-- ***********************

			SET @returnValue = '';

		--SET @keyplus	= '\\SQLAGENT$SQL2014';
			SET @keyplus	= '\\MSOLAP$' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
			SET @key = @key1 + @keyplus;
			SET @value_name	= 'ObjectName';

		--print @key

			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output;

	------------IF (@returnValue IS NULL) OR (@returnValue = '')
	------------------------IF @Value IS NULL
	------------	BEGIN
	------------	--
	------------	-- path for a default installation
	------------	--
	------------		SET @error = @@ERROR;

	------------		SET @keyplus	= '\\' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
	------------		SET @key = @key1 + @keyplus;

	------------		PRINT 'key is ' + @key
	------------		PRINT 'keyplus is ' + @keyplus

	------------		EXEC master.dbo.xp_regread
	------------			@rootkey,
	------------			@key,
	------------			@value_name,
	------------			@value        = @returnValue output;

	------------		------------GOTO redo1
	------------	END
		
			IF (@returnValue IS NULL) OR (@returnValue = '')
	------------IF @Value IS NULL
				BEGIN
		--
		-- path for a default installation
		--
					SET @error = @@ERROR;

			------------SET @keyplus	= '\\' + 'MSOLAP';
					SET @keyplus	= '\\' + 'MSSQLServerOLAPService';
					SET @key = @key1 + @keyplus;

					PRINT 'key is ' + @key
					PRINT 'keyplus is ' + @keyplus

					EXEC master.dbo.xp_regread
						@rootkey,
						@key,
						@value_name,
						@value        = @returnValue output;

------------ check for existence
----------		IF @@ERROR <> 0 GOTO thessrs;

			------------GOTO redo1
				END

			SET @SSASServiceAcct = @returnValue;
----SELECT @returnValue;;

		--SET @keyplus	= '\\SQLAGENT$SQL2014';
			SET @key = @key1 + @keyplus;
			SET @value_name	= 'ImagePath';

		--print @key

			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output;
		

			SET @SSASImagePath = @returnValue;

		END

thessrs:

	IF @SSRSFlag = 1
		BEGIN
-- ***********************
-- *         SSRS        *
-- ***********************

			SET @returnValue = '';

		--SET @keyplus	= '\\SQLAGENT$SQL2014';
			SET @keyplus	= '\\ReportServer$' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
			SET @key = @key1 + @keyplus;
			SET @value_name	= 'ObjectName';

		--print @key

			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output;

	------------IF (@returnValue IS NULL) OR (@returnValue = '')
	------------------------IF @Value IS NULL
	------------	BEGIN
	------------	--
	------------	-- path for a default installation
	------------	--
	------------		SET @error = @@ERROR;

	------------		SET @keyplus	= '\\' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
	------------		SET @key = @key1 + @keyplus;

	------------		PRINT 'key is ' + @key
	------------		PRINT 'keyplus is ' + @keyplus

	------------		EXEC master.dbo.xp_regread
	------------			@rootkey,
	------------			@key,
	------------			@value_name,
	------------			@value        = @returnValue output;

	------------		------------GOTO redo1
	------------	END
		
			IF (@returnValue IS NULL) OR (@returnValue = '')
	------------IF @Value IS NULL
				BEGIN
		--
		-- path for a default installation
		--
					SET @error = @@ERROR;

					SET @keyplus	= '\\' + 'ReportServer';
					SET @key = @key1 + @keyplus;

					PRINT 'key is ' + @key
					PRINT 'keyplus is ' + @keyplus

					EXEC master.dbo.xp_regread
						@rootkey,
						@key,
						@value_name,
						@value        = @returnValue output;

			------------GOTO redo1
				END

------------ check for existence
----------		IF @@ERROR <> 0 GOTO listing;


			SET @SSRSServiceAcct = @returnValue;
----SELECT @returnValue;;

		--SET @keyplus	= '\\SQLAGENT$SQL2014';
			SET @key = @key1 + @keyplus;
			SET @value_name	= 'ImagePath';

		--print @key

			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output;
		

			SET @SSRSImagePath = @returnValue;

--
-- ** set up table **
--
	END

--IF @SSRSFlag = 1
		BEGIN
-- ***********************
-- *         FTS         *
-- ***********************

			SET @returnValue = '';

		--SET @keyplus	= '\\SQLAGENT$SQL2014';
			SET @keyplus	= '\\MSSQLFDLauncher$' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
			SET @key = @key1 + @keyplus;
			SET @value_name	= 'ObjectName';

		--print @key

			 EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output;

			IF (@returnValue IS NULL) OR (@returnValue = '')
	------------IF @Value IS NULL
				BEGIN
		--
		-- path for a default installation
		--
					SET @error = @@ERROR;

					SET @keyplus	= '\\' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
					SET @key = @key1 + @keyplus;

					PRINT 'key is ' + @key
					PRINT 'keyplus is ' + @keyplus

					EXEC master.dbo.xp_regread
						@rootkey,
						@key,
						@value_name,
						@value        = @returnValue output;

			------------GOTO redo1
				END
		
	--------IF (@returnValue IS NULL) OR (@returnValue = '')
	--------------------IF @Value IS NULL
	--------	BEGIN
	--------	--
	--------	-- path for a default installation
	--------	--
	--------		SET @error = @@ERROR;

	--------		SET @keyplus	= '\\' + 'REPORTSERVER';
	--------		SET @key = @key1 + @keyplus;

	--------		PRINT 'key is ' + @key
	--------		PRINT 'keyplus is ' + @keyplus

	--------		EXEC master.dbo.xp_regread
	--------			@rootkey,
	--------			@key,
	--------			@value_name,
	--------			@value        = @returnValue output;

	--------		------------GOTO redo1
	--------	END

------------ check for existence
----------		IF @@ERROR <> 0 GOTO listing;


			SET @FTSServiceAcct = @returnValue;
----SELECT @returnValue;;

		--SET @keyplus	= '\\SQLAGENT$SQL2014';
			SET @key = @key1 + @keyplus;
			SET @value_name	= 'ImagePath';

		--print @key

			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValue output;
		

			SET @FTSImagePath = @returnValue;

			IF @FTSImagePath IS NOT NULL SET @FTSRCFlag = 1; -- Full Text Search

	END

-- ************************
-- *        SSIS          *
-- ************************
  SET @returnValue = '';

		--SET @keyplus	= '\\SQLAGENT$SQL2014';
		SET @keyplus	= '\\MsDtsServer' + substring(@Version,1,2) + '0';
		SET @key = @key1 + @keyplus;
		SET @value_name	= 'ObjectName';

		--print @key

  EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;

	----------IF (@returnValue IS NULL) OR (@returnValue = '')
	----------------------IF @Value IS NULL
	----------	BEGIN
	----------	--
	----------	-- path for a default installation
	----------	--
	----------		SET @error = @@ERROR;

	----------		SET @keyplus	= '\\' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
	----------		SET @key = @key1 + @keyplus;

	----------		PRINT 'key is ' + @key
	----------		PRINT 'keyplus is ' + @keyplus

	----------		EXEC master.dbo.xp_regread
	----------			@rootkey,
	----------			@key,
	----------			@value_name,
	----------			@value        = @returnValue output;

	----------		------------GOTO redo1
	----------	END
		
	--------IF (@returnValue IS NULL) OR (@returnValue = '')
	--------------------IF @Value IS NULL
	--------	BEGIN
	--------	--
	--------	-- path for a default installation
	--------	--
	--------		SET @error = @@ERROR;

	--------		SET @keyplus	= '\\' + 'REPORTSERVER';
	--------		SET @key = @key1 + @keyplus;

	--------		PRINT 'key is ' + @key
	--------		PRINT 'keyplus is ' + @keyplus

	--------		EXEC master.dbo.xp_regread
	--------			@rootkey,
	--------			@key,
	--------			@value_name,
	--------			@value        = @returnValue output;

	--------		------------GOTO redo1
	--------	END

------------ check for existence
----------		IF @@ERROR <> 0 GOTO listing;


		SET @SSISServiceAcct = @returnValue;
----SELECT @returnValue;;

		----------SET @keyplus	= '\\SQLAGENT$SQL2014';
		----------SET @key = @key1 + @keyplus;
		SET @value_name	= 'ImagePath';

		--print @key

  EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		

		SET @SSISImagePath = @returnValue;

		IF @SSISImagePath IS NOT NULL SET @SSISFlag = 1; --SSIS

------------
------------ ** set up table **
------------
----------END

--***************
-- networking  **
--***************

			SET @returnValue   = ''
			SET @rootkey       = N'HKEY_LOCAL_MACHINE';
			SET @key1          = N'SOFTWARE\\Microsoft\\MSSQLServer\Client\SNI11.0\tcp\property1';

-- initialize @keyplua
			SET @keyplus	  = ''

		--SET @keyplus	  = '\\' + 'MSAS12.' + @InstanceName + '\\CPE'
			------SET @keyplus	  = '\\' +  '\\Value'
			SET @key = @key1 + @keyplus
 			SET @value_name	  = 'Value'
		
			EXEC master.dbo.xp_regread
				@rootkey,
				@key,
				@value_name,
				@value        = @returnValuei output
		
			------PRINT 'port number' + @keyplus
			PRINT 'port number ' + convert(varchar(50),@returnValuei)

			SET @TcpPort = @returnValuei

--
-- ** set up table **
--

listing:

INSERT INTO @regtable  
	(
	instancename, 
	InstanceNam, AuditLevel, BackupDirectory, DefaultData, DefaultLog, NumErrorLogs, SQLBinRoot, SQLDataRoot, SQLPath,
	SQLProgramDir, SqlVersion, ErrorDumpDir, SQLServiceAcct, ImagePath,	SQLAgentServiceAcct, SQLAGENTImagePath,
	Edition, EditionType, Collation, FeatureList, SP, SQLArg0, SQLArg1, SQLArg2, HADR_Enabled, ErrorLogFile, DatabaseMailProfile,
	ErrorLoggingLevel, WorkingDirectory,
	SSASInstanceNam, SSASDataDir, SSASEdition, SSASEditionType, SSASFeatureList, SSASPatchLevel, SSASSqlBinRoot, SSASPath, SSASSqlProgramDir, SSASVersion, SSASErrorDumpDir,
	SSASServiceAcct, SSASImagePath, SSRSInstanceNam,--SSRSDataDir, 
	SSRSEdition, SSRSEditionType, SSRSFeatureList, SSRSPatchLevel, --SSRSSqlBinRoot, 
	SSRSPath, SSRSSqlProgramDir, SSRSVersion, SSRSErrorDumpDir, SSRSServiceAcct, SSRSImagePath, SSASFlag, SSRSFlag,
	SSRSSPFlag, SSRSSPInstanceNam, RSSPVirtualRootServer, RSSPConfiguration, RSSPErrorDumpDir, SSRSSPAPatchLevel, SSRSSPAVersion,
	FTSServiceAcct, FTSImagePath, SSISFlag, FTSRCFlag, 
	SSISServiceAcct, SSISImagePath, TcpPort)
SELECT 
@instancename, 
@InstanceNam, @AuditLevel, @BackupDirectory, @DefaultData, @DefaultLog, @NumErrorLogs, @SQLBinRoot, @SQLDataRoot, @SQLPath,
	@SQLProgramDir, @Version, @ErrorDumpDir, @SQLServiceAcct, @ImagePath,	@SQLAgentServiceAcct, @SQLAGENTImagePath,
	@Edition, @EditionType, @Collation, @FeatureList, @SP, @SQLArg0, @SQLArg1, @SQLArg2, @HADR_Enabled, 
	@ErrorLogFile, @DatabaseMailProfile, @ErrorLoggingLevel, @WorkingDirectory,
	@SSASInstanceNam,@SSASDataDir, @SSASEdition, @SSASEditionType, @SSASFeatureList, @SSASPatchLevel, @SSASSqlBinRoot, @SSASPath, @SSASSqlProgramDir, @SSASVersion, @SSASErrorDumpDir,
	@SSASServiceAcct, @SSASImagePath,@SSRSInstanceNam,--@SSRSDataDir,
	 @SSRSEdition, @SSRSEditionType, @SSRSFeatureList, @SSRSPatchLevel, --@SSRSSqlBinRoot, 
	 @SSRSPath, @SSRSSqlProgramDir, @SSRSVersion, @SSRSErrorDumpDir, @SSRSServiceAcct, @SSRSImagePath, @SSASFlag, @SSRSFlag,
	 @SSRSSPFlag, @SSRSSPInstanceNam, @RSSPVirtualRootServer, @RSSPConfiguration, @RSSPErrorDumpDir, @SSRSSPAPatchLevel, @SSRSSPAVersion,
	 @FTSServiceAcct, @FTSImagePath, @SSISFlag, @FTSRCFlag, 
	 @SSISServiceAcct, @SSISImagePath, @TcpPort


SELECT '' AS DateConverted, '' AS Resource,
		CASE SSRSFlag
			WHEN 0 THEN 'N'
		ELSE 'Y'
		END AS SSRSFlag, 
		CASE SSASFlag
			WHEN 0 THEN 'N'
		ELSE 'Y'
		END AS SSASFlag,--' ' AS SSISFlag, 
		------' ' AS FullTxt,
		CASE SSISFlag
			WHEN 0 THEN 'N'
		ELSE 'Y'
		END AS SSISFlag, 
		CASE FTSRCFlag
			WHEN 0 THEN 'N'
		ELSE 'Y'
		END AS FTSRCFlag, 
		CASE SSRSSPFlag
			WHEN 0 THEN 'N'
		ELSE 'Y'
		END AS SSRSSPFlag, 
instancename, 
InstanceNam, AuditLevel, BackupDirectory, DefaultData, DefaultLog, NumErrorLogs, SQLBinRoot, SQLDataRoot, SQLPath,
	SQLProgramDir, SqlVersion, ErrorDumpDir, SQLServiceAcct, ImagePath,	SQLAgentServiceAcct, SQLAGENTImagePath,
	Edition, EditionType, Collation, FeatureList, SP, SQLArg0, SQLArg1, SQLArg2, HADR_Enabled, ErrorLogFile, DatabaseMailProfile,
	ErrorLoggingLevel, WorkingDirectory,
	SSASInstanceNam, SSASDataDir, SSASEdition, SSASEditionType, SSASFeatureList, SSASPatchLevel, SSASSqlBinRoot, SSASPath, SSASSqlProgramDir, SSASVersion, SSASErrorDumpDir,
	SSASServiceAcct, SSASImagePath, SSRSInstanceNam,--SSRSDataDir, 
	SSRSEdition, SSRSEditionType, SSRSFeatureList, SSRSPatchLevel, --SSRSSqlBinRoot, 
	SSRSPath, SSRSSqlProgramDir, SSRSVersion, SSRSErrorDumpDir, SSRSServiceAcct, SSRSImagePath,
	SSRSSPInstanceNam, RSSPVirtualRootServer, RSSPConfiguration, RSSPErrorDumpDir, SSRSSPAPatchLevel, SSRSSPAVersion,
	FTSServiceAcct, FTSImagePath,
	SSISServiceAcct, SSISImagePath, TcpPort

	FROM @regtable;

	END