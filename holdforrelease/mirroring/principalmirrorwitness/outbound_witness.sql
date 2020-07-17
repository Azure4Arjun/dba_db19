--------------------------------------
-- inbound witness server script 
-- to run on witness
--------------------------------------
--Create a login on witness for witness
USE master;
--CREATE LOGIN principal_user WITH PASSWORD = 'principaluser';
--GO
--
--CREATE LOGIN mirror_user WITH PASSWORD = 'mirroruser';
--GO

CREATE LOGIN witness_user WITH PASSWORD = 'witnessuser';
GO

-- view logins
SELECT *
 FROM sys.server_principals

--Create a user for that login
--CREATE USER principal_user FOR LOGIN principal_user;
--GO
--
--CREATE USER mirror_user FOR LOGIN mirror_user;
--GO

CREATE USER witness_user FOR LOGIN witness_user;
GO

-- view users
SELECT *
 FROM sys.sysusers;

--On the master database, create the database master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'witnessuser';
GO

-- view the master keys
select *
from sys.symmetric_keys


--Make a certificate for this server instance
--USE master;
CREATE CERTIFICATE witness_C_cert 
   WITH SUBJECT = 'Witness  certificate';
GO

-- view the certificates
select *
from sys.certificates

--Create a mirroring endpoint for server instance using the certificate.
CREATE ENDPOINT Endpoint_Witness
   STATE = STARTED
   AS TCP (
      LISTENER_PORT=5022
      , LISTENER_IP = ALL
   ) 
   FOR DATABASE_MIRRORING ( 
      AUTHENTICATION = CERTIFICATE witness_C_cert
      , ENCRYPTION = REQUIRED ALGORITHM AES
      , ROLE = WITNESS
   );
GO

-- view the endpoints
SELECT name, role_desc, state_desc, connection_auth_desc, encryption_algorithm_desc 
FROM sys.database_mirroring_endpoints;

--Back up the HOST_C certificate, and copy it to other system, HOST_B and HOST_B
		BACKUP CERTIFICATE witness_C_cert TO FILE = 'C:\temp\witness_C_cert.cer';
GO

-- copy certificate to mirror and principal