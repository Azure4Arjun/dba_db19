-- So I have to specify both media families:

    SELECT COUNT (*) FROM fn_dump_dblog (
        NULL, NULL, 'DISK', 1, 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Log3_1.bak',
        'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Log3_2.bak', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
    GO
