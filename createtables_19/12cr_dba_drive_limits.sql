USE [dba_db19]
GO
/****** Object:  Table [dbo].[dba_drive_limits]    Script Date: 06/30/2008 11:58:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dba_drive_limits](
	[drive_letter] [nchar](1) NULL,
	[drive_limit] [int] NULL
) ON [PRIMARY]
