USE [dba_db19]
GO

ALTER TABLE [dbo].[dba_database_servers] DROP CONSTRAINT [DF_dba_database_servers_row_status]
GO

ALTER TABLE [dbo].[dba_database_servers] DROP CONSTRAINT [DF_dba_database_servers_last_modified_date]
GO

ALTER TABLE [dbo].[dba_database_servers] DROP CONSTRAINT [DF_dba_database_servers_creation_date]
GO

/****** Object:  Table [dbo].[dba_database_servers]    Script Date: 7/27/2019 8:39:51 AM ******/
DROP TABLE [dbo].[dba_database_servers]
GO

/****** Object:  Table [dbo].[dba_database_servers]    Script Date: 7/27/2019 8:39:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dba_database_servers](
	[server_name] [varchar](50) NOT NULL,
	[server_location] [char](2) NULL,
	[dbadb_exists] [smallint] NULL,
	[creation_date] [datetime] NULL,
	[last_modified_date] [datetime] NULL,
	[row_status] [char](1) NULL,
 CONSTRAINT [PK_dba_database_servers] PRIMARY KEY CLUSTERED 
(
	[server_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[dba_database_servers] ADD  CONSTRAINT [DF_dba_database_servers_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO

ALTER TABLE [dbo].[dba_database_servers] ADD  CONSTRAINT [DF_dba_database_servers_last_modified_date]  DEFAULT (getdate()) FOR [last_modified_date]
GO

ALTER TABLE [dbo].[dba_database_servers] ADD  CONSTRAINT [DF_dba_database_servers_row_status]  DEFAULT ('A') FOR [row_status]
GO


