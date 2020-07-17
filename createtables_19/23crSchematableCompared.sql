USE [dba_db19]
GO

/****** Object:  Table [dbo].[SchematableCompared]    Script Date: 4/22/2020 9:01:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SchematableCompared](
	[aschemakey] [int] NULL,
	[aTABLE_CATALOG] [nvarchar](128) NULL,
	[aTABLE_SCHEMA] [nvarchar](128) NULL,
	[aTABLE_NAME] [nvarchar](128) NULL,
	[aCOLUMN_NAME] [nvarchar](128) NULL,
	[aDATA_TYPE] [nvarchar](128) NULL,
	[aCHARACTER_MAXIMUM_LENGTH] [int] NULL,
	[aIS_NULLABLE] [varchar](3) NULL,
	[aORDINAL_POSITION] [int] NULL,
	[aKCONSTRAINT_NAME] [nvarchar](128) NULL,
	[aUCONSTRAINT_NAME] [nvarchar](128) NULL,
	[bschemakey] [int] NULL,
	[bTABLE_CATALOG] [nvarchar](128) NULL,
	[bTABLE_SCHEMA] [nvarchar](128) NULL,
	[bTABLE_NAME] [nvarchar](128) NULL,
	[bCOLUMN_NAME] [nvarchar](128) NULL,
	[bDATA_TYPE] [nvarchar](128) NULL,
	[bCHARACTER_MAXIMUM_LENGTH] [int] NULL,
	[bIS_NULLABLE] [varchar](3) NULL,
	[bORDINAL_POSITION] [int] NULL,
	[bKCONSTRAINT_NAME] [nvarchar](128) NULL,
	[bUCONSTRAINT_NAME] [nvarchar](128) NULL
) ON [PRIMARY]
GO


