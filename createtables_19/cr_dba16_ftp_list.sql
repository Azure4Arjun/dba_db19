USE [dba_db19]
GO
/****** Object:  Table [dbo].[dba_ftp_list]    Script Date: 05/26/2009 13:55:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[dba_ftp_list](
	[name] [nvarchar](128) NOT NULL,
	[group_id] [int] NOT NULL,
	[destination_server] [varchar](50) NULL,
	[destination_share] [varchar](50) NULL,
	[destination_path] [varchar](100) NULL,
	[source_server] [varchar](50) NULL,
	[source_share] [varchar](50) NULL,
	[source_path] [varchar](100) NULL,
 CONSTRAINT [PK_dba_ftp_list] PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF