@echo off
setlocal EnableExtensions

set "REPO_URL=https://github.com/Nataliogc/Menus-Turisticos.git"
set "BRANCH=main"
set "MSG=%~1"
if "%MSG%"=="" set "MSG=Actualizacion Menus Turisticos"

pushd "%~dp0"

where git >nul 2>&1 || (echo [ERROR] Git no esta en PATH & popd & pause & exit /b 1)
if not exist "index.html" (echo [ERROR] No se encontro index.html en %CD% & popd & pause & exit /b 1)

:: init si no hay repo
git rev-parse --is-inside-work-tree >nul 2>&1 || git init

:: remote origin si falta
git remote get-url origin >nul 2>&1 || git remote add origin "%REPO_URL%"

:: rama de trabajo
git checkout "%BRANCH%" 2>nul || git checkout -b "%BRANCH%"

:: 1) guarda tus cambios locales en un commit (si los hay)
git add -A
git commit -m "%MSG%" >nul 2>&1

:: 2) trae remoto y re-aplica tu commit encima (evita “untracked would be overwritten” y non-FF)
git fetch origin
git pull --rebase origin "%BRANCH%" || (
  echo [AVISO] Rebase no aplicable; intentando sincronizar con estrategia "ours"...
  git merge -s ours origin/%BRANCH% -m "Merge ours vs origin/%BRANCH% (auto)"
)

:: 3) sube
git push -u origin "%BRANCH%" || (echo [ERROR] Push fallo. Revisa credenciales/token. & popd & pause & exit /b 1)

echo.
echo [OK] Publicado. URL: https://nataliogc.github.io/Menus-Turisticos/
start "" "https://nataliogc.github.io/Menus-Turisticos/"

popd
pause
endlocal
