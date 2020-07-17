USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_database_expiration_history]    Script Date: 04/01/2011 12:20:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[dba_database_expiration_history](
	[name] [nvarchar](128) NOT NULL,
	[db_owner] [nvarchar](128) NULL,
	[db_dbid] [smallint] NOT NULL,
	[db_cr_date] [datetime] NULL,
	[db_expiration_date] [datetime] NULL,
	[db_restore_date] [datetime] NULL,
	[db_purpose] [varchar](2000) NULL,
	[db_application_name] [varchar](200) NULL,
	[db_Application_owner] [varchar](200) NULL,
	[db_location] [varchar](50) NULL,
	[db_url] [varchar](200) NULL,
	[db_PrimaryWebServer] [varchar](200) NULL,
	[db_SecondaryWebServer] [varchar](200) NULL,
	[db_release_number] [varchar](50) NULL,
	[db_status] [char](1) NULL,
	[last_modified_date] [datetime] NOT NULL,
	[db_backup_db] [int] NULL,
 CONSTRAINT [PK_dba_database_expiration_history] PRIMARY KEY CLUSTERED 
(
	[name] ASC,
	[last_modified_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[dba_database_expiration_history] ADD  CONSTRAINT [DF_dba_database_expiration_history_db_status]  DEFAULT ('A') FOR [db_status]
GO

ALTER TABLE [dbo].[dba_database_expiration_history] ADD  CONSTRAINT [DF_dba_database_expiration_history_last_modified_date]  DEFAULT (getdate()) FOR [last_modified_date]
GO


