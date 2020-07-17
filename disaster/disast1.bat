echo on  H:\DFSEAST.nhradomain.org\NYE-Health\users
rem **** first map drive ****

NET USE w: \\DFSEAST.nhradomain.org\NYE-Health\users\atekulsky @Lawrence92 /user:nyehdomain\atekulsky

xcopy  /F /Y c:\disaster\disast1.bat w:\"DFSEAST.nhradomain.org\NYE-Health\users"\Aron\disaster\*.*

rem copy each item under projects to a backup directory on the server.
xcopy /D /I /S /Y /Z c:\projects\*.* w:\"disaster"\Aron\projects2010\*.*
xcopy /D /I /S /Y /Z c:\worddata\*.* w:\"disaster"\Aron\worddata2010\*.*
xcopy /D /I /S /Y /Z c:\xldata\*.* w:\"disaster"\Aron\xldata2010\*.*
xcopy /D /I /S /Y /Z c:\pptdata\*.* w:\"disaster"\Aron\pptdata2010\*.*
xcopy /D /I /S /Y /Z c:\vsddata\*.* w:\"disaster"\Aron\vsddata2010\*.*
xcopy /D /I /S /Y /Z c:\disaster\*.* w:\"disaster"\Aron\disaster\*.*
rem xcopy /D /I /S /Y /Z c:\work\*.* w:\"disaster"\Aron\work2010\*.*
rem xcopy /D /I /S /Y /Z c:\sqlserver\*.* w:\"disaster"\Aron\sqlserver\*.*
rem ***xcopy /D /I /S /Y /Z c:\lglhold\*.* w:\"disaster"\Aron\lglhold\*.*

NET USE W:/delete


rem NET USE x: \\usnypfls03\data\users\atekulsky xxxxx /user:nyehdomain\atekulsky


rem xcopy /D /I /S /Y /Z C:\VmWare\HardDisks\"windows_7_x32_vm.vmdk"  x:\"My Documents"\vdi-safety\*.*
rem xcopy /D /I /S /Y /Z C:\VmWare\HardDisks\"windows_XP_x32_vm.vmdk" x:\"My Documents"\vdi-safety\*.*
rem xcopy /D /I /S /Y /Z C:\VmWare\HardDisks\"window_7_x64.vmdk"      x:\"My Documents"\vdi-safety\*.*


rem NET USE x:/delete



