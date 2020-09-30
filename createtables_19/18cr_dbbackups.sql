USE [dba_db19]
GO

/****** Object:  Table [dbo].[dbbackups]    Script Date: 7/27/2019 8:44:21 AM ******/
----DROP TABLE [dbo].[dbbackups]
----GO

/****** Object:  Table [dbo].[dbbackups]    Script Date: 7/27/2019 8:44:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dba_dbbackups](
	[servern] [nvarchar](128) NULL,
	[instance_id] [int] NULL,
	[job_id] [uniqueidentifier] NULL,
	[step_id] [int] NULL,
	[step_name] [sysname] NOT NULL,
	[message] [nvarchar](4000) NULL,
	[run_status] [int] NULL,
	[run_date] [varchar](10) NULL,
	[run_time] [varchar](10) NULL,
	[server] [sysname] NOT NULL,
	[jobname] [sysname] NOT NULL,
	[description] [nvarchar](512) NULL,
	[category_id] [int] NULL,
	[enabled] [tinyint] NULL,
	[name] [sysname] NOT NULL
) ON [PRIMARY]
GO


