-----------------------------------------------
-- Step 4: Enable Resource Governer
-- with UDFClassifier
-----------------------------------------------
ALTER RESOURCE GOVERNOR
WITH (CLASSIFIER_FUNCTION=dbo.UDFClassifier);
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO
