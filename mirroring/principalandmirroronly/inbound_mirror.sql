--Create a login on HOST_B for HOST_A
USE master;
CREATE LOGIN principal_user WITH PASSWORD = 'principaluser';
GO

--view logins
select *
from sys.server_principals

--Create a user for that login
CREATE USER principal_user FOR LOGIN principal_user;
GO

-- view users
select *
from sys.sysusers


--Associate the certificate with the user
CREATE CERTIFICATE principal_A_cert
   AUTHORIZATION principal_user
   FROM FILE = 'C:\temp\principal_A_cert.cer'
GO

-- view certificates
select *
from sys.certificates

--Grant CONNECT permission on the login for the remote mirroring endpoint
GRANT CONNECT ON ENDPOINT::Endpoint_Mirror TO principal_user;
GO

-- view endpoint
select *
from sys.endpoints
