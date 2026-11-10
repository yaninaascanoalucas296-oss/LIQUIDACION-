@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
cd /d "%~dp0"
title Instalador - Anexo Local
echo ============================================
echo   INSTALADOR - SANTRIX ANEXO LOCAL
echo ============================================
echo.

where php >nul 2>nul
if errorlevel 1 (
  echo [ERROR] No se encontro PHP en el PATH.
  echo Instala PHP 8.2 o superior ^(https://windows.php.net/download^) o XAMPP/Laragon
  echo y agrega la carpeta de PHP al PATH. Luego ejecuta este archivo otra vez.
  goto :fin
)
where composer >nul 2>nul
if errorlevel 1 (
  echo [ERROR] No se encontro Composer.
  echo Descargalo de https://getcomposer.org/download/ e instalalo. Luego ejecuta este archivo otra vez.
  goto :fin
)

echo [1/6] Verificando version de PHP...
php -r "exit(version_compare(PHP_VERSION,'8.2.0','>=')?0:1);"
if errorlevel 1 (
  echo [ERROR] Se requiere PHP 8.2 o superior.
  php -v
  goto :fin
)

echo [2/6] Verificando extensiones de PHP...
set FALTA=
for %%E in (mbstring openssl pdo_sqlite sqlite3 fileinfo zip xml dom gd ctype tokenizer curl) do (
  php -m | findstr /i /x "%%E" >nul
  if errorlevel 1 set FALTA=!FALTA! %%E
)
if not "!FALTA!"=="" (
  echo [ERROR] Faltan extensiones de PHP:!FALTA!
  echo Abre php.ini y quita el ";" delante de extension=nombre para cada una.
  echo Archivo php.ini en uso:
  php --ini | findstr /i "Loaded"
  goto :fin
)

echo [3/6] Instalando dependencias PHP ^(composer^)...
call composer install --no-dev --optimize-autoloader --no-interaction
if errorlevel 1 ( echo [ERROR] Fallo composer install. & goto :fin )

echo [4/6] Configurando archivo .env...
if not exist ".env" copy ".env.example" ".env" >nul
findstr /b /c:"APP_KEY=base64:" ".env" >nul
if errorlevel 1 call php artisan key:generate --force
if not exist "database\database.sqlite" type nul > "database\database.sqlite"

echo [5/6] Preparando base de datos...
call php artisan migrate --force
if errorlevel 1 ( echo [ERROR] Fallo la migracion. & goto :fin )
call php artisan storage:link >nul 2>nul
call php artisan optimize:clear >nul

echo [6/6] Verificando estilos ^(public\build^)...
if not exist "public\build\manifest.json" (
  where npm >nul 2>nul
  if errorlevel 1 (
    echo [AVISO] Falta public\build y no hay Node.js. Instala Node 20+ y ejecuta: npm install ^& npm run build
  ) else (
    call npm install
    call npm run build
  )
)

echo.
echo ============================================
echo   INSTALACION COMPLETA
echo   Ejecuta iniciar.bat para abrir la aplicacion.
echo ============================================
:fin
echo.
pause
