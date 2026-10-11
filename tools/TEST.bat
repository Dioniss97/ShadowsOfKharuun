@echo off
setlocal
cd /d "%~dp0.."
"tools\godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --fixed-fps 60 --quit-after 18000 --log-file tools/logs/logic.log -- --auto-test
if errorlevel 1 exit /b %errorlevel%
findstr /c:"KHARUUN_TEST_RESULT" "tools\logs\logic.log" | findstr /c:"failures=0" >nul
if errorlevel 1 exit /b 2
findstr /c:"SCRIPT ERROR:" /c:"ERROR:" "tools\logs\logic.log" >nul
if not errorlevel 1 exit /b 3
exit /b 0
