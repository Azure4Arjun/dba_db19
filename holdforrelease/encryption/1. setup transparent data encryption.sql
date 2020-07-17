-- Listing 1: Code to Enable TDE on a Database
-- The master key must be in the master database.
USE Master;
GO
-- Create the master key.
CREATE MASTER KEY ENCRYPTION
BY PASSWORD='MyStrongPassword';
GO
-- Create a certificate.
CREATE CERTIFICATE MySQLCert
WITH SUBJECT='MyDatabase DEK';
GO
-- Use the database to enable TDE.
USE MyDatabase
GO
-- Associate the certificate to MyDatabase.
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_128 -- AES_128, AES_192, AES_256, TRIPLE_DES_3KEY
ENCRYPTION BY SERVER CERTIFICATE MySQLCert;
GO
-- Encrypt the database.
ALTER DATABASE MyDatabase
SET ENCRYPTION ON;
GO