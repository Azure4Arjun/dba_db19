USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_SQL_Versions]    Script Date: 6/25/2019 6:47:23 PM ******/
DROP TABLE [dbo].[dba_SQL_Versions]
GO

/****** Object:  Table [dbo].[dba_SQL_Versions]    Script Date: 6/25/2019 6:47:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dba_SQL_Versions](
	[VersionName] [varchar](8) NOT NULL,
	[VersionNumber] [varchar](15) NULL,
	[PatchLevel] [varchar](3) NULL
) ON [PRIMARY]
GO


