-----------------------------------------------
-- Step 5: Clean Up
-- Run only if you want to clean up everything
-----------------------------------------------
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL)
GO
ALTER RESOURCE GOVERNOR DISABLE
GO
DROP FUNCTION dbo.UDFClassifier
GO
DROP WORKLOAD GROUP RestrictedUserGroup
GO
DROP WORKLOAD GROUP PrimaryServerGroup
GO
DROP RESOURCE POOL RestrictedUserPool
GO
DROP RESOURCE POOL PrimaryServerPool
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO