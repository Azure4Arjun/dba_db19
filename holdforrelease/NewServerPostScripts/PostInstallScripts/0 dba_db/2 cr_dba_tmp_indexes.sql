USE [dba_db08]
GO

/****** Object:  Table [dbo].[tmp_indexes]    Script Date: 07/09/2013 10:18:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmp_indexes]') AND type in (N'U'))
DROP TABLE [dbo].[tmp_indexes]
GO

USE [dba_db08]
GO

/****** Object:  Table [dbo].[tmp_indexes]    Script Date: 07/09/2013 10:18:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tmp_indexes](
	[dbnam] [nvarchar](250) NULL,
	[schemaid] [int] NULL,
	[schemaname] [nvarchar](250) NULL,
	[objectid] [int] NULL,
	[objectname] [nvarchar](250) NULL,
	[indexid] [int] NULL,
	[indexname] [nvarchar](250) NULL,
	[indextype] [int] NULL,
	[indexhold] [int] NULL,
	[partnm] [int] NULL,
	[avgfrag] [numeric](10, 3) NULL,
	[disposit] [varchar](100) NULL,
	[alloc_unit_type_desc] [varchar](100) NULL,
	[index_level] [int] NULL,
	[indextypedesc] [nvarchar](60) NULL,
	[allowrowlocks] [bit] NULL,
	[allowpagelocks] [bit] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


