USE [dba_db19]
GO
/****** Object:  Table [dbo].[dba_disaster_dblist]    Script Date: 08/15/2006 13:53:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[dba_disaster_dblist](
	[name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[group_id] [int] NOT NULL,
	[destination_server] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[destination_share] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[destination_path] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[source_server] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[source_share] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[source_path] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_dba_disaster_dblist] PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF