@echo off
setlocal ENABLEDELAYEDEXPANSION
echo [eCommerceWebsite] Starting local server with Jetty...

where mvn >nul 2>&1
if errorlevel 1 (
  echo Maven (mvn) chua duoc cai dat hoac khong co trong PATH. Cai dat Maven roi chay lai.
  exit /b 1
)

if /I not "%1"=="--skip-build" (
  echo [eCommerceWebsite] Building (skipTests)...
  mvn -q -DskipTests=true clean package
  if errorlevel 1 exit /b 1
)

set PORT_TO_USE=%PORT%
if "%PORT_TO_USE%"=="" set PORT_TO_USE=8080
echo [eCommerceWebsite] Running on http://localhost:%PORT_TO_USE%
mvn -Djetty.http.port=%PORT_TO_USE% jetty:run
