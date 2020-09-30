			INSERT INTO [test5].[dbo].[arondeadlock2] WITH (TABLOCKX)
				  ([bspid]
				,[blk_status])
			VALUES
				 (1,
				'testing') 
