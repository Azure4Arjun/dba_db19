			INSERT INTO [test5].[dbo].[arondeadlock1] WITH (TABLOCKX)
				  ([bspid]
				,[blk_status])
			VALUES
				 (1,
				'testing') 
