@echo off
setlocal
cd /d "%~dp0.."
"tools\godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --fixed-fps 60 --quit-after 30000 --log-file tools/logs/demo-test.log -- --demo-test
if errorlevel 1 exit /b %errorlevel%
findstr /c:"KHARUUN_DEMO_RESULT" "tools\logs\demo-test.log" | findstr /c:"failures=0" >nul
if errorlevel 1 exit /b 2
findstr /c:"SCRIPT ERROR:" /c:"ERROR:" "tools\logs\demo-test.log" >nul
if not errorlevel 1 exit /b 3
exit /b 0
