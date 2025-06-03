@echo off
setlocal EnableDelayedExpansion
cd /d %~dp0

:: config
set APP_NAME=make-mac-machine
set APP_ICON=app.ico
set DIR=%CD%
set APP_DIR=%CD%\dist\%APP_NAME%\

:: cleanup
rmdir /s /q "dist\%APP_NAME%" 2>nul

::del "dist\%APP_NAME%-x64-setup.exe" 2>nul
::del "dist\%APP_NAME%-x64-portable.7z" 2>nul

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

::call :create_7z
::call :create_installer

:done
echo.
echo ****************************************
echo Done.
echo ****************************************
echo.
pause

endlocal
goto :eof

:create_7z
if not exist "C:\Program Files\7-Zip\" (
	echo.
	echo ****************************************
	echo 7z.exe not found at default location, omitting .7z creation...
	echo ****************************************
	exit /B
)
echo.
echo ****************************************
echo Creating .7z archive...
echo ****************************************
cd dist
set PATH=C:\Program Files\7-Zip;%PATH%
7z a "%APP_NAME%-x64-portable.7z" "%APP_NAME%\*"
cd ..
exit /B

:create_installer
if not exist "C:\Program Files (x86)\NSIS\" (
	echo.
	echo ****************************************
	echo NSIS not found at default location, omitting installer creation...
	echo ****************************************
	exit /B
)
echo.
echo ****************************************
echo Creating installer...
echo ****************************************

:: get length of APP_DIR
set TF=%TMP%\x
echo %APP_DIR%> %TF%
for %%? in (%TF%) do set /a LEN=%%~z? - 2
del %TF%

call :make_abs_nsh nsis\uninstall_list.nsh

del "%NSH%" 2>nul

cd "%APP_DIR%"

for /F %%f in ('dir /b /a-d') do (
	echo Delete "$INSTDIR\%%f" >> "%NSH%"
)

for /F %%d in ('dir /s /b /aD') do (
	cd "%%d"
	set DIR_REL=%%d
	for /F %%f IN ('dir /b /a-d 2^>nul') do (
		echo Delete "$INSTDIR\!DIR_REL:~%LEN%!\%%f" >> "%NSH%"
	)
)

cd "%APP_DIR%"

for /F %%d in ('dir /s /b /ad^|sort /r') do (
	set DIR_REL=%%d
	echo RMDir "$INSTDIR\!DIR_REL:~%LEN%!" >> "%NSH%"
)

cd "%DIR%"
set PATH=C:\Program Files (x86)\NSIS;%PATH%
makensis nsis\make-installer.nsi
exit /B

:make_abs_nsh
set NSH=%~dpnx1%
exit /B
