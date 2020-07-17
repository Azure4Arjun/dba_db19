USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_diskdrives]    Script Date: 9/19/2013 10:43:27 AM ******/
DROP TABLE [dbo].[dba_diskdrives]
GO

/****** Object:  Table [dbo].[dba_diskdrives]    Script Date: 9/19/2013 10:43:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[dba_diskdrives](
	[drive] [char](1) NOT NULL,
	[mbfree] [int] NULL,
 CONSTRAINT [PK_dba_diskdrives] PRIMARY KEY CLUSTERED 
(
	[drive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


