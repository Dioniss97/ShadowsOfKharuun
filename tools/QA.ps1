param([ValidateSet('logic','capture','playthrough')][string]$Mode = 'logic')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = Join-Path $PSScriptRoot 'godot\Godot_v4.7.2-stable_win64_console.exe'
if (-not (Test-Path -LiteralPath $enginePath)) { throw 'Falta Godot portátil en tools/godot.' }
$logPath = Join-Path $PSScriptRoot ('logs\' + $Mode + '.log')
$engineArgs = @('--path', $projectRoot, '--fixed-fps', '60', '--quit-after', '18000', '--log-file', $logPath)
if ($Mode -ne 'capture') { $engineArgs += '--headless' }
$userArg = switch ($Mode) { 'logic' {'--auto-test'} 'capture' {'--capture'} 'playthrough' {'--playtest'} }
$engineArgs += @('--', $userArg)
& $enginePath @engineArgs
$engineExit = $LASTEXITCODE
if ($engineExit -ne 0) { exit $engineExit }
$logText = Get-Content -LiteralPath $logPath -Raw
if ($logText -match 'SCRIPT ERROR|(?m)^ERROR:') { Write-Error 'Godot ha emitido errores.'; exit 3 }
$marker = if ($Mode -eq 'playthrough') { 'KHARUUN_PLAYTHROUGH.*"passed":true' } else { 'KHARUUN_TEST_RESULT.*failures=0' }
if ($logText -notmatch $marker) { Write-Error 'La prueba no produjo una confirmación de éxito.'; exit 2 }
exit 0
