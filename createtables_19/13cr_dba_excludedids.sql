USE [dba_db19]
GO
/****** Object:  Table [dbo].[dba_excluded_ids]    Script Date: 08/15/2006 13:55:21 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[dba_excluded_ids](
	[users_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[timeout_amount] [smallint] NULL,
	[exclude_flag] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__dba_exclu__exclu__1FCDBCEB]  DEFAULT ('Y'),
 CONSTRAINT [PK_dba_excluded_ids] PRIMARY KEY CLUSTERED 
(
	[users_name] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF