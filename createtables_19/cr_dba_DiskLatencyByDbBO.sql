USE [dba_db16]
GO

/****** Object:  Table [dbo].[dba_DiskLatencyByDbBO]    Script Date: 6/5/2020 1:44:28 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dba_DiskLatencyByDbBO]') AND type in (N'U'))
DROP TABLE [dbo].[dba_DiskLatencyByDbBO]
GO

/****** Object:  Table [dbo].[dba_DiskLatencyByDbBO]    Script Date: 6/5/2020 1:44:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dba_DiskLatencyByDbBO](
	[RowId] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[SampleTime] [datetime] NULL,
	[DatabaseName] [sysname] NULL,
	[DatabaseId] [int] NOT NULL,
	[FileId] [int] NOT NULL,
	[LogicalFileName] [nvarchar](128) NULL,
	[type_desc] [nvarchar](60) NULL,
	[PhysicalFileName] [nvarchar](128) NULL,
	[DriveLetter] [char](2) NULL,
	[SizeGB] [decimal](23, 2) NULL,
	[TotalIOReadStallMS] [bigint] NULL,
	[TotalReads] [bigint] NULL,
	[GBRead] [numeric](23, 1) NULL,
	[AvgReadStallMS] [bigint] NULL,
	[Legend] [varchar](18) NULL,
	[MaxRecReadStallAvg] [bigint] NULL,
	[TotalIOWriteStallMS] [bigint] NULL,
	[TotalWrites] [bigint] NULL,
	[GBWritten] [numeric](23, 1) NULL,
	[AvgWriteStallMS] [bigint] NULL,
	[MaxRecWriteStallAvg] [bigint] NULL,
	[ReadRelatedWaitStat] [varchar](12) NULL,
	[WriteRelatedWaitStat] [varchar](20) NULL,
 CONSTRAINT [PK_dba_DiskLatencyBO_1] PRIMARY KEY CLUSTERED 
(
	[RowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


