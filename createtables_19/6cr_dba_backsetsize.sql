USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_backsetsize]    Script Date: 09/26/2011 15:34:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

--DROP table  [dbo].[dba_backsetsize]


CREATE TABLE [dbo].[dba_backsetsize](
	[t_server_name] [nvarchar](128) NULL,
	[t_dbname] [sysname] NOT NULL,
	[t_backup_start_date] [datetime] NULL,
	[t_backup_set_id] [int] NOT NULL,
	[t_file_sizeMB] [numeric](20, 0) NULL,
	[t_logical_name] [nvarchar](128) NULL,
	[t_filegroup_name] [nvarchar](128) NULL,
	[t_physical_name] [nvarchar](260) NULL,
	[t_type] [char](1) NULL,
	[t_GrowthPct] [numeric] (5,3) NULL,
	[t_GrowthMB] [numeric] (20,0) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


