Ahk2Exe.exe /in EveryfishCoreKeeper.ahk /out EveryfishCoreKeeper-x32.exe /bin "%AHK%\v2\AutoHotkey32.exe"
if %errorlevel% neq 0 exit /b %errorlevel%
Ahk2Exe.exe /in EveryfishCoreKeeper.ahk /out EveryfishCoreKeeper-x64.exe /bin "%AHK%\v2\AutoHotkey64.exe"
if %errorlevel% neq 0 exit /b %errorlevel%
