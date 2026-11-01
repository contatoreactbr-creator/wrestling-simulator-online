@echo off
title Wrestling Simulator Online
cd /d "%~dp0"
where python >nul 2>nul
if %errorlevel%==0 (
  start "" http://localhost:3000/
  python -m http.server 3000
  goto :eof
)
where py >nul 2>nul
if %errorlevel%==0 (
  start "" http://localhost:3000/
  py -m http.server 3000
  goto :eof
)
echo Python nao foi encontrado.
echo Instale Python 3 ou use a extensao Live Server do VS Code.
pause
