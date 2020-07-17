USE [dba_db19]
GO

/****** Object:  Table [dbo].[rc_temp]    Script Date: 12/21/2012 11:45:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[rc_temp](
	[server_name] [varchar](128) NULL,
	[db_nam] [varchar](128) NULL,
	[obj_name] [varchar](128) NULL,
	[rc_nt] [bigint] NULL,
	[rws] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


