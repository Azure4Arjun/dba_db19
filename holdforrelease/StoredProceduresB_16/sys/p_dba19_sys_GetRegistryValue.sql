SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetRegistryValue
--
-- Arguments:	@regitem int, 
--				@regvalue nvarchar(500) OUTPUT
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get a registry key value.
-- 
-- Date			Modified By			Changes
-- 01/13/2015   Aron E. Tekulsky    Initial Coding.
-- 01/13/2015	Aron E. Tekulsky	V110 compliant
-- 06/09/2016	Aron E. Tekulsky	add tcp port
-- 06/10/2016	Aron E. Tekulsky	allow specific values to be sent back or all.
-- 02/18/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetRegistryValue 
	-- Add the parameters for the stored procedure here
	@regitem int, 
	@regvalue nvarchar(500) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE	@ItemToChoose			int

	DECLARE	@rootkey				nvarchar(1000),
			@key					nvarchar(500),
			@value_name				nvarchar(500),
			@value					nvarchar(1000),
			@returnValue			nvarchar(1000),
			@keyplus				nvarchar(500),
			@key1					nvarchar(500)

-- Current Control Set
	DECLARE	@instancename			nvarchar(500)
	DECLARE @InstanceNam			nvarchar(500)
	DECLARE @SQLServiceAcct			nvarchar(128)
	DECLARE @ImagePath				nvarchar(1000)
	DECLARE @SQLAgentServiceAcct	nvarchar(1000)
	DECLARE @SQLAGENTImagePath		nvarchar(1000)

-- MSSQL12.SQL2014\MSSQLServer
	DECLARE @NumErrorLogs			nvarchar(128)
	DECLARE @AuditLevel				nvarchar(128)
	DECLARE @BackupDirectory		nvarchar(128)
	DECLARE @DefaultData			nvarchar(500)
	DECLARE @DefaultLog				nvarchar(500)



-- MSSQL12.SQL2014\MSSQLServer\Parameters
	DECLARE @SQLArg0				nvarchar(128) 
	DECLARE @SQLArg1				nvarchar(128)
	DECLARE @SQLArg2				nvarchar(128)
	
-- MSSQL12.SQL2014\MSSQLServers\HADR
	DECLARE @HADR_Enabled			nvarchar(128)
	
-- MSSQL12.SQL2014\SQLServerAgent
	DECLARE @ErrorLogFile			nvarchar(500)
	DECLARE @DatabaseMailProfile	nvarchar(200)
	DECLARE @ErrorLoggingLevel		nvarchar(128)
	DECLARE @WorkingDirectory		nvarchar(500)

-- MSSQL12.SQL2014\CPE
	DECLARE @ErrorDumpDir			nvarchar(500)


-- MSSQL12.SQL2014\Setup
	DECLARE @Edition				nvarchar(128)
	DECLARE @EditionType			nvarchar(128)
	DECLARE @Collation				nvarchar(128)
	DECLARE @FeatureList			nvarchar(500)
	DECLARE @SP						nvarchar(128)
	DECLARE @SQLBinRoot				nvarchar(500)
	DECLARE @SQLDataRoot			nvarchar(500)
	DECLARE @SQLPath				nvarchar(500)
	DECLARE @SQLProgramDir			nvarchar(500)
	DECLARE @Version				nvarchar(128)	

-- \\MSSQLServer\\SuperSocketNetLib\Tcp\
	DECLARE @port					nvarchar(100)

-----------------------------

	DECLARE @regtable TABLE (
			instancename			nvarchar(200),
			InstanceNam				nvarchar(128),
			AuditLevel				nvarchar(128),
			BackupDirectory			nvarchar(128),
			DefaultData				nvarchar(128),
			DefaultLog				nvarchar(128),
			NumErrorLogs			nvarchar(128),
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
			HADR_Enabled			nvarchar(128),
			ErrorLogFile			nvarchar(500),
			DatabaseMailProfile		nvarchar(200),
			ErrorLoggingLevel		nvarchar(128),
			WorkingDirectory		nvarchar(500),
			port					nvarchar(100)

	)

	DECLARE	@instancenameprop		nvarchar(200)

	SET @ItemToChoose = @regitem;


	SET @instancename = convert(nvarchar(128),ISNULL(serverproperty('instancename'), 'default'));

	print 'it is ' + @instancename;

	IF @instancename = 'default' 
		SET @instancename = 'MSSQLSERVER';

    SET @rootkey      = N'HKEY_LOCAL_MACHINE';
    SET @key1          = N'SOFTWARE\\Microsoft\\Microsoft SQL Server';
	SET @KEY = @key1;

