USE [dba_db19]
GO

/****** Object:  Table [dbo].[Schematable]    Script Date: 4/22/2020 8:58:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Schematable](
	[schemakey] [int] IDENTITY(1,1) NOT NULL,
	[TABLE_CATALOG] [nvarchar](128) NULL,
	[TABLE_SCHEMA] [nvarchar](128) NULL,
	[TABLE_NAME] [nvarchar](128) NULL,
	[COLUMN_NAME] [nvarchar](128) NULL,
	[DATA_TYPE] [nvarchar](128) NULL,
	[CHARACTER_MAXIMUM_LENGTH] [int] NULL,
	[IS_NULLABLE] [varchar](3) NULL,
	[ORDINAL_POSITION] [int] NULL,
	[KCONSTRAINT_NAME] [nvarchar](128) NULL,
	[UCONSTRAINT_NAME] [nvarchar](128) NULL,
 CONSTRAINT [PK_Schematable] PRIMARY KEY CLUSTERED 
(
	[schemakey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


