@echo off
chcp 65001 >nul
title Ikariam Wars — Configuracao do Servidor
echo.
echo  ================================================
echo   IKARIAM WARS — Configuracao Inicial
echo  ================================================
echo.
echo  Procurando o Godot Engine instalado...
echo.

set GODOT_EXE=

:: Procura em locais comuns do Windows
for %%P in (
    "%LOCALAPPDATA%\Programs\Godot Engine"
    "%PROGRAMFILES%\Godot Engine"
    "%PROGRAMFILES(X86)%\Godot Engine"
    "%USERPROFILE%\Desktop"
    "%USERPROFILE%\Downloads"
    "C:\Godot"
    "D:\Godot"
    "C:\Tools"
) do (
    if exist "%%~P" (
        for /r "%%~P" %%F in (Godot_v4*.exe) do (
            if not defined GODOT_EXE (
                set GODOT_EXE=%%F
            )
        )
    )
)

:: Tambem tenta na raiz de todas as unidades
for %%D in (C D E F G) do (
    if not defined GODOT_EXE (
        for /f "delims=" %%F in ('dir /b /s "%%D:\Godot_v4*.exe" 2^>nul') do (
            if not defined GODOT_EXE set GODOT_EXE=%%F
        )
    )
)

if defined GODOT_EXE (
    echo  Godot encontrado:
    echo  %GODOT_EXE%
    echo.
    echo %GODOT_EXE%> godot_path.txt
    echo  Caminho salvo em godot_path.txt
    echo.
    echo  Configuracao concluida! Use start_server.bat para iniciar.
    echo.
    pause
    exit /b 0
)

echo  Godot nao encontrado automaticamente.
echo.
echo  Por favor, localize o arquivo Godot_v4.x_win64.exe manualmente.
echo  Ele esta na pasta onde voce instalou o Godot Engine.
echo.
echo  Cole o caminho completo abaixo (ou pressione ENTER para cancelar):
echo  Exemplo: C:\Users\SeuNome\Downloads\Godot_v4.6-stable_win64.exe
echo.
set /p MANUAL_PATH="Caminho do Godot.exe: "

if "%MANUAL_PATH%"=="" (
    echo  Cancelado.
    pause
    exit /b 1
)

if not exist "%MANUAL_PATH%" (
    echo  Arquivo nao encontrado: %MANUAL_PATH%
    pause
    exit /b 1
)

echo %MANUAL_PATH%> godot_path.txt
echo.
echo  Caminho salvo! Use start_server.bat para iniciar o servidor.
echo.
pause
