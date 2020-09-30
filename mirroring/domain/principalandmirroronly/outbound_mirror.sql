use master
go 

--On the master database, create the database master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'mirroruser';
GO

--view master keys
select * 
from sys.symmetric_keys

--Make a certificate for this server instance
USE master;
CREATE CERTIFICATE mirror_B_cert 
   WITH SUBJECT = 'Mirror certificate';
GO

-- view certificates
select *
from sys.certificates

--Create a mirroring endpoint for server instance using the certificate.
CREATE ENDPOINT Endpoint_Mirror
   STATE = STARTED
   AS TCP (
      LISTENER_PORT=5022
      , LISTENER_IP = ALL
   ) 
   FOR DATABASE_MIRRORING ( 
      AUTHENTICATION = CERTIFICATE mirror_B_cert
      , ENCRYPTION = REQUIRED ALGORITHM AES
      , ROLE = ALL
   );
GO

-- view endpoints
select *
from sys.endpoints

--Back up the HOST_B certificate, and copy it to other system, HOST_A
BACKUP CERTIFICATE mirror_B_cert TO FILE = 'C:\temp\mirror_B_cert.cer';
GO

-- copy certificate to principal