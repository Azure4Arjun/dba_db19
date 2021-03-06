/*
   Monday, April 08, 20132:33:42 PM
   User: 
   Server: ATEKLT\DBS2008R2
   Database: dba_db08
   Application: 
*/
USE [dba_db19]
go

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.system_config_values
	DROP CONSTRAINT DF_system_config_values_sql_id
GO
ALTER TABLE dbo.system_config_values
	DROP CONSTRAINT DF_system_config_values_user_id
GO
ALTER TABLE dbo.system_config_values
	DROP CONSTRAINT DF_system_config_values_creation_date
GO
ALTER TABLE dbo.system_config_values
	DROP CONSTRAINT DF_system_config_values_last_modified_date
GO
ALTER TABLE dbo.system_config_values
	DROP CONSTRAINT DF_system_config_values_row_status
GO
CREATE TABLE dbo.Tmp_system_config_values
	(
	system_config_name char(50) NOT NULL,
	text_value varchar(100) NULL,
	date_value datetime NULL,
	int_value int NULL,
	real_value real NULL,
	money_value money NULL,
	prev_date_value datetime NULL,
	sql_id varchar(20) NOT NULL,
	user_id varchar(20) NOT NULL,
	creation_date datetime NOT NULL,
	last_modified_date datetime NOT NULL,
	row_status char(1) NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_system_config_values SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE dbo.Tmp_system_config_values ADD CONSTRAINT
	DF_system_config_values_sql_id DEFAULT (user_name()) FOR sql_id
GO
ALTER TABLE dbo.Tmp_system_config_values ADD CONSTRAINT
	DF_system_config_values_user_id DEFAULT (user_name()) FOR user_id
GO
ALTER TABLE dbo.Tmp_system_config_values ADD CONSTRAINT
	DF_system_config_values_creation_date DEFAULT (getdate()) FOR creation_date
GO
ALTER TABLE dbo.Tmp_system_config_values ADD CONSTRAINT
	DF_system_config_values_last_modified_date DEFAULT (getdate()) FOR last_modified_date
GO
ALTER TABLE dbo.Tmp_system_config_values ADD CONSTRAINT
	DF_system_config_values_row_status DEFAULT ('A') FOR row_status
GO
IF EXISTS(SELECT * FROM dbo.system_config_values)
	 EXEC('INSERT INTO dbo.Tmp_system_config_values (system_config_name, text_value, date_value, int_value, real_value, money_value, prev_date_value, sql_id, user_id, creation_date, last_modified_date, row_status)
		SELECT system_config_name, text_value, date_value, int_value, real_value, money_value, prev_date_value, sql_id, user_id, creation_date, last_modified_date, row_status FROM dbo.system_config_values WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.system_config_values
GO
EXECUTE sp_rename N'dbo.Tmp_system_config_values', N'system_config_values', 'OBJECT' 
GO
ALTER TABLE dbo.system_config_values ADD CONSTRAINT
	PK_system_config_values PRIMARY KEY CLUSTERED 
	(
	system_config_name
	) WITH( PAD_INDEX = OFF, FILLFACTOR = 90, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
COMMIT
