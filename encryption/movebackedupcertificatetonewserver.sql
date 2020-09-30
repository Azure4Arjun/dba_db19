-- Listing 3: Code to Move a Backed Up Certificate to a New SQL Server Instance
USE Master
GO
-- Create a new master key.
CREATE MASTER KEY ENCRYPTION
BY PASSWORD = 'MyNewStrongPassword'
-- Restore the certificate.
CREATE CERTIFICATE MySQLCert
FROM FILE='c:\temp\MySQLCert'
WITH PRIVATE KEY (
FILE = 'c:\temp\MySQLCertKey',
DECRYPTION BY PASSWORD='MyStrongPassword2')