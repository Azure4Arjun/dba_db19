echo on
rem **** first map drive ****

rem ***NET USE w: \\us37pfls01\data\users\atekulsky @Lawrence92 /user:iie\atekulsky


rem copy each item under projects to a backup directory on the server.
rem ***xcopy /D /I /S /Y /Z C:\VmWare\HardDisks\"windows_7_x32_vm.vmdk" w:\"My Documents"\vdi-safety\*.*
xcopy /D /I /S /Y /Z C:\VmWare\HardDisks\"windows_XP_x32_vm.vmdk" w:\"My Documents"\vdi-safety\*.*
xcopy /D /I /S /Y /Z C:\temp\"windows_7_x64.vmdk" w:\"My Documents"\vdi-safety\*.*


NET USE W:/delete



