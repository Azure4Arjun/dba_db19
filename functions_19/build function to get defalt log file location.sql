----@DefaultLog

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

	SET @InstanceNam = 'E-TEKNOLOGIES\\SQL2019'
	PRINT @@Servername

	    SET @rootkey      = N'HKEY_LOCAL_MACHINE';
	    SET @key1          = N'SOFTWARE\\Microsoft\\Microsoft SQL Server';
	    SET @KEY = @key1

	SET @returnValue = ''

	SET @keyplus	= '\\' + @InstanceNam + '\\MSSQLServer'
	print @keyplus
	SET @key = @key1 + @keyplus

		SET @DefaultData = @returnValue

--SELECT @returnValue;
 
	SET @value_name	= 'DefaultLog'
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output
		

	SET @DefaultLog = @returnValue;
	
	PRINT '@rootkey = '+ @rootkey;
	PRINT '@key = ' + @key;
	PRINT '@value_name = ' + @value_name;
	PRINT '@value = ' + @value;

	PRINT @DefaultLog;


