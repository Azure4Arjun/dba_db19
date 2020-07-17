USE [master]
GO

/****** Object:  UserDefinedFunction [dbo].[UDFClassifier]    Script Date: 5/16/2016 1:12:18 PM ******/
DROP FUNCTION [dbo].[UDFClassifier]
GO

/****** Object:  UserDefinedFunction [dbo].[UDFClassifier]    Script Date: 5/16/2016 1:12:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-----------------------------------------------
-- Step 3: Create UDF to Route Workload Group
-----------------------------------------------
CREATE FUNCTION [dbo].[UDFClassifier]()
RETURNS SYSNAME
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @WorkloadGroup AS SYSNAME

--	IF(SUSER_NAME() = 'testlogin')
	IF(SUSER_NAME() IN ('PIEDMONT\DixonJa', 'PIEDMONT\ColliKa'))
		--SET @WorkloadGroup = 'RestrictedUserGroup'
		SET @WorkloadGroup = 'RestrictedUserGroup'
--ELSE IF (SUSER_NAME() = 'PrimaryUser')
	ELSE
		SET @WorkloadGroup = 'default'

RETURN @WorkloadGroup
END

GO


