@echo off
setlocal
title Wrestling Simulator Online
cd /d "%~dp0"

echo ==========================================
echo       WRESTLING SIMULATOR ONLINE
echo ==========================================
echo.
echo Procurando uma instalacao funcional do Python...
echo.

python --version >nul 2>&1
if not errorlevel 1 goto USE_PYTHON

py -3 --version >nul 2>&1
if not errorlevel 1 goto USE_PY

echo Python nao esta instalado ou nao esta configurado.
echo.
echo 1. Abra https://www.python.org/downloads/windows/
echo 2. Baixe Python 3 para Windows.
echo 3. Execute o instalador e marque "Add python.exe to PATH".
echo 4. Clique em Install Now.
echo 5. Ao terminar, feche esta janela e execute INICIAR-JOGO.bat novamente.
echo.
echo Se o Python ja estiver instalado, desative os aliases python.exe e python3.exe
echo em Configuracoes > Aplicativos > Configuracoes avancadas > Aliases de execucao.
echo.
pause
exit /b 1

:USE_PYTHON
echo Python funcional encontrado. Iniciando servidor na porta 3000...
echo.
start "" http://localhost:3000/
python -m http.server 3000
goto SERVER_STOPPED

:USE_PY
echo Python funcional encontrado pelo launcher py. Iniciando servidor...
echo.
start "" http://localhost:3000/
py -3 -m http.server 3000
goto SERVER_STOPPED

:SERVER_STOPPED
echo.
echo O servidor foi encerrado ou apresentou um erro.
echo Confira a mensagem acima.
echo.
pause
