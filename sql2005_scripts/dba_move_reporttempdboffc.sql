--=================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 11/10/09
-- Description: Script to move tempdb off of the c drive to an 
--              alternate drive .
--=================================================================

ALTER DATABASE ReportServerTempDB MODIFY FILE (NAME = data, FILENAME = 'E:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\ReportServerTempDB.mdf')
GO

ALTER DATABASE ReportServerTempDB MODIFY FILE (NAME = log, FILENAME = 'E:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Log\ReportServerTempDB_log.ldf')
GO
