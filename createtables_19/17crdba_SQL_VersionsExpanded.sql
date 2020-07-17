USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_SQL_Versions]    Script Date: 5/29/2020 10:31:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dba_SQL_Versions](
	[VersionName] [varchar](8) NOT NULL,
	[VersionNumber] [varchar](15) NULL,
	[PatchLevel] [varchar](3) NULL,
	[CompatibilityLevel] [tinyint] NULL
) ON [PRIMARY]
GO


