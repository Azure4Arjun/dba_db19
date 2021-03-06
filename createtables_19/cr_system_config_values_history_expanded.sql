/*
   Monday, April 08, 20132:32:27 PM
   User: 
   Server: ATEKLT\DBS2012
   Database: dba_db08
   Application: 
*/
USE [dba_db16]
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
ALTER TABLE dbo.system_config_values_history
	DROP CONSTRAINT DF__system_co__sql_i__1BFD2C07
GO
ALTER TABLE dbo.system_config_values_history
	DROP CONSTRAINT DF__system_co__user___1CF15040
GO
ALTER TABLE dbo.system_config_values_history
	DROP CONSTRAINT DF__system_co__creat__1DE57479
GO
ALTER TABLE dbo.system_config_values_history
	DROP CONSTRAINT DF__system_co__last___1ED998B2
GO
ALTER TABLE dbo.system_config_values_history
	DROP CONSTRAINT DF__system_co__row_s__1FCDBCEB
GO
CREATE TABLE dbo.Tmp_system_config_values_history
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
ALTER TABLE dbo.Tmp_system_config_values_history SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE dbo.Tmp_system_config_values_history ADD CONSTRAINT
	DF__system_co__sql_i__1BFD2C07 DEFAULT (user_name()) FOR sql_id
GO
ALTER TABLE dbo.Tmp_system_config_values_history ADD CONSTRAINT
	DF__system_co__user___1CF15040 DEFAULT (user_name()) FOR user_id
GO
ALTER TABLE dbo.Tmp_system_config_values_history ADD CONSTRAINT
	DF__system_co__creat__1DE57479 DEFAULT (getdate()) FOR creation_date
GO
ALTER TABLE dbo.Tmp_system_config_values_history ADD CONSTRAINT
	DF__system_co__last___1ED998B2 DEFAULT (getdate()) FOR last_modified_date
GO
ALTER TABLE dbo.Tmp_system_config_values_history ADD CONSTRAINT
	DF__system_co__row_s__1FCDBCEB DEFAULT ('A') FOR row_status
GO
IF EXISTS(SELECT * FROM dbo.system_config_values_history)
	 EXEC('INSERT INTO dbo.Tmp_system_config_values_history (system_config_name, text_value, date_value, int_value, real_value, money_value, prev_date_value, sql_id, user_id, creation_date, last_modified_date, row_status)
		SELECT system_config_name, text_value, date_value, int_value, real_value, money_value, prev_date_value, sql_id, user_id, creation_date, last_modified_date, row_status FROM dbo.system_config_values_history WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.system_config_values_history
GO
EXECUTE sp_rename N'dbo.Tmp_system_config_values_history', N'system_config_values_history', 'OBJECT' 
GO
ALTER TABLE dbo.system_config_values_history ADD CONSTRAINT
	pk_conf_hist PRIMARY KEY CLUSTERED 
	(
	system_config_name,
	last_modified_date
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
COMMIT
