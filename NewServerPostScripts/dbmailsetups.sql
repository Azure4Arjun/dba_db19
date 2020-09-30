USE [master]
GO
sp_configure 'show advanced options',1
GO
RECONFIGURE WITH OVERRIDE
GO
sp_configure 'Database Mail XPs',1
GO
RECONFIGURE 
GO
-- Create a New Mail Profile for Notifications
EXECUTE msdb.dbo.sysmail_add_profile_sp
       @profile_name = 'CON-SQL-SIT01',
       @description = 'Profile for sending Automated DBA Notifications'
GO
-- Set the New Profile as the Default
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'CON-SQL-SIT01',
    @principal_name = 'public',
    @is_default = 1 ;
GO
-- Create an Account for the Notifications
EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = 'CON-SQL-SIT01',
    @description = 'Account for Automated DBA Notifications',
    @email_address = 'CON-SQL-SIT01@piedmontng.com',  -- Change This
    @display_name = 'CON-SQL-SIT01@piedmontng.com',
    @replyto_address = 'CON-SQL-SIT01@piedmontng.com',
    @mailserver_name = 'lnhub.piedmontng.com'  -- Change This
GO
-- Add the Account to the Profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'CON-SQL-SIT01',
    @account_name = 'CON-SQL-SIT01',
    @sequence_number = 1
GO
