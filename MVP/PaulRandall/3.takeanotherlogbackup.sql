-- Now we take another log backup, which clears the log, and contains the log we just looked at.

BACKUP LOG FNDBLogTest TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Log2.bak' WITH INIT;
GO