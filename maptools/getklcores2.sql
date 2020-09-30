SELECT --d.AdDnsHostName
		--, d.AdDomainName,
      i.[DnsHostName]
      --,i.[Instanceid]
      --,i.[InstanceName]
		,d.NumberOfCores 
		--,d.NumberOfLogicalProcessors
		--,d.NumberOfProcessors 
		--,d.OperatingSystem 
		--,d.OperatingSystemServicePack 
	 -- ,i.[Clustered]
      --,i.[CreateCollectorId]
      --,i.[CreateDatetime]
      --,i.[Iswow64]
      --,i.[Language]
      --,i.[Servicename]
      --,i.[Sku]
      --,i.[Skuname]
      --,i.[Splevel]
      --,i.[Sqlservicetype]
      --,i.[UpdateCollectorId]
      --,i.[UpdateDatetime]
      --,i.[Version]
      --,i.[Fileversion]
      --,i.[Vsname]
      --,i.[Checksum]
	FROM [Core_Inventory].[Devices] d
		JOIN  [serverinventory20160822].[SqlServer_Inventory].[Inventory]  i ON (d.[DeviceNumber] = i.[DeviceNumber])
 		JOIN  [serverinventory20160822].[AllDevices_Assessment].[HardwareInventoryCore] c ON (i.DeviceNumber = c.DeviceNumber )
WHERE c.[OsFamilyName] NOT IN ('Windows 7','Windows 8','Windows XP', 'Windows 8.1','Windows Embedded Standard')
		AND i.[Skuname] NOT IN ('Business Intelligence Edition (64-bit)','Express Edition (64-bit)','Windows Internal Database (64-bit)','Business Intelligence Edition','Windows Internal Database','Express Edition')
		AND i.[Servicename] NOT IN ('DataQualityServices 2014','MSSQLServerOLAPService','MSOLAP$CUBE','MasterDataServices 2014','ReportServer','MSOLAP$POWERPIVOT')
		AND i.[DnsHostName] NOT LIKE ('API-%')
		AND i.[DnsHostName] NOT LIKE ('HLX-%')
		AND i.[DnsHostName] NOT LIKE ('P10%')
		AND i.[DnsHostName] NOT LIKE ('PORTAL-%')
		--AND i.[DnsHostName] NOT LIKE ('RM-MUS-%')
		--AND i.[DnsHostName] NOT LIKE ('SOL-SQL-%')

GROUP BY       i.[DnsHostName],d.NumberOfCores 
