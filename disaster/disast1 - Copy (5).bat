echo on
rem **** first map drive ****

NET USE w: \\us37pfls01\data\users\atekulsky @Lawrence92 /user:iie\atekulsky

xcopy  /F /Y c:\disaster\disast1.bat w:\"My Documents"\disaster\*.*

rem copy each item under projects to a backup directory on the server.
xcopy /D /I /S /Y /Z c:\projects\*.* w:\"My Documents"\projects2010\*.*
xcopy /D /I /S /Y /Z c:\worddata\*.* w:\"My Documents"\worddata2010\*.*
xcopy /D /I /S /Y /Z c:\xldata\*.* w:\"My Documents"\xldata2010\*.*
xcopy /D /I /S /Y /Z c:\pptdata\*.* w:\"My Documents"\pptdata2010\*.*
xcopy /D /I /S /Y /Z c:\vsddata\*.* w:\"My Documents"\vsddata2010\*.*
xcopy /D /I /S /Y /Z c:\disaster\*.* w:\"My Documents"\disaster\*.*
xcopy /D /I /S /Y /Z c:\work\*.* w:\"My Documents"\work2010\*.*
xcopy /D /I /S /Y /Z c:\sqlserver\*.* w:\"My Documents"\sqlserver\*.*
rem ***xcopy /D /I /S /Y /Z c:\lglhold\*.* w:\"My Documents"\lglhold\*.*
xcopy /D /I /S /Y /Z C:\virtualbox\HardDisks\"windows 7 x32 vm.vdi" w:\"My Documents"\vdi-safety\*.*
xcopy /D /I /S /Y /Z C:\VirtualBox\HardDisks\"windows XP x32 vm.vdi" w:\"My Documents"\vdi-safety\*.*
xcopy /D /I /S /Y /Z C:\VirtualBox\HardDisks\"windows 7 x64 vm.vdi" w:\"My Documents"\vdi-safety\*.*


NET USE W:/delete



