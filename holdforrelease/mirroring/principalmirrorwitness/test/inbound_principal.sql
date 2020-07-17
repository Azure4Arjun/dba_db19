
--------------------------------------
-- inbound principal server script 
-- to run on principal
--------------------------------------
--Create a login on principal for mirror and witness
USE master;
CREATE LOGIN mirror_user WITH PASSWORD = 'mirroruser';
GO

CREATE LOGIN witness_user WITH PASSWORD = 'witnessuser';
GO

-- view logins
SELECT *
 FROM sys.server_principals

--Create a user for that login
CREATE USER mirror_user FOR LOGIN mirror_user;
GO

CREATE USER witness_user FOR LOGIN witness_user;
GO

-- view users
SELECT *
 FROM sys.sysusers;

--Associate the certificate with the user
CREATE CERTIFICATE mirror_B_cert
   AUTHORIZATION mirror_user
   FROM FILE = 'C:\temp\mirror_B_cert.cer'
GO

CREATE CERTIFICATE witness_C_cert
   AUTHORIZATION witness_user
   FROM FILE = 'C:\temp\witness_C_cert.cer'
GO

--Grant CONNECT permission on the login for the remote mirroring endpoint
GRANT CONNECT ON ENDPOINT::Endpoint_Principal TO mirror_user;
GO

GRANT CONNECT ON ENDPOINT::Endpoint_Principal TO witness_user;
GO

-- view the endpoints
select *
from sys.endpoints
