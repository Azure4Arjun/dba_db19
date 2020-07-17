-- Listing 2: Code to Back Up a Certificate
USE Master
GO
BACKUP CERTIFICATE MySQLCert
TO FILE = 'C:\temp\MySQLCert'
WITH PRIVATE KEY (file='C:\temp\MySQLCertKey',
ENCRYPTION BY PASSWORD='MyStrongPassword2')