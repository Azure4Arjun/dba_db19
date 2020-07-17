echo on  N:\203 - Information Technology Shared Data
rem **** first map drive ****

rem ***NET USE w: \\us37pfls01\data\users\atekulsky @Lawrence92 /user:iie\atekulsky
NET USE w: \\us37pfls01\shared @Lawrence92 /user:iie\atekulsky

xcopy  /F /Y c:\disaster\disast1.bat w:\"203 - Information Technology Shared Data"\Aron\disaster\*.*

rem copy each item under projects to a backup directory on the server.
xcopy /D /I /S /Y /Z c:\projects\*.* w:\"203 - Information Technology Shared Data"\Aron\projects2010\*.*
xcopy /D /I /S /Y /Z c:\worddata\*.* w:\"203 - Information Technology Shared Data"\Aron\worddata2010\*.*
xcopy /D /I /S /Y /Z c:\xldata\*.* w:\"203 - Information Technology Shared Data"\Aron\xldata2010\*.*
xcopy /D /I /S /Y /Z c:\pptdata\*.* w:\"203 - Information Technology Shared Data"\Aron\pptdata2010\*.*
xcopy /D /I /S /Y /Z c:\vsddata\*.* w:\"203 - Information Technology Shared Data"\Aron\vsddata2010\*.*
xcopy /D /I /S /Y /Z c:\disaster\*.* w:\"203 - Information Technology Shared Data"\Aron\disaster\*.*
xcopy /D /I /S /Y /Z c:\work\*.* w:\"203 - Information Technology Shared Data"\Aron\work2010\*.*
xcopy /D /I /S /Y /Z c:\sqlserver\*.* w:\"203 - Information Technology Shared Data"\Aron\sqlserver\*.*
rem ***xcopy /D /I /S /Y /Z c:\lglhold\*.* w:\"203 - Information Technology Shared Data"\Aron\lglhold\*.*

NET USE W:/delete

rem ***NET USE w: \\us37pfls01\data\users\atekulsky @Lawrence92 /user:iie\atekulsky


rem ***xcopy /D /I /S /Y /Z C:\VmWare\HardDisks\"windows_7_x32_vm.vmdk"  w:\"My Documents"\vdi-safety\*.*
rem ***xcopy /D /I /S /Y /Z C:\VmWare\HardDisks\"windows_XP_x32_vm.vmdk" w:\"My Documents"\vdi-safety\*.*
rem ***xcopy /D /I /S /Y /Z C:\VmWare\HardDisks\"window_7_x64.vmdk"      w:\"My Documents"\vdi-safety\*.*


rem ***NET USE W:/delete



