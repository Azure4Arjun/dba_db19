USE [form0]
GO

/****** Object:  Table [dbo].[addrtable3]    Script Date: 6/26/2013 2:40:05 PM ******/
DROP TABLE [dbo].[addrtable3]
GO

/****** Object:  Table [dbo].[addrtable3]    Script Date: 6/26/2013 2:40:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[addrtable3](
	[custnum] [int] NOT NULL,
	[addr] [nchar](20) NULL,
	[zp] [nchar](10) NOT NULL,
 CONSTRAINT [PK_addrtable3] PRIMARY KEY CLUSTERED 
(
	[custnum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


