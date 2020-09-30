USE [form0]
GO

/****** Object:  Table [dbo].[custtable2]    Script Date: 6/26/2013 9:38:50 AM ******/
DROP TABLE [dbo].[custtable2]
GO

/****** Object:  Table [dbo].[custtable2]    Script Date: 6/26/2013 9:38:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[custtable2](
	[custnum] [int] NOT NULL,
	[fn] [nchar](10) NULL,
	[ln] [nchar](10) NULL,
 CONSTRAINT [PK_custtable2] PRIMARY KEY CLUSTERED 
(
	[custnum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


