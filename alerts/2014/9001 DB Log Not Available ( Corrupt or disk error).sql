USE [msdb]
GO

/****** Object:  Alert [9001 DB Log Not Available ( Corrupt or disk error)]    Script Date: 3/13/2017 3:52:34 PM ******/
EXEC msdb.dbo.sp_delete_alert @name=N'9001 DB Log Not Available ( Corrupt or disk error)'
GO

/****** Object:  Alert [9001 DB Log Not Available ( Corrupt or disk error)]    Script Date: 3/13/2017 3:52:34 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'9001 DB Log Not Available ( Corrupt or disk error)', 
		@message_id=9001, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=600, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


