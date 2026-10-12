param([ValidateSet('logic','capture','playthrough','tactical','tactical_capture')][string]$Mode = 'logic')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = Join-Path $PSScriptRoot 'godot\Godot_v4.7.2-stable_win64_console.exe'
if (-not (Test-Path -LiteralPath $enginePath)) { throw 'Falta Godot portátil en tools/godot.' }
$logPath = Join-Path $PSScriptRoot ('logs\' + $Mode + '.log')
$engineArgs = @('--path', $projectRoot, '--fixed-fps', '60', '--quit-after', '30000', '--log-file', $logPath)
$captureMode = $Mode -in @('capture','tactical_capture')
if (-not $captureMode) { $engineArgs += '--headless' }
$engineArgs += @('--', $(if ($captureMode) { '--demo-capture' } else { '--demo-test' }))
& $enginePath @engineArgs
$engineExit = $LASTEXITCODE
if ($engineExit -ne 0) { exit $engineExit }
$logText = Get-Content -LiteralPath $logPath -Raw
if ($logText -match 'SCRIPT ERROR|(?m)^ERROR:') { Write-Error 'Godot ha emitido errores.'; exit 3 }
if ($logText -notmatch 'KHARUUN_DEMO_RESULT.*failures=0') { Write-Error 'La prueba no produjo una confirmación de éxito.'; exit 2 }
exit 0
