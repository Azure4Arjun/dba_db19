USE [dba_db19]
GO
/****** Object:  Table [dbo].[dbstatus2_codes]    Script Date: 01/23/2007 11:59:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[dbstatus2_codes](
	[dbstatus2_codes] [int] NOT NULL,
	[dbstatus2_description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF