USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_disabled_jobs]    Script Date: 01/10/2013 11:19:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dba_disabled_jobs]') AND type in (N'U'))
DROP TABLE [dbo].[dba_disabled_jobs]
GO

USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_disabled_jobs]    Script Date: 01/10/2013 11:19:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[dba_disabled_jobs](
	[originating_server] [nvarchar](128) NULL,
	[job_id] [nvarchar](4000) NULL,
	[job_name] [nvarchar](128) NULL,
	[job_enabled] [varchar](8) NULL,
	[start_step_id] [int] NULL,
	[schedule_name] [nvarchar](128) NULL,
	[schedule_enabled] [varchar](13) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


