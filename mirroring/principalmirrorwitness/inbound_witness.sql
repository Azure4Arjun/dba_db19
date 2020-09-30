
--------------------------------------
-- inbound witness server script 
-- to run on witness
--------------------------------------
--Create a login on witness for principal and mirror
USE master;
CREATE LOGIN principal_user WITH PASSWORD = 'principaluser';
GO

CREATE LOGIN mirror_user WITH PASSWORD = 'mirroruser';
GO

-- view logins
SELECT *
 FROM sys.server_principals

--Create a user for that login
CREATE USER principal_user FOR LOGIN principal_user;
GO

CREATE USER mirror_user FOR LOGIN mirror_user;
GO

-- view users
SELECT *
 FROM sys.sysusers;

--Associate the certificate with principal and mirror users
CREATE CERTIFICATE principal_A_cert
   AUTHORIZATION principal_user
   FROM FILE = 'C:\temp\principal_A_cert.cer'
GO

CREATE CERTIFICATE mirror_B_cert
   AUTHORIZATION mirror_user
   FROM FILE = 'C:\temp\mirror_B_cert.cer'
GO

-- view the certificates
select *
 from sys.certificates

--Grant CONNECT permission on the login for the remote mirroring endpoint
GRANT CONNECT ON ENDPOINT::Endpoint_Witness TO principal_user;
GRANT CONNECT ON ENDPOINT::Endpoint_Witness TO mirror_user;
GO

-- view the endpoints
select *
from sys.endpoints