-- get instance name
	SET @keyplus	= '\\Instance Names\\SQL';
	SET @key = @key1 + @keyplus;
		--SET @value_name	= 'SQL2014';
	SET @value_name	= @instancename;
		--SET @value_name	= 'MSSQLSERVER';

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;


	SET @InstanceNam = @returnValue;

	PRINT '@InstanceNam ' + @InstanceNam;

--
-- ** get default items **
-- 
	SET @keyplus	= '\\' + @InstanceNam + '\\MSSQLServer';
	print @keyplus;
	SET @key = @key1 + @keyplus;
	SET @value_name	= 'AuditLevel';

	print 'key plus is ' + @keyplus;
	print ' * ' + @key;

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;

--SELECT @returnValue;


	SET @AuditLevel = @returnValue;

	print 'audit level is ' + convert(varchar(128),@AuditLevel);

	SET @value_name	= 'BackupDirectory';

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;


	SET @BackupDirectory = @returnValue;
--	SELECT @returnValue;

	PRINT '*** Backup Directory is *** ' + @BackupDirectory;
	SET @value_name	= 'DefaultData';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		

	SET @DefaultData = @returnValue;

--SELECT @returnValue;
 
 	SET @value_name	= 'DefaultLog';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		

	SET @DefaultLog = @returnValue;

 	SET @value_name	= 'NumErrorLogs';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		

	SET @NumErrorLogs = @returnValue;

--SELECT @returnValue;

	SET @keyplus	= '\\' + @InstanceNam + '\\MSSQLServer\\Parameters';
	print @keyplus;
	SET @key = @key1 + @keyplus;
	SET @value_name	= 'SQLArg0';

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		
	SET @SQLArg0 = @returnValue;

	SET @value_name	= 'SQLArg1';

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		
	SET @SQLArg1 = @returnValue;

	SET @value_name	= 'SQLArg2';

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		
	SET @SQLArg2 = @returnValue;

	SET @keyplus	= '\\' + @InstanceNam + '\\MSSQLServer\\HADR';
	print @keyplus;
	SET @key = @key1 + @keyplus;
	SET @value_name	= 'HADR_Enabled';

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;

		
	SET @HADR_Enabled = @returnValue;


-- ** Setup 
--
	SET @keyplus	= '\\' + @InstanceNam + '\\Setup'	;
	SET @key = @key1 + @keyplus	;
 	SET @value_name	= 'SQLBinRoot'	;
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output	;
		


	SET @SQLBinRoot = @returnValue;

	PRINT 'sqlbinroot***';

--SELECT @returnValue;

 	SET @value_name	= 'SQLDataRoot';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		


	SET @SQLDataRoot = @returnValue;

--SELECT @returnValue;

 	SET @value_name	= 'SQLPath';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		


	SET @SQLPath = @returnValue;

	PRINT 'path is '  + @SQLPath;

--SELECT @returnValue;

 	SET @value_name	= 'SQLProgramDir';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;


	SET @SQLProgramDir = @returnValue;



--SELECT @returnValue;

 	SET @value_name	= 'Version';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		


	SET @Version = @returnValue;

 	SET @value_name	= 'Edition';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		


	SET @Edition = @returnValue;

 	SET @value_name	= 'EditionType';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		


	SET @EditionType = @returnValue;

 	SET @value_name	= 'Collation';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		


	SET @Collation = @returnValue;


 	SET @value_name	= 'FeatureList';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		


	SET @FeatureList = @returnValue;

 	SET @value_name	= 'SP';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		


	SET @SP = @returnValue;

--	SELECT @returnValue;

	PRINT 'CPE***';
--
-- ** CPE
--
	SET @keyplus	= '\\' + @InstanceNam + '\\CPE';
	SET @key = @key1 + @keyplus;
 	SET @value_name	= 'ErrorDumpDir';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		


	SET @ErrorDumpDir = @returnValue;

	PRINT '888 ' + @InstanceNam;
-- SQL Agent
	SET @keyplus	= '\\' + @InstanceNam + '\\SQLServerAgent';
	SET @key = @key1 + @keyplus;
 	SET @value_name	= 'ErrorLogFile';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		
	SET @ErrorLogFile = @returnValue;

	PRINT 'eror log file ' + @ErrorLogFile;

--	SET @keyplus	= '\\' + @InstanceNam + '\\SQLServerAgent';
	SET @key = @key1 + @keyplus;
 	SET @value_name	= 'DatabaseMailProfile;'
 
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;

	SET @DatabaseMailProfile = @returnValue;

	SET @key = @key1 + @keyplus;
 	SET @value_name	= 'WorkingDirectory';
 
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;

	SET @WorkingDirectory = @returnValue;

