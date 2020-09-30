DECLARE @icount	int

SET @icount = 0;

WHILE (@icount < 500)
	BEGIN 
	
	BEGIN TRAN

		--SELECT *
		--	FROM [dba_db08].[dbo].[system_config_values] WITH (TABLOCKX);
		--	--FROM [dbo].[system_config_values] WITH (XLOCK);
			
			INSERT INTO [test5].[dbo].[aronspid] WITH (TABLOCKX)
				  ([bspid]
				,[blk_status])
			VALUES
				 (1,
				'testing') 
				
		WAITFOR DELAY '00:00:03'

	SET @icount = @icount + 1;
	END