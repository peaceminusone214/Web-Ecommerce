@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

echo [eCommerceWebsite] Starting executable JAR...

rem -- Parse args for --port or --port=VALUE
set "PORT_ARG="
:parse
if "%~1"=="" goto after_parse
if /I "%~1"=="--port" (
    if not "%~2"=="" (
        set "PORT_ARG=%~2"
        shift
    )
) else (
    for /f "tokens=1,2 delims==" %%A in ("%~1") do (
        if /I "%%~A"=="--port" set "PORT_ARG=%%~B"
    )
)
shift
goto parse

:after_parse

where java >nul 2>&1
if errorlevel 1 (
  echo Java khong co trong PATH. Cai dat JDK/JRE va thu lai.
  exit /b 1
)

rem -- Find exec jar in target (prefer latest). Fallback to default name.
set "JAR="
for /f "delims=" %%F in ('dir /b /a:-d /o:-d target\*-exec.jar 2^>nul') do (
  set "JAR=target\%%F"
  goto :foundJar
)

set "JAR=target\eCommerceWebsite-1.0-SNAPSHOT-exec.jar"
:foundJar

if not exist "%JAR%" (
  echo Khong tim thay JAR tu chay: %JAR%
  echo Hay build truoc bang: mvn -DskipTests=true clean package
  exit /b 1
)

set "PORT_TO_USE=%PORT%"
if "%PORT_TO_USE%"=="" set "PORT_TO_USE=8080"
if not "%PORT_ARG%"=="" set "PORT_TO_USE=%PORT_ARG%"

echo [eCommerceWebsite] Running on http://localhost:%PORT_TO_USE%
echo [eCommerceWebsite] JAR: %JAR%

java -Dport=%PORT_TO_USE% -jar "%JAR%"
exit /b %ERRORLEVEL%

