--------------------------------------
-- outbound principal server script 
-- to run on principal
--------------------------------------

use master
go

--On the master database, create the database master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'principaluser';
GO

-- view the master keys
select *
from sys.symmetric_keys


--Make a certificate for this server instance
USE master;
CREATE CERTIFICATE principal_A_cert 
   WITH SUBJECT = 'Principal  certificate';
GO

-- view the certificates
select *
from sys.certificates

--Create a mirroring endpoint for server instance using the certificate.
CREATE ENDPOINT Endpoint_Principal
   STATE = STARTED
   AS TCP (
      LISTENER_PORT=5022
      , LISTENER_IP = ALL
   ) 
   FOR DATABASE_MIRRORING ( 
      AUTHENTICATION = CERTIFICATE principal_A_cert
      , ENCRYPTION = REQUIRED ALGORITHM RC4
      , ROLE = ALL
   );
GO

-- view the endpoints
SELECT name, role_desc, state_desc, connection_auth_desc, encryption_algorithm_desc 
FROM sys.database_mirroring_endpoints;

--Back up the HOST_A certificate, and copy it to other system, HOST_B
--CREATE CERTIFICATE principal_A_cert 
		BACKUP CERTIFICATE principal_A_cert TO FILE = 'C:\temp\principal_A_cert.cer';
GO

-- copy certificate to mirror