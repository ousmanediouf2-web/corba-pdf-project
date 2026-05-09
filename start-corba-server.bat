@echo off
echo ===================================================
echo    Demarrage du Serveur CORBA PDF Service
echo ===================================================

REM --- Configuration ---
set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_xxx
set PROJECT_DIR=%~dp0corba-server

cd /d %PROJECT_DIR%

REM --- Etape 1: Generer les stubs/skeletons depuis l'IDL ---
echo.
echo [1/3] Generation des stubs CORBA depuis IDL...
if not exist "src\main\java\pdfservice" mkdir "src\main\java\pdfservice"

"%JAVA_HOME%\bin\idlj" -fall -td src\main\java ..\idl\PDFService.idl
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Echec de la generation IDL
    pause
    exit /b 1
)
echo   OK - Stubs generes dans src/main/java/pdfservice/

REM --- Etape 2: Compiler le projet ---
echo.
echo [2/3] Compilation Maven...
call mvn clean package -q
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Echec de la compilation Maven
    pause
    exit /b 1
)
echo   OK - JAR compile

REM --- Etape 3: Demarrer le ORBd (Name Service) et le serveur ---
echo.
echo [3/3] Demarrage du Name Service CORBA (port 1050)...

REM Demarrer orbd en arriere-plan
start "CORBA NameService" "%JAVA_HOME%\bin\orbd" -ORBInitialPort 1050 -ORBInitialHost localhost

timeout /t 3 /nobreak >nul
echo   OK - NameService demarre

echo.
echo Demarrage du Serveur PDF CORBA...
"%JAVA_HOME%\bin\java" -cp target\corba-server-1.0-SNAPSHOT-jar-with-dependencies.jar ^
    -Dorg.omg.CORBA.ORBInitialHost=localhost ^
    -Dorg.omg.CORBA.ORBInitialPort=1050 ^
    com.pdfservice.server.PDFServer

pause
