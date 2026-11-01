@echo off
setlocal
title Wrestling Simulator Online
cd /d "%~dp0"

echo ==========================================
echo       WRESTLING SIMULATOR ONLINE
echo ==========================================
echo.
echo Verificando servidor Python...
echo.

where python >nul 2>&1
if not errorlevel 1 goto USE_PYTHON

where py >nul 2>&1
if not errorlevel 1 goto USE_PY

echo ERRO: Python nao foi encontrado neste computador.
echo.
echo Instale o Python 3 em https://www.python.org/downloads/
echo Durante a instalacao, marque "Add Python to PATH".
echo Depois, execute este arquivo novamente.
echo.
pause
exit /b 1

:USE_PYTHON
echo Python encontrado. Iniciando o servidor na porta 3000...
echo.
start "" http://localhost:3000/
python -m http.server 3000
goto SERVER_STOPPED

:USE_PY
echo Launcher py encontrado. Iniciando o servidor na porta 3000...
echo.
start "" http://localhost:3000/
py -m http.server 3000
goto SERVER_STOPPED

:SERVER_STOPPED
echo.
echo O servidor foi encerrado ou apresentou um erro.
echo Verifique a mensagem acima. Se aparecer "Address already in use",
echo feche outro servidor que esteja usando a porta 3000.
echo.
pause
