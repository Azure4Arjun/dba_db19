--======================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 11/10/09
-- Description: Script to verify new file location for system database.
--              alternate drive .
--======================================================================

SELECT name, Physical_name as CurrentLocation, state_desc
FROM sys.master_files
