USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_unused_indexes]    Script Date: 6/22/2012 2:31:22 PM ******/
DROP TABLE [dbo].[dba_unused_indexes]
GO

/****** Object:  Table [dbo].[dba_unused_indexes]    Script Date: 6/22/2012 2:31:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dba_unused_indexes](
	[dbname] [nvarchar](128) NULL,
	[schema_nam] [nvarchar](128) NULL,
	[obj_name] [nvarchar](128) NULL,
	[idx_name] [nvarchar](128) NULL,
	[idx_type] [tinyint] NULL,
	[idx_type_desc] [nvarchar](60) NULL,
	[is_primary_key] [bit] NULL,
	[idx_id] [int] NULL
) ON [PRIMARY]

GO


