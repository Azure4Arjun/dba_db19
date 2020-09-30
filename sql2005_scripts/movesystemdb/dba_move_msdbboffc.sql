--=================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 11/10/09
-- Description: Script to move msdb off of the c drive to an 
--              alternate drive .
--=================================================================

ALTER DATABASE msdb MODIFY FILE (NAME = MSDBData, FILENAME = 'F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\MSDBData.mdf')
GO

ALTER DATABASE msdb MODIFY FILE (NAME = MSDBLog, FILENAME = 'S:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Log\MSDBLog.ldf')
GO