--	SET @keyplus	= '\\' + @InstanceNam + '\\SQLServerAgent';
	SET @key = @key1 + @keyplus;
 	SET @value_name	= 'ErrorLoggingLevel';
		
	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;

	SET @ErrorLoggingLevel = @returnValue;

-- GEt port and network information

	SET @keyplus	= '\\' + @InstanceNam + '\\MSSQLServer\\SuperSocketNetLib\Tcp\IPAll';
		------print @keyplus;
	SET @key = @key1 + @keyplus;
	SET @value_name	= 'TcpPort';

	PRINT 'key plus for port is ' + @keyplus;

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;

	SET @port = @returnValue;

	IF @port = '' or @port IS NUll
		SET @port=1433;

	PRINT 'port = ' + @port;



--SELECT @returnValue;

-- *************************
-- *  Current Control Set  *
-- *************************

-- get sql service act
    SET @rootkey      = N'HKEY_LOCAL_MACHINE';
    SET @key1          = N'SYSTEM\\CurrentControlSet\\services';
	SET @KEY = @key1;
--	SET @keyplus	= '\\MSSQL$SQL2014';
--	SET @keyplus	= '\\MSSQLSERVER';@InstanceNam;
	SET @keyplus	= '\\MSSQL$' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
	SET @key = @key1 + @keyplus;
	SET @value_name	= 'ObjectName';

	PRINT 'sql service acct is ' + @key;

  EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		

	SET @SQLServiceAcct = @returnValue;
----SELECT @returnValue;;

--	SET @keyplus	= '\\MSSQL$SQL2014';
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

--	SET @keyplus	= '\\SQLAGENT$SQL2014';
	SET @keyplus	= '\\SQLAGENT$' + SUBSTRING(@InstanceNam,CHARINDEX('.',@InstanceNam) + 1,LEN(@InstanceNam) - CHARINDEX('.',@InstanceNam));
	SET @key = @key1 + @keyplus;
	SET @value_name	= 'ObjectName';

	--print @key

	EXEC master.dbo.xp_regread
		@rootkey,
		@key,
		@value_name,
		@value        = @returnValue output;
		

	SET @SQLAgentServiceAcct = @returnValue;
----SELECT @returnValue;;

--	SET @keyplus	= '\\SQLAGENT$SQL2014';
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

	SET @regvalue =
	CASE 
		WHEN @ItemToChoose = 1 THEN
		 @BackupDirectory
		--PRINT 'test'
		WHEN @ItemToChoose = 2 THEN
			@SQLServiceAcct
		END;


--
-- ** set up table **
--

	IF @ItemToChoose = 0 OR @ItemToChoose IS NULL
		BEGIN
			INSERT INTO @regtable  
				(
				instancename, 
				InstanceNam, AuditLevel, BackupDirectory, DefaultData, DefaultLog, NumErrorLogs, SQLBinRoot, SQLDataRoot, SQLPath,
				SQLProgramDir, SqlVersion, ErrorDumpDir, SQLServiceAcct, ImagePath,	SQLAgentServiceAcct, SQLAGENTImagePath,
				Edition, EditionType, Collation, FeatureList, SP, SQLArg0, SQLArg1, SQLArg2, HADR_Enabled, ErrorLogFile, DatabaseMailProfile,
				ErrorLoggingLevel, WorkingDirectory, port)
			SELECT 
				@instancename, 
				@InstanceNam, @AuditLevel, @BackupDirectory, @DefaultData, @DefaultLog, @NumErrorLogs, @SQLBinRoot, @SQLDataRoot, @SQLPath,
				@SQLProgramDir, @Version, @ErrorDumpDir, @SQLServiceAcct, @ImagePath,	@SQLAgentServiceAcct, @SQLAGENTImagePath,
				@Edition, @EditionType, @Collation, @FeatureList, @SP, @SQLArg0, @SQLArg1, @SQLArg2, @HADR_Enabled, 
				@ErrorLogFile, @DatabaseMailProfile, @ErrorLoggingLevel, @WorkingDirectory, @port;

			SELECT instancename, 
				InstanceNam, AuditLevel, BackupDirectory, DefaultData, DefaultLog, NumErrorLogs, SQLBinRoot, SQLDataRoot, SQLPath,
				SQLProgramDir, SqlVersion, ErrorDumpDir, SQLServiceAcct, ImagePath,	SQLAgentServiceAcct, SQLAGENTImagePath,
				Edition, EditionType, Collation, FeatureList, SP, SQLArg0, SQLArg1, SQLArg2, HADR_Enabled, ErrorLogFile, DatabaseMailProfile,
				ErrorLoggingLevel, WorkingDirectory, port
				FROM @regtable;
		END

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetRegistryValue TO [db_proc_exec] AS [dbo]
GO
