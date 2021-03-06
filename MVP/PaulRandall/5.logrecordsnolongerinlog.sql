-- So what if the log records are no longer in the log? You can use the fn_dump_dblog function. For instance, here is how you use it to look in the FNDBLogTest_Log2.bak backup:

SELECT COUNT (*) FROM fn_dump_dblog (
    NULL, NULL, 'DISK', 1, 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Log2.bak',
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
GO

-- You have to specify all the DEFAULT parameters (63 of them!) or it won't work. The other parameters are:
--
    --Starting LSN (usually just NULL)
    --Ending LSN (again, usually just NULL)
    --Type of file (DISK or TAPE)
    --Backup number within the backup file (for multi-backup media sets)
    --File name

--So you could do the same query as I did above
SELECT
    [Current LSN],
    [Operation],
    [Context],
    [Transaction ID],
    [Description]
FROM fn_dump_dblog (
    NULL, NULL, 'DISK', 1, 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Log2.bak',
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
    DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
    (SELECT [Transaction ID] AS tid
     FROM fn_dump_dblog (
         NULL, NULL, 'DISK', 1, 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Log2.bak',
         DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
         DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
         DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
         DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
         DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
         DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
         DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
         DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
         DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
     WHERE [Transaction Name] LIKE '%DROPOBJ%') fd
WHERE [Transaction ID] = fd.tid;
GO 
