
--------------------------------------
-- inbound principal server script 
-- to run on principal
--------------------------------------
--Create a login on HOST_A for HOST_B
USE master;
CREATE LOGIN mirror_user WITH PASSWORD = 'mirroruser';
GO

-- view logins
SELECT *
 FROM sys.server_principals

--Create a user for that login
CREATE USER mirror_user FOR LOGIN mirror_user;
GO

-- view users
SELECT *
 FROM sys.sysusers;

--Associate the certificate with the user
CREATE CERTIFICATE mirror_B_cert
   AUTHORIZATION mirror_user
   FROM FILE = 'C:\temp\mirror_B_cert.cer'
GO

select *
from sys.certificates

--Grant CONNECT permission on the login for the remote mirroring endpoint
GRANT CONNECT ON ENDPOINT::Endpoint_Principal TO mirror_user;
GO

-- view the endpoints
select *
from sys.endpoints
