--=================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 11/10/09
-- Description: Script to move tempdb off of the c drive to an 
--              alternate drive .
--=================================================================

ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, FILENAME = 'F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\tempdb.mdf')
GO

ALTER DATABASE tempdb MODIFY FILE (NAME = templog, FILENAME = 'S:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Log\templog.ldf')
GO
