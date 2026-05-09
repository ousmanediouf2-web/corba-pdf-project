@echo off
echo ===================================================
echo    Build de l'Application Web CORBA PDF
echo ===================================================

set PROJECT_DIR=%~dp0
set WEB_DIR=%PROJECT_DIR%web-app
set CORBA_DIR=%PROJECT_DIR%corba-server
set IDL_FILE=%PROJECT_DIR%idl\PDFService.idl
set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_xxx

echo.
echo [1/3] Generation des stubs CORBA pour le client web...
if not exist "%WEB_DIR%\src\main\java\pdfservice" mkdir "%WEB_DIR%\src\main\java\pdfservice"

"%JAVA_HOME%\bin\idlj" -fclient -td "%WEB_DIR%\src\main\java" "%IDL_FILE%"
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Echec IDL
    pause
    exit /b 1
)
echo   OK - Stubs client generes

echo.
echo [2/3] Configuration MongoDB Atlas...
echo   IMPORTANT: Editez le fichier suivant et remplacez YOUR_USERNAME, YOUR_PASSWORD, YOUR_CLUSTER:
echo   %WEB_DIR%\src\main\java\com\pdfservice\dao\MongoDBDAO.java
echo.
pause

echo.
echo [3/3] Compilation Maven du projet web...
cd /d "%WEB_DIR%"
call mvn clean package -q
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Echec compilation
    pause
    exit /b 1
)

echo.
echo ===================================================
echo   BUILD REUSSI !
echo ===================================================
echo.
echo   Fichier WAR genere:
echo   %WEB_DIR%\target\corba-pdf-app.war
echo.
echo   Pour deployer:
echo   1. Demarrez d'abord le serveur CORBA: start-corba-server.bat
echo   2. Copiez le WAR dans: [TOMCAT]\webapps\
echo   3. Demarrez Tomcat
echo   4. Accedez a: http://localhost:8080/corba-pdf-app
echo.
pause
