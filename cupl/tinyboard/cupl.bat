@echo off
setlocal

rem Usage: cupl.bat c:\design.pld [/p]
rem /p pauses the command instead of exiting

set CUPLPATH=C:\WINCUPL
set LIBCUPL=%CUPLPATH%\Shared\CUPL.DL
set PATH=%PATH%;%CUPLPATH%\WinCupl;%CUPLPATH%\WinCupl\Fitters;%CUPLPATH%\Shared

if not exist "%~dpnx1" (
    echo Error: Input file '%~dpnx1' does not exist
    goto :error
)

cd %~dp1

rem Delete old output files
for %%e in (abs doc fit io jed lst mx pin pla sim tt2 tt3) do (
    if exist "%~dpn1.%%e" del /Q "%~dpn1.%%e"
)

rem Get device from PLD file
FOR /F "tokens=2 delims=; " %%D in ('FINDSTR /RB "^Device *([a-zA-Z0-9]+) *;" "%~dpnx1"') do set DEVICE=%%D

IF NOT DEFINED DEVICE (
    echo Error: Unable to detect device. Check for 'Device XYZ;' in your PLD file.
    goto :error
)

rem Run CUPL compiler — NO external fitter, generate JED directly
echo cupl.exe -a -l -e -x -b -j -m0 -n %DEVICE% %~nx1
cupl.exe -a -l -e -x -b -j -m0 -n %DEVICE% "%~nx1" || (
    echo Error: CUPL compilation failed.
    goto :error
)

if not exist "%~dpn1.jed" (
    echo Error: .JED file was not produced by CUPL.
    goto :error
)

echo Device %DEVICE% does not require a fitter. JEDEC generated directly.

echo Done!
if "%2"=="/p" pause
exit /B 0

:error
if "%2"=="/p" pause
exit /B 1