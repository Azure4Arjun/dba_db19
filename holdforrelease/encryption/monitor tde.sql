-- Listing 4: Code to Monitor TDE
USE master
GO
SELECT * FROM sys.certificates
-- encryption_state = 3 is encrypted
SELECT * FROM sys.dm_database_encryption_keys
WHERE encryption_state = 3;
