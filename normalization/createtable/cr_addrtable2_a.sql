USE [form0]
GO

/****** Object:  Table [dbo].[addrtable2]    Script Date: 6/26/2013 9:39:13 AM ******/
DROP TABLE [dbo].[addrtable2]
GO

/****** Object:  Table [dbo].[addrtable2]    Script Date: 6/26/2013 9:39:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[addrtable2](
	[custnum] [int] NOT NULL,
	[addr] [nchar](20) NULL,
	[city] [nchar](10) NULL,
	[st] [nchar](10) NULL,
	[zp] [nchar](10) NULL,
 CONSTRAINT [PK_addrtable2] PRIMARY KEY CLUSTERED 
(
	[custnum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


