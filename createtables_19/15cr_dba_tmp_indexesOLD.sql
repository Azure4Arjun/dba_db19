USE [dba_db19]
GO

/****** Object:  Table [dbo].[tmp_indexes]    Script Date: 10/27/2010 12:20:03 ******/
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
	[indextypedesc] [nvarchar](60)NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


