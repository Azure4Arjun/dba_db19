USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_ftp_results]    Script Date: 12/22/2011 09:29:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[dba_ftp_results](
	[creation_date] [datetime] NULL,
	[Output_sp] [varchar](max) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[dba_ftp_results] ADD  CONSTRAINT [DF_dba_ftp_results_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO


