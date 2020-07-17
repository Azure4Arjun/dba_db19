USE [dba_db19]
GO

/****** Object:  Table [dbo].[dba_disk_fragmentation]    Script Date: 5/25/2012 4:42:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[dba_disk_fragmentation](
	[drive_letter] [char](1) NOT NULL,
	[frag_pct] [varchar](100) NULL,
	[frag_decision] [varchar](50) NULL,
	[last_modified] [datetime] NOT NULL,
 CONSTRAINT [PK_dba_disk_fragmentation] PRIMARY KEY CLUSTERED 
(
	[drive_letter] ASC,
	[last_modified] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[dba_disk_fragmentation] ADD  CONSTRAINT [DF_dba_disk_fragmentation_last_modified]  DEFAULT (getdate()) FOR [last_modified]
GO


