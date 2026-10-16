@echo off
setlocal
cd /d "%~dp0"
set "GODOT=%~dp0tools\godot\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (
  echo No se encuentra Godot 4.7.2 portatil.
  echo Coloca Godot_v4.7.2-stable_win64.exe en tools\godot.
  echo Descarga oficial: https://godotengine.org/download/windows/
  pause
  exit /b 1
)
if not exist "%~dp0tools\logs" mkdir "%~dp0tools\logs"
"%GODOT%" --headless --editor --import --path "%~dp0." --log-file "%~dp0tools\logs\import.log"
if errorlevel 1 goto import_failed
findstr /c:"SCRIPT ERROR:" /c:"ERROR:" "%~dp0tools\logs\import.log" >nul
if not errorlevel 1 goto import_failed
start "Shadows of Kharuun" "%GODOT%" --path "%~dp0." --log-file "%~dp0tools\logs\game.log" %*
endlocal
exit /b 0

:import_failed
echo No se han podido preparar los recursos de la demo.
echo Revisa tools\logs\import.log.
pause
exit /b 1
