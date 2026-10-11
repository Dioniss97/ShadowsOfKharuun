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
start "Shadows of Kharuun" "%GODOT%" --path "%~dp0." --log-file "%~dp0tools\logs\game.log" %*
endlocal
