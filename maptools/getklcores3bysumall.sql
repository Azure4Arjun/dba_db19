/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
Upper(SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1)) AS ServerName-----,
	 ,'PROD' AS Environment
      ,sum(p.[NumberOfCores]) as TotalCores 
  FROM [serverinventory201701].[Win_Inventory].[Processors] p
	----------JOIN  [serverinventory201701].[SqlServer_Inventory].[Inventory]  i ON (p.[DeviceNumber] = i.[DeviceNumber])
	JOIN  [serverinventory201701].[AllDevices_Assessment].[HardwareInventoryCore] c ON (p.DeviceNumber = c.DeviceNumber )
	--JOIN [serverinventory201701].[SqlServer_Assessment].[SqlInstances] S
	  WHERE c.[OsFamilyName] NOT IN ('Windows 10','Windows 7','Windows 8','Windows XP', 'Windows 8.1','Windows Embedded Standard','Unknown Windows','Linux')
	  AND c.[OsFamilyName] IS NOT NULL
		----------AND i.[Skuname] NOT IN ('Business Intelligence Edition (64-bit)','Express Edition (64-bit)','Windows Internal Database (64-bit)','Business Intelligence Edition','Windows Internal Database','Express Edition')
		----------AND i.[Servicename] NOT IN ('DataQualityServices 2014','MSSQLServerOLAPService','MSOLAP$CUBE','MasterDataServices 2014','ReportServer','MSOLAP$POWERPIVOT')
		--AND i.[DnsHostName] IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL@k8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')
	----------AND SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL2k8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')
	AND SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) IN ('PNG-SQL-A','SP-SQL-PRD01','PNG-SQL2K8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')
	GROUP BY SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1)
	--------------ORDER BY ServerName ASC


	---***************** UAT
	UNION 
	SELECT 
Upper(SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1)) AS ServerName-----,
	 ,'UAT' AS Environment
      ,sum(p.[NumberOfCores]) as TotalCores 
  FROM [serverinventory201701].[Win_Inventory].[Processors] p
	----------JOIN  [serverinventory201701].[SqlServer_Inventory].[Inventory]  i ON (p.[DeviceNumber] = i.[DeviceNumber])
	JOIN  [serverinventory201701].[AllDevices_Assessment].[HardwareInventoryCore] c ON (p.DeviceNumber = c.DeviceNumber )
	--JOIN [serverinventory201701].[SqlServer_Assessment].[SqlInstances] S
	  WHERE c.[OsFamilyName] NOT IN ('Windows 7','Windows 8','Windows XP', 'Windows 8.1','Windows Embedded Standard')
		----------AND i.[Skuname] NOT IN ('Business Intelligence Edition (64-bit)','Express Edition (64-bit)','Windows Internal Database (64-bit)','Business Intelligence Edition','Windows Internal Database','Express Edition')
		----------AND i.[Servicename] NOT IN ('DataQualityServices 2014','MSSQLServerOLAPService','MSOLAP$CUBE','MasterDataServices 2014','ReportServer','MSOLAP$POWERPIVOT')
		--AND i.[DnsHostName] IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL@k8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')
	----------AND SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL2k8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')
	AND SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) IN ('PNG-DBA-TOOLS2','PNG-TFS-QA','CON-SQL-UAT01','CON-SQL-UAT02','BI-ETL-UAT01','PNG-BI2-QA1','PNG-CLARITY-TST','PNG-SQL-TST','PNG-SQL-TST2','PNG-SQL-TEST01','PNg-SQL-TEST02','SP-SQL-UAT01','SP-SQL-UAT02','SP-MUS-TRN01')
	GROUP BY SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1)
	--------------ORDER BY ServerName ASC

	UNION
	-- ************* SIT
		SELECT 
