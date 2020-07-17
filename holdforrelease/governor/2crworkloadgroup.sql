-----------------------------------------------
-- Step 2: Create Workload Group
-----------------------------------------------
-- Creating Workload Group for Report Server
CREATE WORKLOAD GROUP RestrictedUserGroup
	USING RestrictedUserPool ;
GO
-- Creating Workload Group for OLTP Primary Server
CREATE WORKLOAD GROUP PrimaryServerGroup
	USING PrimaryServerPool ;
GO