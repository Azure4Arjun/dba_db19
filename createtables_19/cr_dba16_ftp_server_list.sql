USE [dba_db19]
GO
/****** Object:  Table [dbo].[dba_ftp_server_list]    Script Date: 12/06/2007 15:09:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[dba_ftp_server_list](
	[server_name] [varchar](50) NOT NULL,
	[ftp_server_name] [varchar](50) NULL,
	[ftp_ip_address] [varchar](50) NULL,
 CONSTRAINT [PK_dba_ftp_server_list] PRIMARY KEY CLUSTERED 
(
	[server_name] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF