-- Which works perfectly, but takes much longer to run. 

--So maybe you're wondering what all the other parameters to fn_dump_dblog are for? They are for specifying the media families of a media set that has more than one media family.

--Here's an example using a log backup striped across two files:

    BACKUP LOG FNDBLogTest
        TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Log3_1.bak',
        DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Log3_2.bak'
        WITH INIT;
    GO 
