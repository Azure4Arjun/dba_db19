echo on
rem copy each item under projects to a backup directory on the server.
xcopy /d /i /s /y /z c:\projects\*.* h:\"My Documents"\projects\*.*
xcopy /d /i /s /y /z c:\worddata\*.* h:\"My Documents"\worddata\*.*
xcopy /d /i /s /y /z c:\xldata\*.* h:\"My Documents"\xldata\*.*
xcopy /d /i /s /y /z c:\pptdata\*.* h:\"My Documents"\pptdata\*.*
xcopy /d /i /s /y /z c:\vsddata\*.* h:\"My Documents"\vsddata\*.*
xcopy /d /i /s /y /z c:\disaster\*.* h:\"My Documents"\disaster\*.*
xcopy /d /i /s /y /z c:\work\*.* h:\"My Documents"\work\*.*
xcopy /d /i /s /y /z c:\sqlserver\*.* h:\"My Documents"\sqlserver\*.*
rem ***xcopy /d /i /s /y /z c:\lglhold\*.* h:\"My Documents"\lglhold\*.*





