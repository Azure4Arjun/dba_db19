/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 
	  --c.[DeviceNumber]
      --,
	  c.[ComputerName]
   --   ,c.[OsFamilyName]
      --,
	  ,c.[CurrentOperatingSystem]
   --   ,c.[OsServicePack]
   --   ,c.[OsArchitectureBits]
   --   ,c.[CpuArchitectureBits]
      ,i.[DnsHostName]
      --,i.[Instanceid]
      ,i.[InstanceName]
	  ,r.InstallDate as SQLInstallDate
	  --,r.InstallDate2
	  ,r.Name 
	  ,i.[Clustered]
      --,i.[CreateCollectorId]
      --,i.[CreateDatetime]
      --,i.[Iswow64]
      --,i.[Language]
      --,i.[Servicename]
      --,i.[Sku]
      ,i.[Skuname]
      --,i.[Splevel]
      --,i.[Sqlservicetype]
      --,i.[UpdateCollectorId]
      --,i.[UpdateDatetime]
      ,i.[Version]
      --,i.[Fileversion]
      ,i.[Vsname]
      --,i.[Checksum]
	  --,p.[DeviceNumber]
      --,p.[Uid]
      --,p.[AddressWidth]
      --,p.[Architecture]
      --,p.[Availability]
      --,p.[Caption]
      --,p.[ConfigManagerErrorCode]
      --,p.[ConfigManagerUserConfig]
      --,p.[CpuStatus]
      --,p.[CreateCollectorId]
      --,p.[CreateDatetime]
      --,p.[CurrentClockSpeed]
      --,p.[CurrentVoltage]
      --,p.[DataWidth]
      --,p.[Description]
      --,p.[DeviceId]
      --,p.[ErrorCleared]
      --,p.[ErrorDescription]
      --,p.[ExtClock]
      --,p.[Family]
      --,p.[InstallDate]
      ,p.[L2CacheSize]
      --,p.[L2CacheSpeed]
      --,p.[L3CacheSize]
      --,p.[L3CacheSpeed]
      --,p.[LastErrorCode]
      --,p.[Level]
      --,p.[LoadPercentage]
      --,p.[Manufacturer]
      --,p.[MaxClockSpeed]
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
      --,p.[SocketDesignation]
      --,p.[Status]
      --,p.[StatusInfo]
      --,p.[Stepping]
      --,p.[UniqueId]
      --,p.[UpdateCollectorId]
      --,p.[UpdateDatetime]
      --,p.[UpgradeMethod]
      --,p.[Version]
      --,p.[VoltageCaps]
  FROM [serverinventory201701].[Win_Inventory].[Processors] p
	JOIN  [serverinventory201701].[SqlServer_Inventory].[Inventory]  i ON (p.[DeviceNumber] = i.[DeviceNumber])
	JOIN  [serverinventory201701].[AllDevices_Assessment].[HardwareInventoryCore] c ON (p.DeviceNumber = c.DeviceNumber )
	JOIN [serverinventory201701].[Win_Inventory].[Products] r ON (r.DeviceNumber = p.DeviceNumber )
	--JOIN [serverinventory201701].[SqlServer_Assessment].[SqlInstances] S
	  WHERE c.[OsFamilyName] NOT IN ('Windows 7','Windows 8','Windows XP', 'Windows 8.1','Windows Embedded Standard')
		AND i.[Skuname] NOT IN ('Business Intelligence Edition (64-bit)','Express Edition (64-bit)','Windows Internal Database (64-bit)','Business Intelligence Edition','Windows Internal Database','Express Edition')
		AND i.[Servicename] NOT IN ('DataQualityServices 2014','MSSQLServerOLAPService','MSOLAP$CUBE','MasterDataServices 2014','ReportServer','MSOLAP$POWERPIVOT')
		--AND i.InstanceName LIKE ('%CONSQL%')		
		--AND i.InstanceName LIKE ('%PNG%')
		AND (c.[ComputerName] LIKE ('PNG-%')
		OR c.[ComputerName] LIKE ('BI-%')
		OR c.[ComputerName] LIKE ('CON-%'))
		AND i.[DnsHostName] NOT IN ('PNG-WM-BPMSD')
		AND r.Name LIKE ('SQL Server%')
		AND r.Name NOT IN ('SQL Server 2014 Integration Services','SQL Server 2014 SQL Data Quality Common','Sql Server Customer Experience Improvement Program',
			'SQL Server 2008 R2 SP2 Management Studio', 'SQL Server 2014 Data quality service','SQL Server 2008 R2 SP2 Client Tools','SQL Server 2014 Full text search',
			'SQL Server 2008 R2 SP2 Full text search','SQL Server 2014 Common Files','SQL Server 2014 Documentation Components','SQL Server 2014 Management Studio',
			'SQL Server 2014 Management Studio','SQL Server Browser for SQL Server 2014','SQL Server 2008 R2 SP2 Common Files','SQL Server 2014 Client Tools',
			'SQL Server 2008 R2 SP2 BI Development Studio','SQL Server 2008 R2 SP2 Integration Services','SQL Server 2008 R2 SP2 BI Development Studio')
	ORDER BY c.[ComputerName] ASC
