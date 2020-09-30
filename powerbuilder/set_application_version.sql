UPDATE dbo.application_version
      SET application_version = 7.15,
          modified_by         = 'dbo'
   WHERE application_name    = 'GRANTEE'