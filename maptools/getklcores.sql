/****** Script for SelectTopNRows command from SSMS  ******/
SELECT --TOP 1000 
SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) AS ServerName,
	  --c.[DeviceNumber]
      --,c.[ComputerName],
      --,c.[OsFamilyName]
      --,
	  c.[CurrentOperatingSystem]
      ,c.[OsServicePack]
      ,c.[OsArchitectureBits]
      --,c.[CpuArchitectureBits]
      --,i.[DnsHostName]
      ,CASE
		WHEN SUBSTRING(i.[Instanceid],1,10)  = 'MSSQL10_50' THEN 'SQL 2008R2'
		WHEN SUBSTRING(i.[Instanceid],1,7)  = 'MSSQL10' THEN 'SQL 2008'
		WHEN SUBSTRING(i.[Instanceid],1,7) = 'MSSQL12' THEN 'SQL 2014'
		END AS SQLVersion
		--WHEN'MSSQL10_50.%' THEN
		--BEGIN 
		--	
		--END
	 
      ,i.[InstanceName]
	  --,i.[Clustered]
      --,i.[CreateCollectorId]
      --,i.[CreateDatetime]
      --,i.[Iswow64]
      --,i.[Language]
      --,i.[Servicename]
      --,i.[Sku]
      ,i.[Skuname]
      ,i.[Splevel]
      --,i.[Sqlservicetype]
      --,i.[UpdateCollectorId]
      --,i.[UpdateDatetime]
      ,i.[Version]
      --,i.[Fileversion]
      --,i.[Vsname]
      --,i.[Checksum]
	  --,p.[DeviceNumber]
      --,p.[Uid]
      --,p.[AddressWidth]
      ,p.[Architecture]
      ,p.[Availability]
      --,p.[Caption]
      --,p.[ConfigManagerErrorCode]
      --,p.[ConfigManagerUserConfig]
      ,p.[CpuStatus]
      --,p.[CreateCollectorId]
      --,p.[CreateDatetime]
      ,p.[CurrentClockSpeed]
      --,p.[CurrentVoltage]
      --,p.[DataWidth]
      ,p.[Description]
      ,p.[DeviceId]
      --,p.[ErrorCleared]
      --,p.[ErrorDescription]
      ,p.[ExtClock]
      ,p.[Family]
      --,p.[InstallDate]
      ,p.[L2CacheSize]
      --,p.[L2CacheSpeed]
      ,p.[L3CacheSize]
      --,p.[L3CacheSpeed]
      --,p.[LastErrorCode]
      ,p.[Level]
      ,p.[LoadPercentage]
      --,p.[Manufacturer]
      ,p.[MaxClockSpeed]
      ,p.[Name]
      ,p.[NumberOfCores]
      ,p.[NumberOfLogicalProcessors]
      --,p.[OtherFamilyDescription]
      --,p.[PnpDeviceId]
      --,p.[PowerManagementCapabilities]
      --,p.[PowerManagementSupported]
      --,p.[ProcessorId]
      --,p.[ProcessorType]
      --,p.[Revision]
      --,p.[Role]
      ,p.[SocketDesignation]
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
	--JOIN [serverinventory20160822].[SqlServer_Assessment].[SqlInstances] S
	  WHERE c.[OsFamilyName] NOT IN ('Windows 7','Windows 8','Windows XP', 'Windows 8.1','Windows Embedded Standard')
		AND i.[Skuname] NOT IN ('Business Intelligence Edition (64-bit)','Express Edition (64-bit)','Windows Internal Database (64-bit)','Business Intelligence Edition','Windows Internal Database','Express Edition')
		AND i.[Servicename] NOT IN ('DataQualityServices 2014','MSSQLServerOLAPService','MSOLAP$CUBE','MasterDataServices 2014','ReportServer','MSOLAP$POWERPIVOT')
		--AND i.[DnsHostName] IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL@k8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')
		AND (i.[DnsHostName] LIKE ('SP-SQL%') OR
		 i.[DnsHostName] LIKE ('PNG-%') OR
		  i.[DnsHostName] LIKE ('BI-ETL-%') OR
		  i.[DnsHostName] LIKE ('CON-SQL%') OR
		  i.[DnsHostName] LIKE ('RM-MUS%') OR
		  i.[DnsHostName] LIKE ('CRM-SQL%') OR
		  i.[DnsHostName] LIKE ('SP-MUS-DEV%'))
	--AND SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL@k8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')	
	----------AND SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) IN ('SP-MUS-DEV06','SP-MUS-DEV01','SP-MUS-DEV03','PNG-BI3-DEV')

	ORDER BY SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) Asc, i.[InstanceName] ASC, p.[SocketDesignation] ASC