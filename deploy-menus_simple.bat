@echo off
setlocal EnableExtensions

rem === Configura tu repo y rama ===
set "REPO_URL=https://github.com/Nataliogc/Menus-Turisticos.git"
set "BRANCH=main"

rem Mensaje de commit (opcional como primer argumento)
set "MSG=%~1"
if "%MSG%"=="" set "MSG=Actualizacion Menus Turisticos"

rem (OPCIONAL) Token para activar Pages via API
rem set GH_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

rem --- Ir a la carpeta del script (soporta espacios/puntos) ---
pushd "%~dp0"

rem --- Comprobaciones básicas ---
where git >nul 2>&1 || (echo [ERROR] Git no esta en PATH. Instala Git for Windows. & pause & exit /b 1)
if not exist "index.html" (echo [ERROR] No se encontro index.html en %CD% & pause & exit /b 1)

rem --- Inicializar repo si hace falta ---
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo [INFO] Inicializando repositorio Git en %CD% ...
  git init || (echo [ERROR] git init & popd & pause & exit /b 1)
)

rem --- Configurar remote 'origin' si falta ---
git remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo [INFO] Configurando remote origin -> %REPO_URL%
  git remote add origin "%REPO_URL%" || (echo [ERROR] No se pudo agregar remote origin & popd & pause & exit /b 1)
)

rem --- Asegurar rama de trabajo ---
git checkout "%BRANCH%" 2>nul || git checkout -b "%BRANCH%"

rem --- Traer cambios remotos (si existen) sin romper primer push ---
git fetch origin "%BRANCH%" >nul 2>&1
git rev-parse --verify "origin/%BRANCH%" >nul 2>&1 && git pull --rebase origin "%BRANCH%"

rem --- Añadir y commitear ---
git add -A
git commit -m "%MSG%" >nul 2>&1
if errorlevel 1 (
  echo [INFO] No hay cambios nuevos que commitear.
) else (
  echo [INFO] Commit creado.
)

rem --- Subir a GitHub ---
git push -u origin "%BRANCH%" || (echo [ERROR] Push fallo. Revisa credenciales/token. & popd & pause & exit /b 1)

rem --- Activar GitHub Pages (opcional) ---
if not "%GH_TOKEN%"=="" (
  where curl >nul 2>&1 && (
    echo [INFO] Activando/ajustando GitHub Pages...
    curl -s -X POST "https://api.github.com/repos/Nataliogc/Menus-Turisticos/pages" ^
      -H "Authorization: Bearer %GH_TOKEN%" ^
      -H "Accept: application/vnd.github+json" ^
      -H "X-GitHub-Api-Version: 2022-11-28" ^
      -d "{\"source\":{\"branch\":\"%BRANCH%\",\"path\":\"/\"}}" >nul
    curl -s -X PUT "https://api.github.com/repos/Nataliogc/Menus-Turisticicos/pages" ^
      -H "Authorization: Bearer %GH_TOKEN%" ^
      -H "Accept: application/vnd.github+json" ^
      -H "X-GitHub-Api-Version: 2022-11-28" ^
      -d "{\"source\":{\"branch\":\"%BRANCH%\",\"path\":\"/\"}}" >nul
  )
)

echo.
echo [OK] Publicado. URL: https://nataliogc.github.io/Menus-Turisticos/
start "" "https://nataliogc.github.io/Menus-Turisticos/"

popd
pause
endlocal
