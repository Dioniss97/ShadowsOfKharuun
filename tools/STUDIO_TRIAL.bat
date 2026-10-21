@echo off
setlocal
cd /d "%~dp0.."
set "TRIAL_GODOT=%CD%\tools\godot\Godot_v4.7.2-stable_win64_console.exe"
if not exist "%TRIAL_GODOT%" (
  echo Coloca Godot_v4.7.2-stable_win64_console.exe en tools\godot.
  pause
  exit /b 1
)
if not exist "tools\logs" mkdir "tools\logs"
"%TRIAL_GODOT%" --headless --editor --import --path . --log-file tools/logs/studio-trial-import.log
if errorlevel 1 goto failed
findstr /c:"SCRIPT ERROR:" /c:"ERROR:" tools\logs\studio-trial-import.log >nul
if not errorlevel 1 goto failed
"%TRIAL_GODOT%" --path . --script res://tools/blender/preview_studio_trial.gd --resolution 1100x1100 --log-file tools/logs/studio-trial-viewer.log -- --interactive
exit /b %errorlevel%
:failed
echo No se ha podido importar el ensayo. Revisa tools\logs\studio-trial-import.log.
pause
exit /b 1
