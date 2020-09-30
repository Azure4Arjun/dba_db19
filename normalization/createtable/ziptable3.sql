USE [form0]
GO

/****** Object:  Table [dbo].[ziptable3]    Script Date: 6/26/2013 2:41:01 PM ******/
DROP TABLE [dbo].[ziptable3]
GO

/****** Object:  Table [dbo].[ziptable3]    Script Date: 6/26/2013 2:41:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ziptable3](
	[zp] [nchar](10) NOT NULL,
	[city] [nchar](10) NULL,
	[st] [nchar](10) NULL,
 CONSTRAINT [PK_ziptable3] PRIMARY KEY CLUSTERED 
(
	[zp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


