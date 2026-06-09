# watch_server.ps1
# Reinicia o servidor Godot automaticamente quando .gd/.tscn/.tres/project.godot mudam.
# Versao POLLING: tudo roda no thread principal (sem as armadilhas de evento do
# FileSystemWatcher no PowerShell). Uso: rodar watch_server.bat
$ErrorActionPreference = "Stop"

$ProjectDir = "C:\Work\TribalLine"
$ServerDir  = "C:\Work\TribalLineServer"
$Port       = "7777"
$DebounceMs = 800   # espera apos a ultima mudanca antes de reiniciar
$PollMs     = 500   # intervalo de verificacao

# --- Ler porta do server.cfg (opcional) ---
$cfgPath = Join-Path $ServerDir "server.cfg"
if (Test-Path $cfgPath) {
    $line = Select-String -Path $cfgPath -Pattern "^port\s*=" | Select-Object -First 1
    if ($line) { $Port = ($line.Line -split "=")[1].Trim() }
}

# --- Descobrir Godot ---
$GodotExe = ""
$pathFile = Join-Path $ServerDir "godot_path.txt"
if (Test-Path $pathFile) { $GodotExe = (Get-Content $pathFile -Raw).Trim() }
if (-not $GodotExe -or -not (Test-Path $GodotExe)) {
    $fallback = "C:\Users\luang\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64.exe"
    if (Test-Path $fallback) { $GodotExe = $fallback }
}
if (-not (Test-Path $GodotExe)) {
    Write-Host "ERRO: Godot nao encontrado. Execute setup.bat primeiro." -ForegroundColor Red
    pause; exit 1
}

Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host "   TRIBALLINE - Watch Server (polling)" -ForegroundColor Yellow
Write-Host "   Projeto : $ProjectDir" -ForegroundColor Cyan
Write-Host "   Porta   : $Port" -ForegroundColor Cyan
Write-Host "   Godot   : $GodotExe" -ForegroundColor Cyan
Write-Host "   Monitora: *.gd | *.tscn | *.tres | project.godot" -ForegroundColor Cyan
Write-Host "   Ctrl+C para parar" -ForegroundColor Cyan
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host ""

$ServerProc = $null

function Start-Server {
    if ($script:ServerProc -and -not $script:ServerProc.HasExited) {
        Write-Host "[Watch] Parando servidor anterior (PID $($script:ServerProc.Id))..." -ForegroundColor Yellow
        try { $script:ServerProc.Kill(); $script:ServerProc.WaitForExit(3000) | Out-Null } catch {}
    }
    Write-Host "[Watch] $(Get-Date -Format 'HH:mm:ss') (re)Iniciando servidor..." -ForegroundColor Green
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName  = $GodotExe
    $psi.Arguments = "--path `"$ProjectDir`" --headless -- --server --port $Port"
    $psi.UseShellExecute = $false   # herda este console (output do servidor visivel aqui)
    $script:ServerProc = [System.Diagnostics.Process]::Start($psi)
    Write-Host "[Watch] Servidor rodando (PID $($script:ServerProc.Id))" -ForegroundColor Green
}

function Get-LatestWrite {
    $files = Get-ChildItem -Path $ProjectDir -Recurse -File `
        -Include *.gd,*.tscn,*.tres,*.godot -ErrorAction SilentlyContinue
    if (-not $files) { return [datetime]::MinValue }
    return ($files | Measure-Object -Property LastWriteTime -Maximum).Maximum
}

try {
    Start-Server
    $lastWrite     = Get-LatestWrite
    $pendingChange = $null

    while ($true) {
        Start-Sleep -Milliseconds $PollMs

        # Servidor caiu sozinho? reinicia
        if ($script:ServerProc.HasExited) {
            Write-Host "[Watch] Servidor caiu (codigo $($script:ServerProc.ExitCode)), reiniciando..." -ForegroundColor Magenta
            Start-Server
        }

        # Algum arquivo mudou?
        $now = Get-LatestWrite
        if ($now -gt $lastWrite) {
            $lastWrite     = $now
            $pendingChange = Get-Date
            Write-Host "[Watch] Mudanca detectada ($(Get-Date -Format 'HH:mm:ss'))..." -ForegroundColor DarkYellow
        }

        # Debounce: passou tempo suficiente desde a ultima mudanca? reinicia
        if ($pendingChange -and ((Get-Date) - $pendingChange).TotalMilliseconds -ge $DebounceMs) {
            $pendingChange = $null
            Start-Server
        }
    }
} finally {
    if ($script:ServerProc -and -not $script:ServerProc.HasExited) {
        Write-Host "[Watch] Encerrando servidor..." -ForegroundColor Yellow
        try { $script:ServerProc.Kill() } catch {}
    }
    Write-Host "[Watch] Watch encerrado." -ForegroundColor Red
}
