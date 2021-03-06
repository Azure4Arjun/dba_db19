USE [dba_db19]
GO
/****** Object:  Table [dbo].[system_config_values]    Script Date: 08/16/2007 12:26:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[system_config_values](
	[system_config_name] [char](30) NOT NULL,
	[text_value] [varchar](100) NULL,
	[date_value] [datetime] NULL,
	[int_value] [int] NULL,
	[real_value] [real] NULL,
	[money_value] [money] NULL,
	[prev_date_value] [datetime] NULL,
	[sql_id] [varchar](20) NOT NULL CONSTRAINT [DF_system_config_values_sql_id]  DEFAULT (user_name()),
	[user_id] [varchar](20) NOT NULL CONSTRAINT [DF_system_config_values_user_id]  DEFAULT (user_name()),
	[creation_date] [datetime] NOT NULL CONSTRAINT [DF_system_config_values_creation_date]  DEFAULT (getdate()),
	[last_modified_date] [datetime] NOT NULL CONSTRAINT [DF_system_config_values_last_modified_date]  DEFAULT (getdate()),
	[row_status] [char](1) NOT NULL CONSTRAINT [DF_system_config_values_row_status]  DEFAULT ('A'),
 CONSTRAINT [PK_system_config_values] PRIMARY KEY CLUSTERED 
(
	[system_config_name] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF