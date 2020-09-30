--=================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 11/10/09
-- Description: Script to move tempdb off of the c drive to an 
--              alternate drive .
--=================================================================

ALTER DATABASE mssqlsystemresource MODIFY FILE (NAME = data, FILENAME = 'F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\mssqlsystemresource.mdf')
GO

ALTER DATABASE mssqlsystemresource MODIFY FILE (NAME = log, FILENAME = 'S:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\mssqlsystemresource.ldf')
GO
