--------------------------------------
-- outbound Witness server script 
-- to run on Witness - domain id's
--------------------------------------

CREATE ENDPOINT Endpoint_Witness
    STATE=STARTED 
    AS TCP (LISTENER_PORT=5022) 
    FOR DATABASE_MIRRORING (ROLE=WITNESS)
GO


--Create a login for the partner server instances,
--which are both running as Mydomain\dbousername:
USE master ;
GO
CREATE LOGIN iie\dbservices FROM WINDOWS ;
GO
--Grant connect permissions on endpoint to login account of partners.
GRANT CONNECT ON ENDPOINT::Endpoint_Witness TO [iie\dbservices];
GO
-- view logins
SELECT *
 FROM sys.server_principals

-- view users
SELECT *
 FROM sys.sysusers;

-- view the endpoints
select *
from sys.endpoints
