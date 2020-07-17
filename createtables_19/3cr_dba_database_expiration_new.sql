USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_database_expiration]    Script Date: 5/19/2020 8:53:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dba_database_expiration](
	[name] [nvarchar](128) NOT NULL,
	[db_owner] [nvarchar](128) NULL,
	[db_dbid] [smallint] NOT NULL,
	[db_cr_date] [datetime] NULL,
	[db_Expiration_Date] [datetime] NULL,
	[db_Restore_date] [datetime] NULL,
	[db_purpose] [varchar](2000) NULL,
	[db_application_name] [varchar](200) NULL,
	[db_Application_owner] [varchar](200) NULL,
	[db_location] [varchar](50) NULL,
	[db_url] [varchar](200) NULL,
	[db_PrimaryWebServer] [varchar](200) NULL,
	[db_SecondaryWebServer] [varchar](200) NULL,
	[db_release_number] [varchar](50) NULL,
	[db_status] [char](1) NULL,
	[last_modified_date] [datetime] NULL,
	[db_backup_db] [int] NULL,
 CONSTRAINT [PK_dba_database_expiration] PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[dba_database_expiration] ADD  CONSTRAINT [DF_dba_database_expiration_db_status]  DEFAULT ('A') FOR [db_status]
GO

ALTER TABLE [dbo].[dba_database_expiration] ADD  CONSTRAINT [DF_dba_database_expiration_last_modified_date]  DEFAULT (getdate()) FOR [last_modified_date]
GO


