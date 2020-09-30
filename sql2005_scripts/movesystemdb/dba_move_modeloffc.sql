--=================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 11/10/09
-- Description: Script to move model off of the c drive to an 
--              alternate drive .
--=================================================================

ALTER DATABASE model MODIFY FILE (NAME = modeldev, FILENAME = 'F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\model.mdf')
GO

ALTER DATABASE model MODIFY FILE (NAME = modellog, FILENAME = 'S:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Log\modellog.ldf')
GO
