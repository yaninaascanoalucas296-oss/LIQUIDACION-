@echo off
cd /d "%~dp0"
title Anexo Local - Servidor
if not exist "vendor\autoload.php" (
  echo Primero ejecuta instalar.bat
  pause
  exit /b 1
)
echo Iniciando en http://127.0.0.1:8000  ^(cierra esta ventana para detener^)
start "" http://127.0.0.1:8000
php artisan serve --host=127.0.0.1 --port=8000
pause