Upper(SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1)) AS ServerName-----,
	 ,'SIT' AS Environment
      ,sum(p.[NumberOfCores]) as TotalCores 
  FROM [serverinventory201701].[Win_Inventory].[Processors] p
	----------JOIN  [serverinventory201701].[SqlServer_Inventory].[Inventory]  i ON (p.[DeviceNumber] = i.[DeviceNumber])
	JOIN  [serverinventory201701].[AllDevices_Assessment].[HardwareInventoryCore] c ON (p.DeviceNumber = c.DeviceNumber )
	--JOIN [serverinventory201701].[SqlServer_Assessment].[SqlInstances] S
	  WHERE c.[OsFamilyName] NOT IN ('Windows 7','Windows 8','Windows XP', 'Windows 8.1','Windows Embedded Standard')
		----------AND i.[Skuname] NOT IN ('Business Intelligence Edition (64-bit)','Express Edition (64-bit)','Windows Internal Database (64-bit)','Business Intelligence Edition','Windows Internal Database','Express Edition')
		----------AND i.[Servicename] NOT IN ('DataQualityServices 2014','MSSQLServerOLAPService','MSOLAP$CUBE','MasterDataServices 2014','ReportServer','MSOLAP$POWERPIVOT')
		--AND i.[DnsHostName] IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL@k8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')
	----------AND SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL2k8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')
	AND SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) IN ('CON-SQL-SIT01','CON-SQL-SIT02','BI-ETL-SIT01','CRM-SQL-TEST')--,'SP-SQL-SIT')
	GROUP BY SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1)
	--------------ORDER BY ServerName ASC

	UNION
	--************** dev
			SELECT 
Upper(SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1)) AS ServerName-----,
	 ,'DEV' AS Environment
      ,sum(p.[NumberOfCores]) as TotalCores 
  FROM [serverinventory201701].[Win_Inventory].[Processors] p
	----------JOIN  [serverinventory201701].[SqlServer_Inventory].[Inventory]  i ON (p.[DeviceNumber] = i.[DeviceNumber])
	JOIN  [serverinventory201701].[AllDevices_Assessment].[HardwareInventoryCore] c ON (p.DeviceNumber = c.DeviceNumber )
	--JOIN [serverinventory201701].[SqlServer_Assessment].[SqlInstances] S
	  WHERE c.[OsFamilyName] NOT IN ('Windows 7','Windows 8','Windows XP', 'Windows 8.1','Windows Embedded Standard')
		----------AND i.[Skuname] NOT IN ('Business Intelligence Edition (64-bit)','Express Edition (64-bit)','Windows Internal Database (64-bit)','Business Intelligence Edition','Windows Internal Database','Express Edition')
		----------AND i.[Servicename] NOT IN ('DataQualityServices 2014','MSSQLServerOLAPService','MSOLAP$CUBE','MasterDataServices 2014','ReportServer','MSOLAP$POWERPIVOT')
		--AND i.[DnsHostName] IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL@k8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')
	----------AND SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) IN ('SP-SQL-PRD01','SP-SQL-PRD02','PNG-SQL2K8-PA','PNG-SQL2k8-PB','PNG-BI2-PRD1','PNG-VARONIS-01','PNG-CLARITY-PRD','BI-ETL-PRD01','CON-SQL-PRD01','CON-SQL-PRD02')
	AND SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1) IN ('CON-SQL-DEV01','CON-SQL-DEV02','BI-ETL-DEV01','PNG-BI2-DEV','PNG-BI3-DEV','RM-MUS-DEV01','SP-MUS-DEV01','SP-MUS-DEV03','SP-MUS-DEV04','SP-MUS-DEV05','SP-MUS-DEV06','SP-MUS-DEV07','SP-MUS-DEV08','SP-MUS-DEV09','SP-MUS-DEV10','SP-MUS-DEV15')
	GROUP BY SUBSTRING(c.[ComputerName],1,(CHARINDEX ('.',c.[ComputerName],1))-1)
	ORDER BY  Environment, ServerName ASC
