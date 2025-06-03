@echo off
setlocal EnableDelayedExpansion
cd /d %~dp0

:: config
set APP_NAME=make-mac-machine
set APP_ICON=app.ico

:: cleanup
rmdir /s /q "dist\%APP_NAME%" 2>nul

echo.
echo ****************************************
echo Running pyinstaller...
echo ****************************************

pyinstaller --noupx -i "%APP_ICON%" -n "%APP_NAME%" -D main.py

echo.
echo ****************************************
echo Copying resources...
echo ****************************************

xcopy /e ..\bin "dist\%APP_NAME%\_internal\bin\" >nul
xcopy /e ..\dsk "dist\%APP_NAME%\_internal\dsk\" >nul
xcopy /e ..\vmx "dist\%APP_NAME%\_internal\vmx\" >nul

echo.
echo ****************************************
echo Optimizing dist folder...
echo ****************************************

del dist\%APP_NAME%\_internal\api-ms-win-*.dll
del dist\%APP_NAME%\_internal\libcrypto-3.dll
del dist\%APP_NAME%\_internal\ucrtbase.dll

echo.
pause
