--=================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 11/10/09
-- Description: Script to move model off of the c drive to an 
--              alternate drive .
--=================================================================

ALTER DATABASE model MODIFY FILE (NAME = modeldev, FILENAME = 'S:\MSSQL12.MSSQLSERVER\DATA01\SQLData\model.mdf')
GO

ALTER DATABASE model MODIFY FILE (NAME = modellog, FILENAME = 'T:\MSSQL12.MSSQLSERVER\TRAN01\SQLLogs\modellog.ldf')
GO
