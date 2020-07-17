--------------------------------------
-- outbound principal server script 
-- to run on principal - domain id's
--------------------------------------

CREATE ENDPOINT Endpoint_Principal
    STATE=STARTED 
    AS TCP (LISTENER_PORT=5022) 
    FOR DATABASE_MIRRORING (ROLE=PARTNER)
GO


--Partners under same domain user; login already exists in master.
--Create a login for the witness server instance,
--which is running as Somedomain\witnessuser:
USE master ;
GO
CREATE LOGIN iie\dbservices FROM WINDOWS ;
GO
-- view logins
SELECT *
 FROM sys.server_principals

-- view users
SELECT *
 FROM sys.sysusers;

-- Grant connect permissions on endpoint to login account of witness.
GRANT CONNECT ON ENDPOINT::Endpoint_Principal TO [iie\dbservices];
GO
-- view the endpoints
select *
from sys.endpoints
