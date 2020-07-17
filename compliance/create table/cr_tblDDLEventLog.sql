USE [sox]
GO

-- disable trigger name 
DISABLE TRIGGER [tu_mod_tbl_checkname] ON DATABASE
GO

/****** Object:  Table [dbo].[tblDDLEventLog]    Script Date: 5/18/2012 9:07:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblDDLEventLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EventTime] [datetime] NULL,
	[EventType] [varchar](255) NULL,
	[ServerName] [nvarchar](128) NULL,
	[DatabaseName] [varchar](255) NULL,
	[ObjectType] [varchar](255) NULL,
	[ObjectName] [varchar](128) NULL,
	[UserName] [nvarchar](128) NULL,
	[CommandText] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

-- re-enable trigger name 
ENABLE TRIGGER [tu_mod_tbl_checkname] ON DATABASE
GO
