USE [dba_db19]
GO
/****** Object:  Table [dbo].[dba_db_mirror_changes]    Script Date: 02/26/2009 12:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dba_db_mirror_changes](
	[t_dbname] [nvarchar](128) NULL,
	[t_dbrole] [int] NULL,
	[t_db_local_time] [datetime] NULL
) ON [PRIMARY]
