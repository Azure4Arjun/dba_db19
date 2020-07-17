USE [dba_db16]
GO

ALTER TABLE [dbo].[dba_SystemPLE] DROP CONSTRAINT [DF_dba_SystemPLE_LastModified]
GO

/****** Object:  Table [dbo].[dba_SystemPLE]    Script Date: 6/5/2020 1:40:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dba_SystemPLE]') AND type in (N'U'))
DROP TABLE [dbo].[dba_SystemPLE]
GO

/****** Object:  Table [dbo].[dba_SystemPLE]    Script Date: 6/5/2020 1:40:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dba_SystemPLE](
	[RowId] [int] NOT NULL,
	[ObjectName] [nchar](128) NULL,
	[CounterName] [nchar](128) NULL,
	[CntrValue] [bigint] NULL,
	[LastModified] [datetime] NOT NULL,
 CONSTRAINT [PK_dba_SystemPLE] PRIMARY KEY CLUSTERED 
(
	[RowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[dba_SystemPLE] ADD  CONSTRAINT [DF_dba_SystemPLE_LastModified]  DEFAULT (getdate()) FOR [LastModified]
GO


