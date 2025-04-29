@echo off
setlocal

rem Usage: cupl.bat c:\design.pld [/p]
rem /p pauses the command instead of exiting, for use in a build shortcut

set CUPLPATH=C:\WINCUPL
set LIBCUPL=%CUPLPATH%\Shared\CUPL.DL
set PATH=%PATH%;%CUPLPATH%\WinCupl;%CUPLPATH%\WinCupl\Fitters;%CUPLPATH%\Shared

if not exist "%~dpnx1" (
	echo Error: Input file '%~dpnx1' does not exist
	goto :error
)

rem cupl likes to execute where the file is located
cd %~dp1

rem delete build outputs if some are present
for %%e in (abs doc fit io jed lst mx pin pla sim tt2 tt3) do (
  if exist "%~dpn1.%%e" del /Q "%~dpn1.%%e"
)

rem get device from file
FOR /F "tokens=2 delims=; " %%D in ('FINDSTR /RB "^Device *([a-zA-Z0-9]+) *;" "%~dpnx1"') do set DEVICE=%%D

IF NOT DEFINED DEVICE (
	echo Error: Unable to automatically detect device from file. Make sure to use `Device XXX;` in your design.
	goto :error
)

rem execute cupl
echo cupl.exe -a -l -e -x -f -b -j -m0 -n %DEVICE% %~nx1
cupl.exe -a -l -e -x -f -b -j -m0 -n %DEVICE% "%~nx1" || (
	echo Error: executing cupl.exe failed
	goto :error
)

if not exist "%~dpn1.tt2" (
	echo Error: tt2 output from cupl.exe does not exist
	goto :error
)

rem translate device from pld file to fitter and arguments
rem TODO: How to make this code nicer?
IF "%DEVICE%"=="f1502ispplcc44" (
	SET FITTER=find1502.exe
	SET FITTER_ARGS=-dev P1502C44 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1502plcc44" (
	SET FITTER=find1502.exe
	SET FITTER_ARGS=-dev P1502C44
) ELSE IF "%DEVICE%"=="f1502isptqfp44" (
	SET FITTER=find1502.exe
	SET FITTER_ARGS=-dev P1502T44 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1502tqfp44" (
	SET FITTER=find1502.exe
	SET FITTER_ARGS=-dev P1502T44
) ELSE IF "%DEVICE%"=="f1504ispplcc44" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504C44 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1504plcc44" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504C44
) ELSE IF "%DEVICE%"=="f1504ispplcc68" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504C68 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1504plcc68" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504C68
) ELSE IF "%DEVICE%"=="f1504ispplcc84" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504C84 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1504plcc84" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504C84
) ELSE IF "%DEVICE%"=="f1504ispqfp100" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504Q100 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1504qfp100" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504Q100
) ELSE IF "%DEVICE%"=="f1504isptqfp44" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504T44 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1504tqfp44" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504T44
) ELSE IF "%DEVICE%"=="f1504isptqfp100" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504T100 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1504tqfp100" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504T100
) ELSE IF "%DEVICE%"=="f1504ispplcc84" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504C84 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1504plcc84" (
	SET FITTER=find1504.exe
	SET FITTER_ARGS=-dev P1504C84
) ELSE IF "%DEVICE%"=="f1508ispplcc84" (
	SET FITTER=find1508.exe
	SET FITTER_ARGS=-dev P1508C84 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1508plcc84" (
	SET FITTER=find1508.exe
	SET FITTER_ARGS=-dev P1508C84
) ELSE IF "%DEVICE%"=="f1508ispqfp100" (
	SET FITTER=find1508.exe
	SET FITTER_ARGS=-dev P1508Q100 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1508qfp100" (
	SET FITTER=find1508.exe
	SET FITTER_ARGS=-dev P1508Q100
) ELSE IF "%DEVICE%"=="f1508isppqfp160" (
	SET FITTER=find1508.exe
	SET FITTER_ARGS=-dev P1508Q160 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1508pqfp160" (
	SET FITTER=find1508.exe
	SET FITTER_ARGS=-dev P1508Q160
) ELSE IF "%DEVICE%"=="f1508isptqfp100" (
	SET FITTER=find1508.exe
	SET FITTER_ARGS=-dev P1508T100 -str JTAG ON
) ELSE IF "%DEVICE%"=="f1508tqfp100" (
	SET FITTER=find1508.exe
	SET FITTER_ARGS=-dev P1508T100
)

rem Execute fitter if needed
IF DEFINED FITTER (
	%FITTER% -i "%~dpn1.tt2" -CUPL %FITTER_ARGS% || (
		echo Error: executing fitter failed
		goto :error
	)
	if not exist "%~dpn1.jed" (
		echo Error: jed output from fitter does not exist
		goto :error
	)
) ELSE (
	echo Device %DEVICE% does not need fitter, skipping.
)

echo Done!
if "%2"=="/p" (
	pause
)
exit /B 0

:error
if "%2"=="/p" (
	pause
)
exit /B 1