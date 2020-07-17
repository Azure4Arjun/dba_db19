USE [dba_db16]
GO

/****** Object:  Table [dbo].[dba_sql_patchlevel]    Script Date: 01/10/2013 10:24:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dba_sql_patchlevel]') AND type in (N'U'))
DROP TABLE [dbo].[dba_sql_patchlevel]
GO

USE [dba_db16]
GO

/****** Object:  Table [dbo].[dba_sql_patchlevel]    Script Date: 01/10/2013 10:24:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dba_sql_patchlevel](
	[date] [date] NULL,
	[productversion] [nvarchar](128) NULL,
	[productlevel] [nvarchar](128) NULL,
	[machinename] [nvarchar](128) NULL,
	[instancename] [nvarchar](128) NULL,
	[engineedition] [nvarchar](10) NULL
) ON [PRIMARY]

GO


