-- I've blogged a bunch about using the undocumented fn_dblog function I helped write (and I've got a lot more to come :-) but here's one I haven't mentioned on my blog before: fn_dump_dblog (although I have talked about it at SQL Connections last year).
-- Here's a scenario: someone dropped a table and you want to find out when it happened and maybe who did it. The default trace has also wrapped so you can't get the DDL trace from there anymore.
-- If the transaction log for the DROP hasn't yet been cleared from the active portion of the log then you'd be able to use fn_dblog to search through the log for the information you need. You might even be able to look in the inactive portion of the log by using trace flag 2536, which instructs the log reader to ignore the log truncation point and dump all possible log records from the log.
-- But what do you do if the pertinent log records just don't exist in the log anymore? They're only in your log backups. You could tediously inch your way through restoring the log backups a few seconds at a time until you find the point at which the DROP took place, and then restore to just before that point so you can get the data back.
-- Or you could save a whole ton of time and use fn_dump_dblog which allows you to dump and search log records from a log backup file, without having to restore the database! 

    USE MASTER;
    GO
    IF DATABASEPROPERTYEX ('FNDBLogTest', 'Version') > 0 DROP DATABASE FNDBLogTest;
    GO

    CREATE DATABASE FNDBLogTest;
    GO
    USE FNDBLogTest;
    GO
    SET NOCOUNT ON;
    GO

    --– Create tables to play with
    CREATE TABLE ProdTable (c1 INT IDENTITY, c2 DATETIME DEFAULT GETDATE (), c3 CHAR (25) DEFAULT 'a');
    CREATE TABLE ProdTable2 (c1 INT IDENTITY, c2 DATETIME DEFAULT GETDATE (), c3 CHAR (25) DEFAULT 'a');
    GO

    INSERT INTO ProdTable DEFAULT VALUES;
    GO 1000

    --– Take initial backups
    BACKUP DATABASE FNDBLogTest TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Full.bak' WITH INIT;
    GO
    BACKUP LOG FNDBLogTest TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\Backup\FNDBLogTest_Log1.bak' WITH INIT;
    GO

    INSERT INTO ProdTable2 DEFAULT VALUES;
    GO 1000

--Now I'll drop the table and add some more log records:

    DROP TABLE ProdTable;
    GO

    INSERT INTO ProdTable2 DEFAULT VALUES;
    GO 1000
