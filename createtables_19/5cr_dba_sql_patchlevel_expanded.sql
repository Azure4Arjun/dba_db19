USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_sql_patchlevel]    Script Date: 5/18/2016 12:58:37 PM ******/
DROP TABLE [dbo].[dba_sql_patchlevel]
GO

/****** Object:  Table [dbo].[dba_sql_patchlevel]    Script Date: 5/18/2016 12:58:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dba_sql_patchlevel](
	[date]							[date] NULL,
	[productversion]				[nvarchar](128) NULL,
	[productlevel]					[nvarchar](128) NULL,
	[machinename]					[nvarchar](128) NULL,
	[instancename]					[nvarchar](128) NULL,
	[Collation]						[nvarchar](128) NULL,
	[ComputerNamePhysicalNetBIOS]	[nvarchar](128) NULL,
	[IsClustered]					[nvarchar](15)  NULL,
	[IsFullTextInstalled]			[nvarchar](128) NULL,
	[IsHadrEnabled]					[nvarchar](20)  NULL,
	[IsIntegratedSecurityOnly]		[nvarchar](60)  NULL,
	[IsSingleUser]					[nvarchar](15)  NULL,
	[BuildClrVersion]				[nvarchar](60)  NULL,
	[EditionID]						[nvarchar](60)  NULL,
	[HadrManagerStatus]				[nvarchar](60)  NULL,
	[IsLocalDB]						[nvarchar](60)  NULL,
	[IsXTPSupported]				[nvarchar](60)  NULL,
	[LCID]							[nvarchar](60)  NULL,
	[ProcessID]						[nvarchar](60)  NULL,
	[SqlCharSet]					[nvarchar](60)  NULL,
	[SqlCharSetName]				[nvarchar](60)  NULL,
	[SqlSortOrder]					[nvarchar](60)  NULL,
	[SqlSortOrderName]				[nvarchar](60)  NULL,
	[engineedition]					[nvarchar](10)  NULL
) ON [PRIMARY]

GO


