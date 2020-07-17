-- script to initiate manual failover.

-- point to master
USE master

-- do the failover
ALTER DATABASE cdr SET PARTNER FAILOVER

