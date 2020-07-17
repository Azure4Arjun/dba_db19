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
       @profile_name = 'E-TEKnologies',
       @description = 'Profile for sending Automated DBA Notifications'
GO
-- Set the New Profile as the Default
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'E-TEKnologies',
    @principal_name = 'public',
    @is_default = 1 ;
GO
-- Create an Account for the Notifications
EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = 'E-TEKnologies',
    @description = 'Account for Automated DBA Notifications',
    @email_address = 'E-TEKnologies@E-TEKnologies.net',  -- Change This
    @display_name = 'E-TEKnologies@E-TEKnologies.net',
    @replyto_address = 'E-TEKnologies@E-TEKnologies.net',
    @mailserver_name = 'lnhub.E-TEKnologies.net'  -- Change This
GO
-- Add the Account to the Profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'E-TEKnologies',
    @account_name = 'E-TEKnologies',
    @sequence_number = 1
GO
