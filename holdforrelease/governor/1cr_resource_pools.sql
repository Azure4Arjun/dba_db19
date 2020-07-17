-----------------------------------------------
-- Step 1: Create Resource Pool
-----------------------------------------------
-- Creating Resource Pool for Report Server
CREATE RESOURCE POOL RestrictedUserPool
WITH
( MIN_CPU_PERCENT=0,
	MAX_CPU_PERCENT=25,
	MIN_MEMORY_PERCENT=0,
	MAX_MEMORY_PERCENT=25)
GO

-- Creating Resource Pool for OLTP Primary Server
CREATE RESOURCE POOL PrimaryServerPool
WITH
( MIN_CPU_PERCENT=0,
	MAX_CPU_PERCENT=100,
	MIN_MEMORY_PERCENT=0,
	MAX_MEMORY_PERCENT=100)
GO