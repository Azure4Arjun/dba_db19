SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sev_2001ListVersionInformationER
--
--
-- Calls:		None
--
-- Description:	2001 - List Version Information (version).
--
-- From Edward Roepe - Perimeter DBA, LLC.  - www.perimeterdba.com
-- 
-- Date			Modified By			Changes
-- 09/01/2018   Aron E. Tekulsky    Initial Coding.
-- 05/10/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/14/2020   Aron E. Tekulsky    Update to Version 150.
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

-- 2001 - List Version Information (version)

-- 12-20-2012 - ESR - Original Program
-- 05-06-2015 - ESR - Add cluster name and drive letter columns
-- 07-14-2015 - ESR - Updated for SQL Server 2014

-- Tested on SQL 2008 thru 2017
-- Tested on Windows 2008 thru 2016

-- Declare variables

	DECLARE @ClusterName		VARCHAR(255);
	DECLARE @ClusterDrive		VARCHAR(255);
	DECLARE @DatabaseNames		VARCHAR(8000);
	DECLARE @IsClustered		VARCHAR(255);
	DECLARE @IsVirtual			VARCHAR(255);
	DECLARE @Processors			BIGINT;
	DECLARE @PhysicalMemory		BIGINT;
	DECLARE @ServerName			VARCHAR(255);
	DECLARE @SQLVersion			VARCHAR(255);
	DECLARE @SQLEdition			VARCHAR(255);
	DECLARE @SQLProductVersion	VARCHAR(255);
	DECLARE @SQLServicePack		VARCHAR(255);
	DECLARE @SQLBitLevel		VARCHAR(255);
	DECLARE @Version			VARCHAR(255);
	DECLARE @WindowsVersion		VARCHAR(255);
	DECLARE @WindowsProductName VARCHAR(255);
	DECLARE @WindowsReleaseId	VARCHAR(255);
	DECLARE @WindowsServicePack VARCHAR(255);
	DECLARE @WindowsEdition		VARCHAR(255);
	DECLARE @WindowsBitLevel	VARCHAR(255);

-- Drop temp table if it exists

	IF OBJECT_ID('tempdb..#ConfigTable') IS NOT NULL
	    DROP TABLE #ConfigTable;

-- Create temp table 

	CREATE TABLE #ConfigTable
		([Index]           INT, 
		[Name]            VARCHAR(255), 
		[Internal_Value]  VARCHAR(255), 
		[Character_Value] VARCHAR(255)
		);

-- Insert values into temp table 

	INSERT INTO #ConfigTable
		EXEC master.dbo.xp_msver;

-- Get number of processors

	SELECT @Processors =
			(
			SELECT Character_Value
				FROM #ConfigTable
			WHERE [Index] = 16
			);

-- Get physical memory

	SELECT @PhysicalMemory =
			(
			SELECT SUBSTRING(Character_Value, 1, CHARINDEX('(', Character_Value)-1)
				FROM #ConfigTable
			WHERE [Index] = 19
			);

-- Get Version information

	SET @Version = CONVERT(VARCHAR(255), @@Version);

-- Get the edition of SQL Server

	SET @SQLEdition = 'Unknown';  

	IF @Version LIKE '%Standard Edition%'
	    SET @SQLEdition = 'Standard Edition';
    
	IF @Version LIKE '%Enterprise Edition%'
		SET @SQLEdition = 'Enterprise Edition';
    
	IF @Version LIKE '%Business Intelligence Edition%'
	    SET @SQLEdition = 'Business Intelligence Edition';
    
	IF @Version LIKE '%Developer Edition%'
		SET @SQLEdition = 'Developer Edition';
    
	IF @Version LIKE '%Express Edition%'
		SET @SQLEdition = 'Express Edition';

	IF @Version LIKE '%Enterprise Edition: Core-based Licensing%'
		SET @SQLEdition = 'Enterprise Edition: Core-based Licensing';

-- Get Product Version

	SET @SQLProductVersion = CONVERT(VARCHAR(255), SERVERPROPERTY('ProductVersion'));

-- Get the Product Level

	SET @SQLServicePack = CONVERT(VARCHAR(255), SERVERPROPERTY('ProductLevel'));

-- Get the version of SQL Server

	SET @SQLVersion = 'Unknown';

	IF @Version LIKE '%Microsoft SQL Server  2000%' -- keep two blanks before 2000
		SET @SQLVersion = '2000';

	IF @Version LIKE '%Microsoft SQL Server 2000%'
		SET @SQLVersion = '2000';
	
	IF @Version LIKE '%Microsoft SQL Server 2005%'
		SET @SQLVersion = '2005';
	
	IF @Version LIKE '%Microsoft SQL Server 2008%'
		SET @SQLVersion = '2008';
	
	IF @Version LIKE '%Microsoft SQL Server 2008 R2%'
		SET @SQLVersion = '2008 R2';
    
	IF @Version LIKE '%Microsoft SQL Server 2012%'
		SET @SQLVersion = '2012';   

	IF @Version LIKE '%Microsoft SQL Server 2014%'
		SET @SQLVersion = '2014'; 

	IF @Version LIKE '%Microsoft SQL Server 2016%'
		SET @SQLVersion = '2016'; 
    
	IF @Version LIKE '%Microsoft SQL Server 2017%'
		SET @SQLVersion = '2017'; 
    
	IF @Version LIKE '%Microsoft SQL Server 2019%'
		SET @SQLVersion = '2019'; 

