@echo off
chcp 65001 >nul
title TribalLine — Servidor

:: -- Porta do server.cfg ---------------------------------------------------
set PORT=7777
for /f "tokens=1,2 delims==" %%a in (server.cfg) do (
    if "%%a"=="port" set PORT=%%b
)
set PORT=%PORT: =%

:: -- Encontrar Godot --------------------------------------------------------
set GODOT_EXE=

:: 1. .exe exportado (producao)
if exist "triballine.exe" (
    echo [Server] Usando triballine.exe...
    triballine.exe --headless -- --server --port %PORT%
    goto :end
)

:: 2. godot_path.txt (configurado pelo setup.bat)
if exist "godot_path.txt" (
    set /p GODOT_EXE=<godot_path.txt
)

:: 3. Caminho conhecido nesta maquina (detectado automaticamente)
if not defined GODOT_EXE (
    set GODOT_EXE=C:\Users\luang\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64.exe
)

:: 4. Verificar e executar
if not exist "%GODOT_EXE%" (
    echo.
    echo  ERRO: Godot nao encontrado em:
    echo  %GODOT_EXE%
    echo.
    echo  Execute setup.bat para reconfigurar.
    echo.
    pause
    goto :end
)

echo ============================================================
echo  TribalLine — Servidor Dedicado
echo  Porta  : %PORT%
echo  Projeto: C:\Work\TribalLine
echo  Godot  : %GODOT_EXE%
echo  Pressione Ctrl+C para parar
echo ============================================================
echo.

"%GODOT_EXE%" --path "C:\Work\TribalLine" --headless -- --server --port %PORT%

:end
