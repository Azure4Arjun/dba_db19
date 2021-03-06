/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT 
SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) AS ServerName
			--,c.[ComputerName] AS DomainName
			----------,sum(m.Capacity ) as capacity
			--,m.[Capacity]
	       ,SUM(p.[NumberOfCores]) AS TotalCores
             ,count(p.[SocketDesignation]) as NumberofProcessorSlots
			,count(p.[DeviceId]) AS NumberofProcessors
--c.[DeviceNumber]
      --,c.[ComputerName],
      --,c.[OsFamilyName]
      --,
	  ------c.[CurrentOperatingSystem]
   ------   ,c.[OsServicePack]
   ------   ,c.[OsArchitectureBits]
      --,c.[CpuArchitectureBits]
      --,i.[DnsHostName]
      ,
	  CASE
		WHEN SUBSTRING(i.[Instanceid],1,10)  = 'MSSQL10_50' THEN 'SQL 2008R2'
		WHEN SUBSTRING(i.[Instanceid],1,7)  = 'MSSQL10' THEN 'SQL 2008'
		WHEN SUBSTRING(i.[Instanceid],1,7) = 'MSSQL11' THEN 'SQL 2012'
		WHEN SUBSTRING(i.[Instanceid],1,7) = 'MSSQL12' THEN 'SQL 2014'
		--ELSE '''' + [Instanceid] + ''''
		END AS SQL--Version
		--WHEN'MSSQL10_50.%' THEN
		--BEGIN 
		--	
		--END
	 
      ,
	  i.[InstanceName]
	  --,i.[Clustered]
      --,i.[CreateCollectorId]
      --,i.[CreateDatetime]
      --,i.[Iswow64]
      --,i.[Language]
      --,i.[Servicename]
      --,i.[Sku]
      ,i.[Skuname]
      ----------,i.[Splevel]
      --,i.[Sqlservicetype]
      --,i.[UpdateCollectorId]
      --,i.[UpdateDatetime]
      ----------,i.[Version]
      --,i.[Fileversion]
      --,i.[Vsname]
      --,i.[Checksum]
	  --,p.[DeviceNumber]
      --,p.[Uid]
      --,p.[AddressWidth]
      ------,p.[Architecture]
      ------,p.[Availability]
      --,p.[Caption]
      --,p.[ConfigManagerErrorCode]
      --,p.[ConfigManagerUserConfig]
      ------,p.[CpuStatus]
      --,p.[CreateCollectorId]
      --,p.[CreateDatetime]
      ------,p.[CurrentClockSpeed]
      --,p.[CurrentVoltage]
      --,p.[DataWidth]
      ------,p.[Description]
      --,p.[ErrorCleared]
      --,p.[ErrorDescription]
      ------,p.[ExtClock]
      ------,p.[Family]
      --,p.[InstallDate]
      ------,p.[L2CacheSize]
      --,p.[L2CacheSpeed]
      ------,p.[L3CacheSize]
      --,p.[L3CacheSpeed]
      --,p.[LastErrorCode]
      ------,p.[Level]
      ------,p.[LoadPercentage]
      --,p.[Manufacturer]
      ------,p.[MaxClockSpeed]
      ------,p.[Name]
      ----------,p.[NumberOfLogicalProcessors] 
      --,p.[OtherFamilyDescription]
      --,p.[PnpDeviceId]
      --,p.[PowerManagementCapabilities]
      --,p.[PowerManagementSupported]
      --,p.[ProcessorId]
      --,p.[ProcessorType]
      --,p.[Revision]
      --,p.[Role]
      --,p.[Status]
      --,p.[StatusInfo]
      --,p.[Stepping]
      --,p.[UniqueId]
      --,p.[UpdateCollectorId]
      --,p.[UpdateDatetime]
      --,p.[UpgradeMethod]
      --,p.[Version]
      --,p.[VoltageCaps]
  FROM [serverinventory20160822].[Win_Inventory].[Processors] p
	JOIN  [serverinventory20160822].[SqlServer_Inventory].[Inventory]  i ON (p.[DeviceNumber] = i.[DeviceNumber])
	JOIN  [serverinventory20160822].[AllDevices_Assessment].[HardwareInventoryCore] c ON (p.DeviceNumber = c.DeviceNumber )
	--JOIN  [serverinventory20160822].[dbo].[v_dba_memory] m ON (m.[DeviceNumber] = p.DeviceNumber )
	----------JOIN [serverinventory20160822].[Win_Inventory].[PhysicalMemory] m ON (m.DeviceNumber = p.DeviceNumber)
	--JOIN [serverinventory20160822].[SqlServer_Assessment].[SqlInstances] S
	  WHERE c.[OsFamilyName] NOT IN ('Windows 7','Windows 8','Windows XP', 'Windows 8.1','Windows Embedded Standard')
		AND i.[Skuname] NOT IN ('Business Intelligence Edition (64-bit)','Express Edition (64-bit)','Windows Internal Database (64-bit)','Business Intelligence Edition','Windows Internal Database','Express Edition')
		AND i.[Servicename] NOT IN ('DataQualityServices 2014','MSSQLServerOLAPService','MSOLAP$CUBE','MasterDataServices 2014','ReportServer','MSOLAP$POWERPIVOT')
		--AND i.[DnsHostName] IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL@k8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')
	AND SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL2k8-PB','PNG-SQL-A','PNG-SQL-B','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02',
	'BI-ETL-DEV01','BI-ETL-SIT01','BI-ETL-UAT01','CON-SQL-DEV01','CON-SQL-DEV02','CON-SQL-SIT01','CON-SQL-SIT02','CON-SQL-UAT01','CON-SQL-UAT02',
	'PNG-BI2-DEV','PNG-BI2-SIT','PNG-BIU2-UAT','PNG-CLARITY-TST','PNG-DBA-TOOLS2','PNG-SQL-TEST01','PNG-SQL-TEST02','RM-MUS-DEV01','SP-MUS-DEV02','SP-MUS-DEV05','SP-MUS-DEV07','SP-MUS-DEV09',
	'SP-SQL-UAT01', 'SP-SQL-UAT02')
GROUP BY SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1),c.[ComputerName],
	--m.[Capacity],
 	  CASE
		WHEN SUBSTRING(i.[Instanceid],1,10)  = 'MSSQL10_50' THEN 'SQL 2008R2'
		WHEN SUBSTRING(i.[Instanceid],1,7)  = 'MSSQL10' THEN 'SQL 2008'
		WHEN SUBSTRING(i.[Instanceid],1,7) = 'MSSQL11' THEN 'SQL 2012'
		WHEN SUBSTRING(i.[Instanceid],1,7) = 'MSSQL12' THEN 'SQL 2014'
		END , i.[InstanceName],i.[Skuname],i.[Splevel],i.[Version]--,
		--p.[NumberOfLogicalProcessors]
--ORDER BY SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1), i.[InstanceName] ASC--, p.[NumberOfLogicalProcessors] ASC
