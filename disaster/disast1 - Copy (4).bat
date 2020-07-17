echo on
rem **** first map drive ****

NET USE w: \\us37pfls01\data\users\atekulsky @Lawrence92 /user:iie\atekulsky

xcopy  /F /Y c:\disaster\disast1.bat w:\"My Documents"\disaster\*.*

rem copy each item under projects to a backup directory on the server.
xcopy /D /I /S /Y /Z c:\projects\*.* w:\"My Documents"\projects\*.*
xcopy /D /I /S /Y /Z c:\worddata\*.* w:\"My Documents"\worddata\*.*
xcopy /D /I /S /Y /Z c:\xldata\*.* w:\"My Documents"\xldata\*.*
xcopy /D /I /S /Y /Z c:\pptdata\*.* w:\"My Documents"\pptdata\*.*
xcopy /D /I /S /Y /Z c:\vsddata\*.* w:\"My Documents"\vsddata\*.*
xcopy /D /I /S /Y /Z c:\disaster\*.* w:\"My Documents"\disaster\*.*
xcopy /D /I /S /Y /Z c:\work\*.* w:\"My Documents"\work\*.*
xcopy /D /I /S /Y /Z c:\sqlserver\*.* w:\"My Documents"\sqlserver\*.*
rem ***xcopy /D /I /S /Y /Z c:\lglhold\*.* w:\"My Documents"\lglhold\*.*
rem ***xcopy /D /I /S /Y /Z C:\Users\atekulsky\.VirtualBox\HardDisks\"windows 7 x32 vm.vdi" w:\"My Documents"\vdi_safety\*.*
rem ***xcopy /D /I /S /Y /Z C:\Users\atekulsky\.VirtualBox\HardDisks\"windows XP x32 vm.vdi" w:\"My Documents"\vdi_safety\*.*
rem ***xcopy /D /I /S /Y /Z C:\Users\atekulsky\.VirtualBox\HardDisks\"windows 7 x64 vm.vdi" w:\"My Documents"\vdi_safety\*.*


NET USE W:/delete



