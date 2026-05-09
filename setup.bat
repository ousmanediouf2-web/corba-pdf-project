@echo off
setlocal EnableDelayedExpansion

echo.
echo ╔══════════════════════════════════════════════════╗
echo ║       CORBA PDF Service - Setup Complet          ║
echo ╚══════════════════════════════════════════════════╝
echo.

REM ---- Detecter JAVA_HOME ----
if defined JAVA_HOME (
    echo [✓] JAVA_HOME detecte: %JAVA_HOME%
) else (
    echo [!] JAVA_HOME non defini. Recherche automatique...
    for /f "tokens=*" %%i in ('where java 2^>nul') do (
        set JAVA_BIN=%%i
        goto :found_java
    )
    echo [✗] Java non trouve. Installez JDK 8 et definissez JAVA_HOME
    pause
    exit /b 1
    :found_java
    echo [✓] Java trouve: !JAVA_BIN!
)

REM ---- Verifier Maven ----
mvn -version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [✗] Maven non trouve. Installez Maven et ajoutez-le au PATH.
    pause
    exit /b 1
)
echo [✓] Maven disponible

echo.
echo ═══════════════════════════════════════════════════
echo  CONFIGURATION MONGODB ATLAS
echo ═══════════════════════════════════════════════════
echo.
set /p MONGO_URI="Entrez votre URI MongoDB Atlas (ou Entree pour passer): "

if not "!MONGO_URI!"=="" (
    REM Remplacer l'URI dans MongoDBDAO.java
    powershell -Command "(Get-Content 'web-app\src\main\java\com\pdfservice\dao\MongoDBDAO.java') -replace 'mongodb\+srv://YOUR_USERNAME:YOUR_PASSWORD@YOUR_CLUSTER.mongodb.net/pdfservice.*', '!MONGO_URI!' | Set-Content 'web-app\src\main\java\com\pdfservice\dao\MongoDBDAO.java'"
    echo [✓] URI MongoDB configuree
) else (
    echo [!] URI MongoDB non configuree - editez MongoDBDAO.java manuellement
)

echo.
echo ═══════════════════════════════════════════════════
echo  GENERATION DES STUBS IDL
echo ═══════════════════════════════════════════════════
echo.

REM Generer stubs pour le serveur CORBA
echo Generation des stubs serveur...
if not exist "corba-server\src\main\java\pdfservice" mkdir "corba-server\src\main\java\pdfservice"
"%JAVA_HOME%\bin\idlj" -fall -td "corba-server\src\main\java" "idl\PDFService.idl"
if %ERRORLEVEL% NEQ 0 (
    echo [✗] Echec generation stubs serveur
    pause
    exit /b 1
)
echo [✓] Stubs serveur generes

REM Generer stubs pour le client web
echo Generation des stubs client...
if not exist "web-app\src\main\java\pdfservice" mkdir "web-app\src\main\java\pdfservice"
"%JAVA_HOME%\bin\idlj" -fclient -td "web-app\src\main\java" "idl\PDFService.idl"
if %ERRORLEVEL% NEQ 0 (
    echo [✗] Echec generation stubs client
    pause
    exit /b 1
)
echo [✓] Stubs client generes

echo.
echo ═══════════════════════════════════════════════════
echo  COMPILATION
echo ═══════════════════════════════════════════════════
echo.

REM Compiler le serveur CORBA
echo Compilation du serveur CORBA...
cd corba-server
call mvn clean package -q
if %ERRORLEVEL% NEQ 0 (
    echo [✗] Echec compilation serveur CORBA
    cd ..
    pause
    exit /b 1
)
echo [✓] Serveur CORBA compile: corba-server\target\corba-server-1.0-SNAPSHOT-jar-with-dependencies.jar
cd ..

REM Compiler l'application web
echo Compilation de l'application web...
cd web-app
call mvn clean package -q
if %ERRORLEVEL% NEQ 0 (
    echo [✗] Echec compilation application web
    cd ..
    pause
    exit /b 1
)
echo [✓] Application web compilee: web-app\target\corba-pdf-app.war
cd ..

echo.
echo ═══════════════════════════════════════════════════
echo  DEPLOIEMENT TOMCAT
echo ═══════════════════════════════════════════════════
echo.
set /p TOMCAT_DIR="Entrez le chemin vers Tomcat (ex: C:\tomcat9) ou Entree pour ignorer: "

if not "!TOMCAT_DIR!"=="" (
    if exist "!TOMCAT_DIR!\webapps" (
        copy "web-app\target\corba-pdf-app.war" "!TOMCAT_DIR!\webapps\"
        echo [✓] WAR copie dans !TOMCAT_DIR!\webapps\

        REM Configurer setenv.bat pour CORBA
        echo set JAVA_OPTS=-Dcorba.host=localhost -Dcorba.port=1050> "!TOMCAT_DIR!\bin\setenv.bat"
        echo [✓] setenv.bat configure
    ) else (
        echo [!] Repertoire Tomcat invalide: !TOMCAT_DIR!\webapps non trouve
    )
) else (
    echo [!] Copiez manuellement web-app\target\corba-pdf-app.war dans votre Tomcat\webapps\
)

echo.
echo ╔══════════════════════════════════════════════════╗
echo ║                 SETUP TERMINE !                  ║
echo ╚══════════════════════════════════════════════════╝
echo.
echo Pour lancer l'application:
echo.
echo   1. Demarrez le serveur CORBA:
echo      start-corba-server.bat
echo.
echo   2. Demarrez Tomcat:
echo      [TOMCAT]\bin\startup.bat
echo.
echo   3. Ouvrez votre navigateur:
echo      http://localhost:8080/corba-pdf-app
echo.
pause