-- Get the bit level of SQL

	SELECT @SQLBitLevel = 'Unknown';

	IF @Version LIKE '%(Intel X86)%'
		SET @SQLBitLevel = '32'; 
    
	IF @Version LIKE '%(X64)%'
		SET @SQLBitLevel = '64'; 

-- Get the version of Windows

	SELECT @WindowsVersion = 'Unknown';

	EXEC master..xp_regread 
		@rootkey = 'HKEY_LOCAL_MACHINE', 
		@key = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\', 
		@value_name = 'CurrentVersion', 
		@value = @WindowsVersion OUTPUT;
    
-- Get the Product Name of Windows

	SELECT @WindowsProductName = 'Unknown';

	EXEC master..xp_regread 
		@rootkey = 'HKEY_LOCAL_MACHINE', 
		@key = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\', 
		@value_name = 'ProductName', 
		@value = @WindowsProductName OUTPUT;

-- Get the Release Id of Windows

	SELECT @WindowsReleaseId = 'Unknown';

	EXEC master..xp_regread 
		@rootkey = 'HKEY_LOCAL_MACHINE', 
		@key = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\', 
		@value_name = 'ReleaseId', 
		@value = @WindowsReleaseId OUTPUT;

-- Get the service pack of windows

	SELECT @WindowsServicePack = 'Unknown';

	IF @Version LIKE '%Service Pack 1%'
		SET @WindowsServicePack = 'SP1'; 
    
	IF @Version LIKE '%Service Pack 2%'
		SET @WindowsServicePack = 'SP2'; 
    
	IF @Version LIKE '%Service Pack 3%'
		SET @WindowsServicePack = 'SP3'; 
    
	IF @Version LIKE '%Service Pack 4%'
		SET @WindowsServicePack = 'SP4'; 
    
	IF @Version LIKE '%Service Pack 5%'
		SET @WindowsServicePack = 'SP5'; 
    
-- Get the bit level of Windows

	SELECT @WindowsBitLevel = '32';

	IF @Version LIKE '%<X86>%'
		SET @WindowsBitLevel = '32'; 
    
	IF @Version LIKE '%<X64>%'
		SET @WindowsBitLevel = '64';   

-- Get the edition of Windows

	SELECT @WindowsEdition = 'Unknown';

	EXEC master..xp_regread 
		@rootkey = 'HKEY_LOCAL_MACHINE', 
		@key = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\', 
		@value_name = 'CompositionEditionID', 
		@value = @WindowsEdition OUTPUT;
    
-- Get physical or virtual platform

	IF @Version LIKE '%Hypervisor%'
		SELECT @IsVirtual = 'Y';
	ELSE
		SELECT @IsVirtual = 'N';
    
-- Get list of databases

	SELECT @DatabaseNames = '';

	SELECT @DatabaseNames = COALESCE(@DatabaseNames, ', ')+LTRIM(RTRIM(name))+', '
		FROM master.sys.databases
	WHERE name NOT IN('master', 'msdb', 'model', 'tempdb')
	ORDER BY name;

-- Calculate if instance is clustered

	IF SERVERPROPERTY('IsClustered') = 1
		SELECT @IsClustered = 'Y';
    ELSE
		SELECT @IsClustered = 'N';

-- Get the cluster name

	EXEC master..xp_regread 
		@rootkey = 'HKEY_LOCAL_MACHINE', 
		@key = 'Cluster', 
		@value_name = 'ClusterName', 
		@value = @ClusterName OUTPUT;

	IF @ClusterName IS NULL
		SELECT @ClusterName = 'NA';

-- Calculate cluster drive

	SELECT @ClusterDrive = DriveName
		FROM fn_servershareddrives(); 

	IF @ClusterDrive IS NULL
		SELECT @ClusterDrive = 'NA';

-- List results

	SELECT SERVERPROPERTY('ServerName') AS 'InstanceName', 
			SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS 'ComputerName', 
			@SQLProductVersion AS 'SQLProduct', 
			@SQLVersion AS 'SQLVersion', 
			@SQLServicePack AS 'SQLSP', 
			@SQLEdition AS 'SQLEdition', 
			@SQLBitLevel AS 'SQLBit', 
			@WindowsVersion AS 'WinVersion', 
			@WindowsProductName AS 'WinProductName', 
			@WindowsReleaseId AS 'WinReleaseId', 
			@WindowsServicePack AS 'WinSP', 
			@windowsEdition AS 'WinEdition', 
			@WindowsBitLevel AS 'WinBit', 
			@Processors AS 'Processors', 
			@PhysicalMemory AS 'PhysicalMemory', 
			@IsClustered AS 'IsClustered', 
			@ClusterName AS 'ClusterName', 
			@ClusterDrive AS 'ClusterDrive', 
			@IsVirtual AS 'IsVirtual', 
			@Version AS 'Version', 
			@DatabaseNames AS 'DatabaseNames';
END
GO
