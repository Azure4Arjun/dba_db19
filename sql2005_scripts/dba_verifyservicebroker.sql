--=============================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 11/10/09
-- Description: Script to verify service broker is enabled for database mail.
--              alternate drive .
--=============================================================================

SELECT is_broker_enabled 
FROM sys.databases
WHERE name = N'msdb';