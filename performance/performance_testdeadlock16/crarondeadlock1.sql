USE [test5]
GO

/****** Object:  Table [dbo].[arondeadlock1]    Script Date: 11/9/2016 12:31:29 PM ******/
DROP TABLE [dbo].[arondeadlock1]
GO

/****** Object:  Table [dbo].[arondeadlock1]    Script Date: 11/9/2016 12:31:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[arondeadlock1](
	[bspid] [smallint] NULL,
	[blk_status] [nchar](10) NULL
) ON [PRIMARY]

GO


