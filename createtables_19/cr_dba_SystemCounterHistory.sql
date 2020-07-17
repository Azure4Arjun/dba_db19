/****** Object:  Table [dbo].[dba_SystemCounterHistory]    Script Date: 6/10/2020 10:29:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dba_SystemCounterHistory](
	[RowId] [int] IDENTITY(1,1) NOT NULL,
	[ObjectName] [nchar](128) NULL,
	[Backgroundwriterpagessec] [bigint] NULL,
	[Buffercachehitratio] [bigint] NULL,
	[Buffercachehitratiobase] [bigint] NULL,
	[Checkpointpagessec] [bigint] NULL,
	[Databasepages] [bigint] NULL,
	[Extensionallocatedpages] [bigint] NULL,
	[Extensionfreepages] [bigint] NULL,
	[Extensioninuseaspercentage] [bigint] NULL,
	[ExtensionoutstandingIOcounter] [bigint] NULL,
	[Extensionpageevictionssec] [bigint] NULL,
	[Extensionpagereadssec] [bigint] NULL,
	[Extensionpageunreferencedtime] [bigint] NULL,
	[Extensionpagewritessec] [bigint] NULL,
	[Freeliststallssec] [bigint] NULL,
	[IntegralControllerSlope] [bigint] NULL,
	[Lazywritessec] [bigint] NULL,
	[Pagelifeexpectancy] [bigint] NULL,
	[Pagelookupssec] [bigint] NULL,
	[Pagereadssec] [bigint] NULL,
	[Pagewritessec] [bigint] NULL,
	[Readaheadpagessec] [bigint] NULL,
	[Readaheadtimesec] [bigint] NULL,
	[Target pages] [bigint] NULL,
	[LastModified] [datetime] NOT NULL,
 CONSTRAINT [PK_dba_SystemCounterHistory] PRIMARY KEY CLUSTERED 
(
	[RowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[dba_SystemCounterHistory] ADD  CONSTRAINT [DF_dba_SystemPLE_LastModified]  DEFAULT (getdate()) FOR [LastModified]
GO


