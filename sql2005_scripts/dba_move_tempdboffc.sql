--=================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 11/10/09
-- Description: Script to move tempdb off of the c drive to an 
--              alternate drive .
--=================================================================

ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, FILENAME = 'F:\TEMPDB01\MSSQL\BIETLSIT\TEMPDB01\tempdb.mdf')
----ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, FILENAME = 'F:\MSSQL\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\tempdb.mdf')
--ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev2, FILENAME = 'F:\TEMPDB01\MSSQL\BIETLSIT\TEMPDB01\tempdev2.ndf')
--ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev2, FILENAME = 'F:\MSSQL\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\tempdev2.ndf')

--ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev3, FILENAME = 'F:\TEMPDB01\MSSQL\BIETLSIT\TEMPDB01\tempdev3.ndf')

--ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev4, FILENAME = 'F:\TEMPDB01\MSSQL\BIETLSIT\TEMPDB01\tempdev4.ndf')

--ALTER DATABASE tempdb MODIFY FILE (NAME = tempdb2, FILENAME = 'F:\TEMPDB01\MSSQL\BIETLSIT\TEMPDB01\tempdb2.ndf')
----ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, FILENAME = 'F:\MSSQL\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\tempdb.mdf')
--ALTER DATABASE tempdb MODIFY FILE (NAME = tempdb3, FILENAME = 'F:\TEMPDB01\MSSQL\BIETLSIT\TEMPDB01\tempdb3.ndf')

--ALTER DATABASE tempdb MODIFY FILE (NAME = tempdb4, FILENAME = 'F:\TEMPDB01\MSSQL\BIETLSIT\TEMPDB01\tempdb4.ndf')

--ALTER DATABASE tempdb MODIFY FILE (NAME = tempdeb2, FILENAME = 'F:\TEMPDB01\MSSQL\BIETLSIT\TEMPDB01\tempdeb2.ndf')

--ALTER DATABASE tempdb MODIFY FILE (NAME = tempdeb3, FILENAME = 'F:\TEMPDB01\MSSQL\BIETLSIT\TEMPDB01\tempdeb3.ndf')

--ALTER DATABASE tempdb MODIFY FILE (NAME = tempdeb4, FILENAME = 'F:\TEMPDB01\MSSQL\BIETLSIT\TEMPDB01\tempdeb4.ndf')

--ALTER DATABASE tempdb MODIFY FILE (NAME = tempsit2, FILENAME = 'F:\TEMPDB01\MSSQL\BIETLSIT\TEMPDB01\tempsit2.ndf')

GO

--ALTER DATABASE tempdb MODIFY FILE (NAME = templog, FILENAME = 'F:\TRAN01\MSSQL\BIETLSIT\TRAN01\templog.ldf')
--GO
