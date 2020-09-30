-- Restoring using STOPBEFOREMARK

-- The LSN for the LOP_BEGIN_XACT log record is where we need to restore to just before.

--To do that we need to convert the LSN to the format necessary when using the STOPBEFOREMARK option for RESTORE. The option is documented but the format is not – how helpful!!

--The LSN we have from the log dump above is 0000009d:0000021e:0001. To convert it:

--    Take the rightmost 4 characters (2-byte log record number) and convert to a 5-character decimal number, including leading zeroes, to get stringA
--    Take the middle number (4-byte log block number) and convert to a 10-character decimal number, including leading zeroes, to get stringB
--    Take the leftmost number (4-byte VLF sequence number) and convert to a decimal number, with no leading zeroes, to get stringC
--    The LSN string we need is stringC + stringB + stringA

--So 0000009d:0000021e:0001 becomes '157' + '0000000542' + '00001' = '157000000054200001'. 



    RESTORE DATABASE FNDBLogTest2
        FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Full.bak'
        WITH MOVE 'FNDBLogTest' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\DATA\FNDBLogTest2.mdf',
        MOVE 'FNDBLogTest_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\DATA\FNDBLogTest2_log.ldf',
        REPLACE, NORECOVERY;
    GO

    RESTORE LOG FNDBLogTest2
        FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Log1.bak'
        WITH NORECOVERY;
    GO

    RESTORE LOG FNDBLogTest2
        FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Log2.bak'
        WITH STOPBEFOREMARK = 'lsn:157000000054200001',
        NORECOVERY;
    GO

    RESTORE DATABASE FNDBLogTest2 WITH RECOVERY;
    GO
